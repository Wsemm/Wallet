import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class VoiceCommandService {
  final SpeechToText _speech = SpeechToText();
  late final GenerativeModel _model;

  Completer<AppAction?>? _currentCompleter;
  String _lastRecognizedText = '';

  // Stable transcript and the current in-progress recognition phrase.
  String _savedText = '';
  String _currentWords = '';
  final walletActionSchema = Schema(
    SchemaType.object, // تحديد النوع كـ Object باستخدام الـ Enum الرسمي
    description: 'The root action structure for the wallet app.',
    requiredProperties: [
      'action',
    ], // هنا نستخدم requiredProperties بدلاً من required
    properties: {
      'action': Schema(
        SchemaType.string,
        description:
            'The operation type. Must be strictly either "add" or "export" or "unknown".',
      ),
      'value': Schema(
        SchemaType.object,
        description: 'The transaction details extracted from the text.',
        requiredProperties: [
          'title',
          'amount',
          'type',
          'category',
        ], // الحقول الإلزامية داخل الـ Object الداخلي
        properties: {
          'title': Schema(
            SchemaType.string,
            description: 'Brief title for the transaction.',
          ),
          'amount': Schema(
            SchemaType.number,
            description: 'The monetary value as a double only',
          ),
          'type': Schema(
            SchemaType.string,
            description:
                'The transaction type. Allowed values: "income", "expense", "debt".',
          ),
          'category': Schema(
            SchemaType.string,
            description:
                'The mapped category. Allowed values: "Income", "Expense", "people_debt", "user_debt".',
          ),
          'note': Schema(
            SchemaType.string,
            description: 'Optional notes, can be null or empty string if none.',
          ),
        },
      ),
    },
  );

  VoidCallback? _onProcessingAICallback;
  bool _isSubmitting = false;

  VoiceCommandService() {
    _model = GenerativeModel(
      model: 'models/gemini-3.1-flash-lite',
      apiKey: '',
      generationConfig: GenerationConfig(
        responseMimeType:
            'application/json', // إجبار الموديل على إرجاع جيسون صافي [1]
        responseSchema: walletActionSchema, // فرض الـ Schema البرمجية [1]
      ),
    );
  }

  Future<bool> initSpeech() async {
    return await _speech.initialize();
  }

  String _normalize(String text) {
    return text.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  // Preserve the transcript if the recognizer starts a new phrase
  // after a pause and returns text that no longer contains old words.
  String _mergeRecognizedText(String previous, String incoming) {
    previous = _normalize(previous);
    incoming = _normalize(incoming);

    if (incoming.isEmpty) return previous;
    if (previous.isEmpty) return incoming;

    if (previous == incoming) return previous;

    // Normal case: the recognizer returns the whole phrase so far.
    if (incoming.startsWith(previous)) return incoming;

    // Find overlapping words so repeated partial results are not duplicated.
    final oldWords = previous.split(' ');
    final newWords = incoming.split(' ');

    int overlap = 0;
    final maxOverlap = oldWords.length < newWords.length
        ? oldWords.length
        : newWords.length;

    for (int count = 1; count <= maxOverlap; count++) {
      final oldTail = oldWords.sublist(oldWords.length - count).join(' ');
      final newHead = newWords.sublist(0, count).join(' ');

      if (oldTail.toLowerCase() == newHead.toLowerCase()) {
        overlap = count;
      }
    }

    if (overlap > 0) {
      return _normalize('$previous ${newWords.skip(overlap).join(' ')}');
    }

    // The recognizer returned a different phrase after a pause.
    return _normalize('$previous $incoming');
  }

  Future<AppAction?> listenAndProcessHold({
    required String localeId,
    required Function(String) onResultText,
    required VoidCallback onProcessingAI,
  }) async {
    final available = await initSpeech();

    if (!available) {
      log('Speech engine not available/initialized');
      return null;
    }

    if (_speech.isListening) {
      await _speech.stop();
    }

    _savedText = '';
    _currentWords = '';
    _lastRecognizedText = '';
    _isSubmitting = false;

    _onProcessingAICallback = onProcessingAI;
    _currentCompleter = Completer<AppAction?>();

    await _speech.listen(
      localeId: localeId,
      listenOptions: SpeechListenOptions(
        listenMode: ListenMode.dictation,
        partialResults: true,
        cancelOnError: false,
        listenFor: const Duration(minutes: 2),
        pauseFor: const Duration(seconds: 25),
      ),
      onResult: (result) {
        if (_isSubmitting) return;

        final recognized = _normalize(result.recognizedWords);
        if (recognized.isEmpty) return;

        if (result.finalResult) {
          // Commit the current result into the persistent transcript.
          _savedText = _mergeRecognizedText(_savedText, recognized);
          _currentWords = '';
        } else {
          // Keep partial results separate from committed text.
          // If the recognizer revises its partial result, update it.
          if (_currentWords.isEmpty) {
            _currentWords = recognized;
          } else if (recognized.startsWith(_currentWords)) {
            _currentWords = recognized;
          } else {
            _currentWords = _mergeRecognizedText(_currentWords, recognized);
          }
        }

        _lastRecognizedText = _normalize('$_savedText $_currentWords');

        onResultText(_lastRecognizedText);
      },
    );

    return _currentCompleter!.future;
  }

  Future<void> stopListeningAndSubmit() async {
    if (_isSubmitting) return;
    if (_currentCompleter == null || _currentCompleter!.isCompleted) {
      return;
    }

    _isSubmitting = true;

    // Stop recognition before sending the accumulated transcript.
    if (_speech.isListening) {
      await _speech.stop();
    }

    // Allow any final recognition callback to update the transcript.
    _lastRecognizedText = _normalize('$_savedText $_currentWords');

    _onProcessingAICallback?.call();

    if (_lastRecognizedText.isEmpty) {
      _currentCompleter?.complete(AppAction(action: 'unknown'));
      return;
    }

    final action = await _processTextWithAI(_lastRecognizedText);

    if (_currentCompleter != null && !_currentCompleter!.isCompleted) {
      _currentCompleter!.complete(action);
    }
  }

  Future<AppAction> _processTextWithAI(String text) async {
    final prompt =
        '''
You are a backend assistant for a wallet and expense tracker app.
Analyze the following user voice command (in English or Arabic), determine the CRUD action, and extract the transaction details.

CRITICAL RULES:
1. Return ONLY a raw, clean JSON object. Do NOT wrap it in markdown.
2. The "type" must be strictly one of these lowercase strings: "income", "expense", or "debt".
3. The "createdAt" must be an ISO 8601 date string (YYYY-MM-DDTHH:MM:SSZ). Use the current time context if no date is specified.

TYPE AND CATEGORY MAPPING RULES:
- If the type is "income", category MUST be "Income".
- If the type is "expense", category MUST be "Expense".
- If the type is "debt":
  - If someone owes the user money, category MUST be "people_debt".
  - If the user owes someone else money, category MUST be "user_debt".

Supported Actions:
- "add": insert a new transaction.
- "unknown": command does not match a financial entry.

Current Timestamp: ${DateTime.now().toIso8601String()}

User Command: "$text"

Expected response:
{
  "action": "add",
  "value": {
    "title": "String",
    "amount": 0.0,
    "type": "expense",
    "category": "Expense",
    "note": "String or null"
  }
}

If the command is invalid or unrelated to a wallet app, return:
{"action": "unknown", "value": null}
''';

    int retryCount = 0;
    int delaySeconds = 1;

    while (retryCount < 3) {
      try {
        log('Starting AI processing: $text');

        final response = await _model.generateContent([Content.text(text)]);

        final responseText = response.text;
        if (responseText == null || responseText.trim().isEmpty) {
          throw FormatException('Gemini returned an empty response');
        }

        final jsonResponse = jsonDecode(responseText.trim());
        log('AI response: $jsonResponse');

        return AppAction.fromJson(
          Map<String, dynamic>.from(jsonResponse as Map),
        );
      } catch (e) {
        log('AI processing error: $e');

        if (e.toString().contains('503') && retryCount < 2) {
          retryCount++;
          await Future.delayed(Duration(seconds: delaySeconds));
          delaySeconds *= 2;
          continue;
        }

        break;
      }
    }

    return AppAction(action: 'unknown');
  }
}

class AppAction {
  final String action;
  final Map<String, dynamic>? transactionData;

  AppAction({required this.action, this.transactionData});

  factory AppAction.fromJson(Map<String, dynamic> json) {
    final value = json['value'];

    return AppAction(
      action: json['action'] ?? 'unknown',
      transactionData: value == null
          ? null
          : Map<String, dynamic>.from(value as Map),
    );
  }
}
