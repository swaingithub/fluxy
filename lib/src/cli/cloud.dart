import 'dart:io';
import 'package:path/path.dart' as p;

class FluxyCloud {
  static Future<void> handle(List<String> args) async {
    if (args.isEmpty) {
      print('Usage: fluxy cloud <command> [args]');
      print('Commands:');
      print('  build android   Setup GitHub Actions for Android Build');
      print('  build ios       Setup GitHub Actions for iOS Build');
      print('  deploy          Setup GitHub Actions for Play Store/TestFlight');
      return;
    }

    final command = args.first;
    final rest = args.skip(1).toList();

    switch (command) {
      case 'build':
        if (rest.isEmpty) {
          print('Usage: fluxy cloud build <android|ios>');
          return;
        }
        await _scaffoldBuild(rest.first);
        break;
      case 'deploy':
        await _scaffoldDeploy();
        break;
      default:
        print('Unknown cloud command: $command');
    }
  }

  static Future<void> _scaffoldBuild(String target) async {
    final workflowsDir = Directory('.github/workflows');
    if (!workflowsDir.existsSync()) {
      workflowsDir.createSync(recursive: true);
      print('📂 Created .github/workflows directory');
    }

    if (target == 'android') {
      final file = File(p.join(workflowsDir.path, 'fluxy_android_build.yml'));
      file.writeAsStringSync(_androidTemplate);
      print('✅ Generated fluxy_android_build.yml');
      print('👉 Commit and push to trigger your first Android Cloud Build!');
    } else if (target == 'ios') {
      final file = File(p.join(workflowsDir.path, 'fluxy_ios_build.yml'));
      file.writeAsStringSync(_iosTemplate);
      print('✅ Generated fluxy_ios_build.yml');
      print('👉 Commit and push to trigger your first iOS Cloud Build!');
    } else {
      print('Unsupported build target: $target');
    }
  }

  static Future<void> _scaffoldDeploy() async {
    final workflowsDir = Directory('.github/workflows');
    if (!workflowsDir.existsSync()) {
      workflowsDir.createSync(recursive: true);
    }

    final file = File(p.join(workflowsDir.path, 'fluxy_deploy.yml'));
    file.writeAsStringSync(_deployTemplate);
    print('✅ Generated fluxy_deploy.yml');
    print('👉 Use "workflow_dispatch" in GitHub to trigger deployment.');
  }

  static const String _androidTemplate = '''
name: Fluxy Android Build

on:
  push:
    branches: [ "main" ]
  workflow_dispatch:

jobs:
  build:
    name: Build APK
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-java@v3
        with:
          distribution: 'zulu'
          java-version: '17'
      - uses: subosito/flutter-action@v2
        with:
          channel: 'stable'
      
      - run: flutter pub get
      - run: flutter build apk --release
      
      - uses: actions/upload-artifact@v3
        with:
          name: release-apk
          path: build/app/outputs/flutter-apk/app-release.apk
''';

  static const String _iosTemplate = '''
name: Fluxy iOS Build

on:
  workflow_dispatch:

jobs:
  build:
    name: Build IPA
    runs-on: macos-latest

    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          channel: 'stable'
      
      - run: flutter pub get
      - run: flutter build ios --release --no-codesign
      
      - name: Compress App
        run: |
          cd build/ios/iphoneos
          mkdir Payload
          cp -r Runner.app Payload
          zip -r FluxyApp.ipa Payload
          
      - uses: actions/upload-artifact@v3
        with:
          name: release-ipa
          path: build/ios/iphoneos/FluxyApp.ipa
''';

  static const String _deployTemplate = '''
name: Fluxy Deploy

on:
  workflow_dispatch:
    inputs:
      track:
        description: 'Track (production/beta/alpha)'
        required: true
        default: 'alpha'

jobs:
  fastlane-deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.0'
          bundler-cache: true
      
      - name: Deploy to Play Store
        run: |
          echo "Simulating Fastlane Deployment to \${{ inputs.track }}..."
          # bundle exec fastlane android deploy track:\${{ inputs.track }}
''';
}
