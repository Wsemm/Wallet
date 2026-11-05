import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:wallet/core/router/app_router.dart';
import 'package:wallet/core/servcies/tts_service.dart';
import 'package:wallet/core/services/local/export_excel_service.dart';
import 'package:wallet/features/transactions/domain/entities/transaction_entity.dart';
import 'package:wallet/features/transactions/presentation/bloc/transaction_bloc.dart';

class VoiceControlScreen extends StatefulWidget {
  const VoiceControlScreen({super.key});

  @override
  _VoiceControlScreenState createState() => _VoiceControlScreenState();
}

class _VoiceControlScreenState extends State<VoiceControlScreen> {
  final VoiceCommandService _voiceService = VoiceCommandService();
  Color _backgroundColor = Colors.blue;
  String _spokenText = "Press the button and speak...";
  bool _isHoldingButton = false;

  // Track active target language: 'en-US' for English or 'ar-SA' for Arabic
  String _selectedLocale = 'en-US';
  bool _isLoading = false;

  void _executeAction(AppAction appAction) {
    if (!context.mounted) return;
    log("the action data is ${appAction.action}");
    context.pop();
    switch (appAction.action) {
      case 'add':
        if (appAction.transactionData != null) {
          try {
            context.push(
              AppRoutes.addTransaction,
              extra: TransactionEntity.fromJson(appAction.transactionData!),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("حدث خطأ في معالجة بيانات المعاملة"),
              ),
            );
          }
        }
        break;
      case 'export':
        var transState = context.read<TransactionBloc>().state;
        exportToExcel(
          data: transState.transactions.map((e) => e.toJson(e)).toList(),
          summary: [
            {
              "totalIncome": transState.totalIncome,
              "totalExpense": transState.totalExpense,
              "totalDebits": transState.totalDebits,
              "totalBalance": transState.totalBalance,
              "totalPeopleDebits": transState.totalPeopleDebits,
            },
          ],
        );
        break;
      case 'edit':
        log("the action is to edit transaction");
        break;
      case 'exit_app':
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Command not recognized / لم يتم التعرف على الأمر"),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text("AI Voice Actions"),
        actions: [
          // Language selector dropdown in top right corner
          DropdownButton<String>(
            value: _selectedLocale,
            dropdownColor: Colors.blueGrey,
            icon: Icon(Icons.language, color: Colors.white),
            underline: SizedBox(),
            items: [
              DropdownMenuItem(
                value: 'en-US',
                child: Text(
                  "🇺🇸 English",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              DropdownMenuItem(
                value: 'ar-SA',
                child: Text(
                  "🇸🇦 العربية",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
            onChanged: (String? newLocale) {
              if (newLocale != null) {
                setState(() {
                  _selectedLocale = newLocale;
                  _spokenText = newLocale == 'ar-SA'
                      ? "اضغط مطولاً على الزر وتحدث..."
                      : "Press and hold the button to speak...";
                });
              }
            },
          ),
          SizedBox(width: 15),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _spokenText,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                textDirection: _selectedLocale == 'ar-SA'
                    ? TextDirection.rtl
                    : TextDirection.ltr,
              ),
            ),
            SizedBox(height: 40),
            GestureDetector(
              onLongPressStart: (_) async {
                log("start recording");
                setState(() {
                  _isHoldingButton = true;
                  _spokenText = _selectedLocale == 'ar-SA'
                      ? "جاري الاستماع..."
                      : "Listening...";
                  _isLoading = false;
                });
                log("111");

                final appAction = await _voiceService.listenAndProcessHold(
                  localeId: _selectedLocale,
                  onResultText: (text) => setState(() => _spokenText = text),
                  onProcessingAI: () {
                    setState(() {
                      _isLoading = true;
                    });
                    showLoadingDialog(context, _selectedLocale);
                  },
                );
                log("222");

                setState(() {
                  _isLoading = false;
                });

                if (appAction != null) {
                  _executeAction(appAction);
                }
              },
              onLongPressEnd: (_) async {
                log("recording stoped");

                setState(() {
                  _isHoldingButton = false;
                });

                await _voiceService.stopListeningAndSubmit();
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 150),
                padding: EdgeInsets.all(_isHoldingButton ? 24 : 20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isHoldingButton
                      ? Colors.red
                      : (_selectedLocale == 'ar-SA'
                            ? Colors.green
                            : Colors.orange),
                  boxShadow: [
                    if (_isHoldingButton)
                      BoxShadow(
                        color: Colors.red.withOpacity(0.4),
                        blurRadius: 15,
                        spreadRadius: 5,
                      ),
                  ],
                ),
                child: Icon(
                  _isHoldingButton ? Icons.mic : Icons.mic_none,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

showLoadingDialog(BuildContext context, String _selectedLocale) {
  showDialog(
    context: context,
    builder: (context) => Material(
      color: Colors.transparent,
      child: Center(
        child: Column(
          children: [
            SizedBox(height: 150.h),
            Spacer(),

            Text(
              _selectedLocale == 'ar-SA'
                  ? "يرجى الأنتظار ريثما يتم تحليل الصوت..."
                  : "please wait until we analyze your record...",
              style: TextStyle(fontSize: 20),
            ),
            Spacer(),

            CircularProgressIndicator(),
            Spacer(),
          ],
        ),
      ),
    ),
  );
}
