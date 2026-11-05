import 'package:flutter/material.dart';
import 'package:wallet/core/database/app_database.dart';
import 'package:wallet/core/di/injection.dart';
import 'package:wallet/features/home/presentation/widgets/restart_widget.dart';

Future<void> performFullAppReset(BuildContext context) async {
  try {
    // 1. Close and delete the Drift database safely
    await closeAndDeleteDatabase();

    // 2. Reset the GetIt container completely (disposes all singletons/factories)
    await sl.reset();

    // 3. Re-initialize all dependencies from scratch (creates a clean AppDatabase instance)
    await initDependencies();

    // 4. Force Flutter to rebuild the entire Widget tree with clean states
    if (context.mounted) {
      RestartWidget.restartApp(context);
    }
  } catch (e) {
    print("Error during app reset: $e");
  }
}
