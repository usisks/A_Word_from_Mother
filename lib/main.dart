import 'package:flutter/material.dart';

import 'app/app_bootstrap.dart';
import 'app/app_settings_controller.dart';
import 'app/mother_word_app.dart';
import 'core/diagnostics.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const _BootstrapHost());
}

class _BootstrapHost extends StatefulWidget {
  const _BootstrapHost();
  @override
  State<_BootstrapHost> createState() => _BootstrapHostState();
}

class _BootstrapHostState extends State<_BootstrapHost> {
  late Future<AppSettingsController> _bootstrap;
  var _attempt = 0;

  @override
  void initState() {
    super.initState();
    _bootstrap = _runBootstrap();
  }

  Future<AppSettingsController> _runBootstrap() async {
    try {
      return await bootstrapApp();
    } on AppBootstrapException {
      rethrow;
    } on Object catch (error, stackTrace) {
      logFailure('startup_failed', error, stackTrace);
      rethrow;
    }
  }

  void _retry() {
    setState(() {
      _attempt++;
      _bootstrap = _runBootstrap();
    });
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<AppSettingsController>(
    key: ValueKey(_attempt),
    future: _bootstrap,
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        return MotherWordApp(controller: snapshot.requireData);
      }
      if (snapshot.hasError) {
        final error = snapshot.error;
        final code = error is AppBootstrapException
            ? error.code
            : 'startup_failed';
        return FatalStartupApp(errorCode: code, onRetry: _retry);
      }
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    },
  );
}

class FatalStartupApp extends StatelessWidget {
  const FatalStartupApp({
    required this.errorCode,
    required this.onRetry,
    super.key,
  });

  final String errorCode;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final isJapanese =
        WidgetsBinding.instance.platformDispatcher.locale.languageCode == 'ja';
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isJapanese
                        ? 'アプリのデータを読み込めませんでした。'
                        : 'The app data could not be loaded.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text('${isJapanese ? 'エラーコード' : 'Error code'}: $errorCode'),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: onRetry,
                    child: Text(isJapanese ? 'もう一度試す' : 'Try again'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
