import 'dart:io';
import 'package:path/path.dart' as p;

class FluxyCloud {
  static const String _rs = '\x1B[0m';
  static const String _b = '\x1B[1m';
  static const String _g = '\x1B[32m';
  static const String _c = '\x1B[36m';
  static const String _r = '\x1B[31m';

  static void _info(String msg) => print('$_c$_b[INFO]$_rs $msg');
  static void _success(String msg) => print('$_g$_b[DONE]$_rs $msg');
  static void _error(String msg) => print('$_r$_b[FAIL]$_rs $msg');

  static Future<void> handle(List<String> args) async {
    _info('Configuring Fluxy Cloud CI/CD Pipeline...');

    final githubDir = Directory('.github/workflows');
    if (!githubDir.existsSync()) {
      githubDir.createSync(recursive: true);
    }

    final workflowFile = File(p.join(githubDir.path, 'fluxy_deploy.yml'));
    
    workflowFile.writeAsStringSync('''
name: Fluxy Cloud Deployment

on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main

jobs:
  build_and_deploy:
    runs-on: ubuntu-latest
    
    steps:
      - name: ⬇️ Checkout Repository
        uses: actions/checkout@v3

      - name: ⚙️ Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: 'stable'

      - name: 📦 Install Dependencies
        run: flutter pub get

      - name: 🧪 Check Integrity
        run: |
          dart format --output=none --set-exit-if-changed .
          flutter analyze --no-fatal-infos --no-fatal-warnings
          flutter test

      - name: 🏗️ Build Application (Web)
        run: flutter build web --release

      - name: 🚀 Deploy to Fluxy Cloud (Placeholder)
        run: echo "Cloud deployment orchestrated via Fluxy!"
''');

    _success('GitHub Actions Workflow created at .github/workflows/fluxy_deploy.yml');
    _info('Commit and push to trigger automated deployments!');
  }
}
