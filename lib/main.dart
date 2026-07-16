import 'package:flutter/material.dart';

import 'app/app_bootstrap.dart';
import 'app/app_settings_controller.dart';
import 'app/mother_word_app.dart';

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
  late final Future<AppSettingsController> _bootstrap = bootstrapApp();

  @override
  Widget build(BuildContext context) => FutureBuilder<AppSettingsController>(
    future: _bootstrap,
    builder: (context, snapshot) {
      if (snapshot.hasData) return MotherWordApp(controller: snapshot.requireData);
      if (snapshot.hasError) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            body: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    WidgetsBinding.instance.platformDispatcher.locale.languageCode == 'ja'
                        ? 'アプリのデータを読み込めませんでした。'
                        : 'The app data could not be loaded.',
                  ),
                ),
              ),
            ),
          ),
        );
      }
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    },
  );
}
