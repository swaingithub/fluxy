// ignore_for_file: avoid_print
import 'dart:io';

void main(List<String> args) async {
  if (args.isEmpty) {
    _printUsage();
    return;
  }

  final command = args[0];

  switch (command) {
    case 'init':
      await _handleInit();
      break;
    case 'gen:page':
      if (args.length < 2) {
        print("❌ Please provide a page name: fluxy gen:page Home");
        return;
      }
      await _handleGenPage(args[1]);
      break;
    case 'gen:controller':
      if (args.length < 2) {
        print("❌ Please provide a controller name: fluxy gen:controller Auth");
        return;
      }
      await _handleGenController(args[1]);
      break;
    default:
      print("❌ Unknown command: $command");
      _printUsage();
  }
}

void _printUsage() {
  print("🚀 Fluxy Framework CLI");
  print("Usage: dart run fluxy <command> [arguments]");
  print("");
  print("Commands:");
  print("  init              Initialize Fluxy project structure");
  print("  gen:page <name>   Generate a new reactive page and route");
  print("  gen:controller <name>  Generate a new reactive controller");
}

Future<void> _handleInit() async {
  print("🏗️ Initializing Fluxy Project Structure...");
  
  final folders = [
    'lib/app/modules',
    'lib/app/data/services',
    'lib/app/data/models',
    'lib/app/routes',
    'lib/app/core/theme',
  ];

  for (var folder in folders) {
    await Directory(folder).create(recursive: true);
    print("  ✅ Created $folder");
  }

  // Create standard routes file
  final routesFile = File('lib/app/routes/app_routes.dart');
  if (!await routesFile.exists()) {
    await routesFile.writeAsString("""
import 'package:fluxy/fluxy.dart';
import '../modules/home/home_page.dart';

class AppPages {
  static final routes = [
    FxRoute(
      path: '/',
      builder: (p, a) => const HomePage(),
    ),
  ];
}
""");
  }

  print("\n🎉 Fluxy Project Ready! Next step: Define your routes in lib/app/routes/app_routes.dart");
}

Future<void> _handleGenPage(String name) async {
  final className = name[0].toUpperCase() + name.substring(1);
  final fileName = name.toLowerCase();
  final dirPath = 'lib/app/modules/$fileName';

  await Directory(dirPath).create(recursive: true);

  // Generate Page
  final pageFile = File('$dirPath/${fileName}_page.dart');
  await pageFile.writeAsString("""
import 'package:flutter/material.dart';
import 'package:fluxy/fluxy.dart';
import '${fileName}_controller.dart';

class ${className}Page extends StatelessWidget {
  const ${className}Page({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.find<${className}Controller>();

    return Scaffold(
      appBar: AppBar(title: const Text("$className Page")),
      body: Center(
        child: Fx.text("$className Module is working!"),
      ),
    );
  }
}
""");

  // Generate Controller
  await _handleGenController(name, path: dirPath);

  print("✅ Generated Page and Controller for $className in $dirPath");
  print("👉 Don't forget to register it in AppPages!");
}

Future<void> _handleGenController(String name, {String? path}) async {
  final className = name[0].toUpperCase() + name.substring(1);
  final fileName = name.toLowerCase();
  final dirPath = path ?? 'lib/app/data/services';

  await Directory(dirPath).create(recursive: true);

  final controllerFile = File('$dirPath/${fileName}_controller.dart');
  await controllerFile.writeAsString("""
import 'package:fluxy/fluxy.dart';

class ${className}Controller extends FluxyController {
  final count = 0.obs;

  @override
  void onInit() {
    super.onInit();
    print("${className}Controller initialized");
  }

  void increment() => count.value++;
}
""");

  if (path == null) {
    print("✅ Generated Controller: $dirPath/${fileName}_controller.dart");
  }
}
