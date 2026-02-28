import 'dart:io';
import 'package:args/args.dart';
import 'package:path/path.dart' as p;
import 'package:fluxy/src/cloud.dart';


const String version = '1.0.1';

const String _rs = '\x1B[0m';
const String _b = '\x1B[1m';
const String _g = '\x1B[32m';
const String _bl = '\x1B[34m';
const String _c = '\x1B[36m';
const String _r = '\x1B[31m';

// Standard Log Styles
void _info(String msg) => print('$_c$_b[INFO]$_rs $msg');
void _step(String tag, String msg) => print('$_bl$_b[$tag]$_rs $msg');
void _success(String msg) => print('$_g$_b[DONE]$_rs $msg');
void _error(String msg) => print('$_r$_b[FAIL]$_rs $msg');

void _printBanner() {
  print('''
$_bl$_b
   _______   __   __  __  __  __   __ 
  |  _____| |  | |  | \\ \\/ / |  | |  |
  |  |___   |  | |  |  \\  /  |  |_|  |
  |   ___|  |  | |  |  /  \\  \\___   / 
  |  |      |  |_|  | / /\\ \\     |  |  
  |__|      \\_______|/_/  \\_\\    |__|  
                                      
$_rs$_b    FLUXY ARCHITECTURAL AUTHORITY v$version$_rs
''');
}

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addCommand('init')
    ..addCommand('generate')
    ..addCommand('g')
    ..addCommand('run')
    ..addCommand('doctor')
    ..addCommand('build')
    ..addCommand('deploy')
    ..addCommand('cloud')
    ..addCommand('serve')
    ..addCommand('module')
    ..addCommand('m')
    ..addCommand('melos');

  parser.addFlag('help', abbr: 'h', negatable: false);
  parser.addFlag('version', abbr: 'v', negatable: false);

  ArgResults argResults;
  try {
    argResults = parser.parse(arguments);
  } catch (e) {
    _error('Invalid command arguments: $e');
    printUsage(parser);
    exit(1);
  }

  if (argResults['help']) {
    _printBanner();
    printUsage(parser);
    return;
  }

  if (argResults['version']) {
    print('Fluxy CLI v$version');
    return;
  }

  final command = argResults.command;
  if (command == null) {
    _printBanner();
    printUsage(parser);
    return;
  }

  // Industrial Command Router
  try {
    switch (command.name) {
      case 'init':
        await _handleInit(command.rest);
        break;
      case 'generate':
      case 'g':
        await _handleGenerate(command.rest);
        break;
      case 'run':
        await _handleRun(command.rest);
        break;
      case 'doctor':
        await _handleDoctor();
        break;
      case 'build':
        await _handleBuild(command.rest);
        break;
      case 'deploy':
        await _handleDeploy();
        break;
      case 'cloud':
        await FluxyCloud.handle(command.rest);
        break;
      case 'serve':
        await _handleServe(command);
        break;
      case 'module':
      case 'm':
        await _handleModule(command.rest);
        break;
      case 'melos':
        await _handleMelos(command.rest);
        break;
      default:
        _error('Unknown command: ${command.name}');
        printUsage(parser);
    }
  } catch (e, stack) {
    _error('Architectural breakdown: $e');
    if (argResults['help'] == true) print(stack);
    exit(1);
  }
}

void printUsage(ArgParser parser) {
  print('Fluxy CLI - The Ultimate Flutter Framework Tool\n');
  print('Usage: fluxy <command> [arguments]\n');
  print('Commands:');
  print(
    '  init <name>      Scaffold a complete Fluxy application (Expo-style).',
  );
  print(
    '  generate <feat>  (g) Create a new feature domain (login, feed, default).',
  );
  print('  generate plugin <name>  Create a new Fluxy plugin scaffold.');
  print('  generate layout <name>  Create a responsive layout template.');
  print('  generate model <name>  Create a reactive data model.');
  print('  run              Launch the application.');
  print('  serve            Start a local OTA development server.');
  print('  build            Compile the application.');
  print('  cloud            Configure GitHub Actions CI/CD.');
  print('  module add <pkg> Add and register a Fluxy platform module.');
  print('  module list      List all available platform modules.');
  print('  melos <args>     Run melos commands within the workspace.');
}

Future<void> _handleInit(List<String> args) async {
  if (args.isEmpty) {
    _error('Project name required. Usage: fluxy init <project_name>');
    exit(1);
  }

  _printBanner();
  final projectName = args.first;
  _step(
    'INIT',
    'Scaffolding Industrial Fluxy Application: $_b$projectName$_rs...',
  );

  final process = await Process.start(
    'flutter',
    ['create', projectName],
    runInShell: true,
    mode: ProcessStartMode.inheritStdio,
  );
  final exitCode = await process.exitCode;

  if (exitCode != 0) {
    _error('Flutter project creation failed.');
    exit(1);
  }

  final projectDir = Directory(projectName);
  final libDir = Directory(p.join(projectDir.path, 'lib'));
  final testDir = Directory(p.join(projectDir.path, 'test'));

  _step('ARCH', 'Aligning Structural Consistency (core/features/registry)...');
  if (libDir.existsSync()) libDir.deleteSync(recursive: true);
  libDir.createSync();

  if (testDir.existsSync()) testDir.deleteSync(recursive: true);
  testDir.createSync();

  // Create Industrial Directory Structure
  final coreDir = Directory(p.join(libDir.path, 'core'))..createSync();
  Directory(p.join(libDir.path, 'features')).createSync();
  Directory(p.join(coreDir.path, 'theme')).createSync();
  Directory(p.join(coreDir.path, 'registry')).createSync();

  _step('CORE', 'Injecting Fluxy Framework into pubspec...');
  await Process.run('flutter', ['pub', 'add', 'fluxy'], workingDirectory: projectDir.path, runInShell: true);

  // Write Templates
  File(p.join(libDir.path, 'main.dart')).writeAsStringSync(_fluxyMainTemplate);
  File(p.join(coreDir.path, 'theme', 'app_theme.dart')).writeAsStringSync(_coreThemeTemplate);
  File(
    p.join(testDir.path, 'fluxy_boot_test.dart'),
  ).writeAsStringSync(_fluxyTestTemplate);
  
  _step('SYNC', 'Bootstrapping local plugin registry...');
  // Force a registry regeneration in the new project
  final current = Directory.current.path;
  Directory.current = projectName;
  await _regeneratePluginRegistry();
  Directory.current = current;

  _step('FEAT', 'Building industrial-standard home feature...');
  await _createFeature(projectDir.path, 'home');

  _success('Fluxy project "$_b$projectName$_rs" is ready for production.');
  print('$_c$_b[NEXT]$_rs cd $projectName && fluxy run');
}

Future<void> _handleGenerate(List<String> args) async {
  if (args.isEmpty) {
    _error('Resource type required (feature|plugin|layout|model|controller).');
    return;
  }
  final name = args.first.toLowerCase();
  
  if (name == 'plugin') {
    if (args.length < 2) {
      _error('Plugin name required. Usage: fluxy g plugin <name>');
      return;
    }
    await _createPlugin(args[1].toLowerCase());
    return;
  }
  
  if (name == 'layout') {
    if (args.length < 2) {
      _error('Layout name required. Usage: fluxy g layout <name>');
      return;
    }
    await _createLayout(args[1].toLowerCase());
    return;
  }

  if (name == 'model') {
    if (args.length < 2) {
      _error('Model name required. Usage: fluxy g model <name>');
      return;
    }
    await _createModel(args[1].toLowerCase());
    return;
  }

  if (name == 'controller') {
    if (args.length < 2) {
      _error('Controller name required. Usage: fluxy g controller <name>');
      return;
    }
    await _createController(args[1].toLowerCase());
    return;
  }

  // Default to feature generation
  final type = args.length > 1 ? args[1].toLowerCase() : 'default';

  _info(
    'Generating industrial ${type == "default" ? "" : "$type "}feature: $name...',
  );
  await _createFeature('.', name, type: type);
}

Future<void> _createPlugin(String name) async {
  final pluginDir = Directory(p.join('lib', 'plugins'))..createSync(recursive: true);
  final camel = name[0].toUpperCase() + name.substring(1);
  final fileName = '${name}_plugin.dart';

  File(p.join(pluginDir.path, fileName)).writeAsStringSync('''
import 'package:fluxy/fluxy.dart';

/// ${camel}Plugin - Extends Fluxy lifecycle
class ${camel}Plugin extends FluxyPlugin {
  @override
  String get name => "${camel}Plugin";

  @override
  Future<void> onRegister() async {
    // Register dependencies, initialize loggers, etc.
    print("[PLUGIN] ${camel}Plugin Registered");
  }

  @override
  void onAppReady() {
    // Called after Fluxy.init() finishes
    print("[INIT] ${camel}Plugin Ready");
  }
}
''');

  _success('Generated plugin: ${camel}Plugin at lib/plugins/$fileName');
  _info('To use: Fluxy.register(${camel}Plugin()); in main.dart');
}

Future<void> _createFeature(String path, String name, {String type = 'default'}) async {
  final featDir = Directory(p.join(path, 'lib', 'features', name))..createSync(recursive: true);
  final camel = name[0].toUpperCase() + name.substring(1);

  if (type == 'login') {
    _createLoginBlueprint(featDir, name, camel);
  } else if (type == 'feed') {
    _createFeedBlueprint(featDir, name, camel);
  } else {
    _createDefaultBlueprint(featDir, name, camel);
  }

  _success('Generated $type feature: $name at lib/features/$name');
}

void _createLoginBlueprint(Directory dir, String name, String camel) {
  // 1. Repository
  File(p.join(dir.path, '$name.repository.dart')).writeAsStringSync('''
import 'package:fluxy/fluxy.dart';

class ${camel}Repository extends FluxRepository<bool> {
  @override
  Future<bool> fetchRemote() async {
    // Simulate auth check
    await Future.delayed(const Duration(seconds: 1));
    return true; 
  }

  Future<void> login(String email, String password) async {
    // Zero-dependency FluxyHttp!
    await Fluxy.http.post('/auth/login', body: {'email': email, 'password': password});
  }

  @override
  Future<bool> fetchLocal() async => false;
  @override
  Future<void> saveLocal(bool data) async {}
}
''');

  // 2. Controller
  File(p.join(dir.path, '$name.controller.dart')).writeAsStringSync('''
import 'package:fluxy/fluxy.dart';
import '$name.repository.dart';

class ${camel}Controller extends FluxController {
  final repo = ${camel}Repository();
  
  final email = flux("");
  final password = flux("");
  final isLoading = flux(false);

  Future<void> submit() async {
    if (email.value.isEmpty || password.value.isEmpty) {
      Fx.toast.error("Please fill all fields");
      return;
    }

    isLoading.value = true;
    try {
      await repo.login(email.value, password.value);
      Fx.toast.success("Welcome back!");
      Fluxy.offAll('/home');
    } catch (e, stack) {
      if (e is FxHttpException) {
        // Report to global pipeline for safety
        FluxyError.report(e, stack);
        rethrow;
      }
      final error = FxHttpException(message: e.toString());
      FluxyError.report(error, stack);
      throw error;
    } finally {
      isLoading.value = false;
    }
  }
}
''');

  // 3. View
  File(p.join(dir.path, '$name.view.dart')).writeAsStringSync('''
import 'package:flutter/material.dart';
import 'package:fluxy/fluxy.dart';
import '$name.controller.dart';

class ${camel}View extends StatelessWidget {
  const ${camel}View({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Fluxy.find<${camel}Controller>();

    return Scaffold(
      body: Fx.center(
        child: Fx.container(
          maxWidth: 400,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Fx.text('LOGIN').font.xl3().bold().letterSpacing(4),
              Fx.text('Enter your credentials').muted(),
              Fx.gap(40),
              
              Fx.input(
                signal: controller.email, 
                placeholder: 'Email',
                icon: Icons.email_outlined,
              ),
              Fx.gap(16),
              Fx.password(
                signal: controller.password,
                placeholder: 'Password',
              ),
              Fx.gap(24),
              
              Fx(() => Fx.button(
                controller.isLoading.value ? 'PROCESSING...' : 'SIGN IN',
                onTap: controller.submit,
              ).w(double.infinity).background(Colors.black)),
              
              Fx.gap(16),
              Fx.textButton('Forgot Password?', onTap: () {}),
            ],
          ).p(24),
        ),
      ),
    );
  }
}
''');

  // 4. Routes
  _createRoutesFile(dir, name, camel);
}

void _createFeedBlueprint(Directory dir, String name, String camel) {
  // 1. Repository
  File(p.join(dir.path, '$name.repository.dart')).writeAsStringSync('''
import 'package:fluxy/fluxy.dart';

class ${camel}Repository extends FluxRepository<List<String>> {
  @override
  Future<List<String>> fetchRemote() async {
    final response = await Fluxy.http.get('/posts');
    return List<String>.from(response.data.map((e) => e['title']));
  }

  @override
  Future<List<String>> fetchLocal() async => [];
  @override
  Future<void> saveLocal(List<String> data) async {}
}
''');

  // 2. Controller
  File(p.join(dir.path, '$name.controller.dart')).writeAsStringSync('''
import 'package:fluxy/fluxy.dart';
import '$name.repository.dart';

class ${camel}Controller extends FluxController {
  final repo = ${camel}Repository();
  final items = flux(<String>[]);
  final isLoading = flux(true);

  @override
  void onInit() async {
    super.onInit();
    await refresh();
  }

  Future<void> refresh() async {
    isLoading.value = true;
    items.value = await repo.sync();
    isLoading.value = false;
  }
}
''');

  // 3. View
  File(p.join(dir.path, '$name.view.dart')).writeAsStringSync('''
import 'package:flutter/material.dart';
import 'package:fluxy/fluxy.dart';
import '$name.controller.dart';

class ${camel}View extends StatelessWidget {
  const ${camel}View({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Fluxy.find<${camel}Controller>();

    return Scaffold(
      appBar: AppBar(title: Fx.text('$camel').bold()),
      body: Fx(() {
        if (controller.isLoading.value) {
          return Fx.list(
            itemCount: 5,
            itemBuilder: (_, __) => Fx.loader.shimmer(height: 80).m(16),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refresh,
          child: Fx.list(
            itemCount: controller.items.value.length,
            itemBuilder: (context, index) {
              final item = controller.items.value[index];
              return Fx.box(
                style: FxStyle(
                  padding: const EdgeInsets.all(16), 
                  borderBottom: BorderSide(color: Colors.grey.shade200),
                ),
                child: Fx.text(item).bold(),
              );
            },
          ),
        );
      }),
    );
  }
}
''');

  // 4. Routes
  _createRoutesFile(dir, name, camel);
}

void _createDefaultBlueprint(Directory dir, String name, String camel) {
  // 1. Repository
  File(p.join(dir.path, '$name.repository.dart')).writeAsStringSync('''
import 'package:fluxy/fluxy.dart';

class ${camel}Repository extends FluxRepository<String> {
  @override
  Future<String> fetchRemote() async {
    final response = await Fluxy.http.get('/data');
    return response.data['message'] ?? "Fluxy Engine Active";
  }

  @override
  Future<String> fetchLocal() async => "Offline Cache Ready";
  
  @override
  Future<void> saveLocal(String data) async {}
}
''');

  // 2. Controller
  File(p.join(dir.path, '$name.controller.dart')).writeAsStringSync('''
import 'package:fluxy/fluxy.dart';
import '$name.repository.dart';

class ${camel}Controller extends FluxController {
  final repo = ${camel}Repository();
  final count = flux(0, key: 'counter_$name');
  final status = flux("Booting...");

  @override
  void onInit() async {
    super.onInit();
    status.value = await repo.sync();
  }
  
  void increment() => count.value++;
}
''');

  // 3. View
  File(p.join(dir.path, '$name.view.dart')).writeAsStringSync('''
import 'package:flutter/material.dart';
import 'package:fluxy/fluxy.dart';
import '$name.controller.dart';

class ${camel}View extends StatelessWidget {
  const ${camel}View({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Fluxy.find<${camel}Controller>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Fx.text('FLUXY').font.xl4().bold().letterSpacing(8).color(Colors.blue),
            Fx.text('FRAMEWORK').font.sm().letterSpacing(4).muted(),
            Fx.gap(60),
            Fx.text('$camel Feature Scaffolding').font.lg().bold(),
            Fx.gap(10),
            Fx(() => Fx.text(controller.status.value)).muted().italic(),
            Fx.gap(40),
            Fx(() => Fx.text('\${controller.count.value}')).font.xl4().bold().animate(fade: 0),
            Fx.gap(20),
            Fx.button('INCREMENT', onTap: controller.increment)
              .w(160).rounded(0).background(Colors.black),
            Fx.gap(100),
            Fx.text('Structural Authority for Flutter').font.xs().muted().letterSpacing(1),
          ],
        ),
      ),
    );
  }
}
''');

  // 4. Routes
  _createRoutesFile(dir, name, camel);
}

void _createRoutesFile(Directory dir, String name, String camel) {
  File(p.join(dir.path, '$name.routes.dart')).writeAsStringSync('''
import 'package:fluxy/fluxy.dart';
import '$name.view.dart';
import '$name.controller.dart';

final ${name}Routes = [
  FxRoute(
    path: '/$name',
    controller: () => ${camel}Controller(),
    builder: (params, args) => const ${camel}View(),
  ),
];
''');
}

Future<void> _handleServe(ArgResults command) async {
  final port = int.tryParse(command['port'] ?? '8080') ?? 8080;
  final server = await HttpServer.bind(InternetAddress.anyIPv4, port);
  _step(
    'OTA',
    'Fluxy Industrial Live Server running at http://localhost:$port',
  );
  _info('Watching ./ota directory for structural updates...');

  final otaDir = Directory('ota');
  if (!otaDir.existsSync()) {
    otaDir.createSync();
    File(p.join(otaDir.path, 'manifest.json')).writeAsStringSync('''
{
  "version": 1,
  "assets": {
    "home.json": "http://localhost:$port/home.json"
  }
}
''');
    File(p.join(otaDir.path, 'home.json')).writeAsStringSync('''
{
  "type": "box",
  "style": { "padding": 20, "backgroundColor": "#ffffff" },
  "children": [
    { "type": "text", "data": "Hello from Fluxy Live OTA!", "style": { "fontSize": 20, "fontWeight": "bold" } },
    { "type": "text", "data": "Try changing the JSON and refresh." }
  ]
}
''');
  }

  await for (HttpRequest request in server) {
    final path = request.uri.path == '/' ? '/manifest.json' : request.uri.path;
    final file = File(p.join(otaDir.path, path.substring(1)));

    if (await file.exists()) {
      request.response.headers.contentType = ContentType.json;
      request.response.headers.add('Access-Control-Allow-Origin', '*');
      await file.openRead().pipe(request.response);
    } else {
      request.response.statusCode = HttpStatus.notFound;
      request.response.write('Asset Not Found: $path');
      await request.response.close();
    }
  }
}

Future<void> _handleRun(List<String> args) async {
  _info('Syncing architectural integrity...');
  await _regeneratePluginRegistry();

  _step('RUN', 'Launching Industrial Fluxy Engine...');
  await Process.start('flutter', ['run', ...args], mode: ProcessStartMode.inheritStdio, runInShell: true);
}

Future<void> _handleDoctor() async {
  _printBanner();
  _step('DOCTOR', 'Inspecting Fluxy Architectural Health...');
  
  _info('Checking Modular Integration...');
  await _regeneratePluginRegistry();
  
  print('\n$_bl$_b[ENV]$_rs Flutter Environment Status:');
  await Process.start('flutter', ['doctor'], mode: ProcessStartMode.inheritStdio, runInShell: true);
}

Future<void> _handleBuild(List<String> args) async {
  if (args.isEmpty) return;
  await Process.start('flutter', ['build', ...args], mode: ProcessStartMode.inheritStdio, runInShell: true);
}

Future<void> _handleDeploy() async =>
    _info('Cloud deployment orchestration coming in v1.1.0');

const String _fluxyMainTemplate = """
import 'package:flutter/material.dart';
import 'package:fluxy/fluxy.dart';
import 'core/theme/app_theme.dart';
import 'core/registry/fluxy_registry.dart';
import 'features/home/home.routes.dart';

void main() async {
  // 1. Initialize Framework & Stability Policy
  // strictMode: true throws errors on layout violations (perfect for Dev)
  // strictMode: false (Relaxed) auto-fixes violations (perfect for Prod)
  await Fluxy.init(strictMode: false);

  // 2. Boot Modular Plugins (Auto-generated registry)
  registerFluxyPlugins();
  Fluxy.autoRegister();

  // 3. Setup Global Error Pipeline
  Fluxy.onError((error, stack) {
    debugPrint("Fluxy Global Error: \$error");
  });

  runApp(
    Fluxy.debug(
      child: FluxyApp(
        title: 'Fluxy App',
        theme: AppTheme.light,
        initialRoute: homeRoutes.first.path,
        routes: homeRoutes,
      ),
    ),
  );
}
""";

const String _coreThemeTemplate = """
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
  );
}
""";

Future<void> _createLayout(String name) async {
  final layoutDir = Directory(p.join('lib', 'core', 'layouts'))..createSync(recursive: true);
  final camel = name[0].toUpperCase() + name.substring(1);
  final fileName = '${name}_layout.dart';

  File(p.join(layoutDir.path, fileName)).writeAsStringSync('''
import 'package:flutter/material.dart';
import 'package:fluxy/fluxy.dart';

class ${camel}Layout extends StatelessWidget {
  final Widget child;
  const ${camel}Layout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Fx.dashboard(
      sidebar: _buildSidebar(),
      navbar: _buildNavbar(),
      body: child,
    );
  }

  Widget _buildNavbar() => Fx.navbar(
    logo: Fx.text('${camel.toUpperCase()}').font.lg().bold(),
    actions: [
      Fx.icon(Icons.notifications_none_outlined, onTap: () {}),
      Fx.icon(Icons.account_circle_outlined, onTap: () {}),
    ],
  );

  Widget _buildSidebar() => Fx.sidebar(
    items: [
      Fx.text('Dashboard').font.sm().p(12),
      Fx.text('Analytics').font.sm().p(12),
      Fx.text('Settings').font.sm().p(12),
    ],
  );
}
''');

  _success('Generated layout: ${camel}Layout at lib/core/layouts/$fileName');
}

Future<void> _createModel(String name) async {
  final modelDir = Directory(p.join('lib', 'core', 'models'))..createSync(recursive: true);
  final camel = name[0].toUpperCase() + name.substring(1);
  final fileName = '$name.dart';

  File(p.join(modelDir.path, fileName)).writeAsStringSync('''
import 'package:fluxy/fluxy.dart';

class $camel {
  final id = flux(0);
  final title = flux("");
  final createdAt = DateTime.now();

  $camel({int? id, String? title}) {
    if (id != null) this.id.value = id;
    if (title != null) this.title.value = title;
  }

  Map<String, dynamic> toJson() => {
    'id': id.value,
    'title': title.value,
  };

  static $camel fromJson(Map<String, dynamic> json) {
    return $camel(
      id: json['id'],
      title: json['title'],
    );
  }
}
''');

  _success('Generated model: $camel at lib/core/models/$fileName');
}

Future<void> _createController(String name) async {
  final controllerDir = Directory(p.join('lib', 'core', 'controllers'))..createSync(recursive: true);
  final camel = name[0].toUpperCase() + name.substring(1);
  final fileName = '$name.controller.dart';

  File(p.join(controllerDir.path, fileName)).writeAsStringSync('''
import 'package:fluxy/fluxy.dart';

class ${camel}Controller extends FluxController {
  final isLoading = flux(false);

  @override
  void onInit() {
    super.onInit();
    print("${camel}Controller Initialized");
  }
}
''');

  _success(
    'Generated controller: ${camel}Controller at lib/core/controllers/$fileName',
  );
}

Future<void> _handleMelos(List<String> args) async {
  _step('MELOS', 'Executing Workspace Command: melos ${args.join(' ')}');
  
  String workDir = Directory.current.path;
  if (Platform.isWindows && workDir.contains(' ')) {
    try {
      final result = await Process.run('cmd', ['/c', 'for %I in (.) do @echo %~sI']);
      if (result.exitCode == 0) {
         workDir = result.stdout.toString().trim();
         _info('Using safe path: $workDir');
      }
    } catch (_) {}
  }

  final process = await Process.start(
    'melos',
    args,
    mode: ProcessStartMode.inheritStdio,
    runInShell: true,
    workingDirectory: workDir,
  );
  
  final exitCode = await process.exitCode;
  if (exitCode != 0) {
    _error('Melos command failed with exit code $exitCode');
    exit(exitCode);
  }
}

Future<void> _handleModule(List<String> args) async {
  if (args.isEmpty) {
    _info('Usage: fluxy module <add|remove|list> [name]');
    return;
  }

  final command = args.first;
  final rest = args.skip(1).toList();

  switch (command) {
    case 'add':
      if (rest.isEmpty) {
        _error('Module name required.');
        return;
      }
      await _addModule(rest.first);
      break;
    case 'remove':
      if (rest.isEmpty) {
        _error('Module name required.');
        return;
      }
      await _removeModule(rest.first);
      break;
    case 'list':
      _listModules();
      break;
    default:
      _error('Unknown module command: $command');
  }
}

const _availablePlugins = {
  'storage': 'FluxyStoragePlugin',
  'analytics': 'FluxyAnalyticsPlugin',
  'permissions': 'FluxyPermissionsPlugin',
  'auth': 'FluxyAuthPlugin',
  'notifications': 'FluxyNotificationsPlugin',
  'ota': 'FluxyOTAPlugin',
  'camera': 'FluxyCameraPlugin',
  'biometric': 'FluxyBiometricPlugin',
  'connectivity': 'FluxyConnectivityPlugin',
  'platform': 'FluxyPlatformPlugin',
  'haptics': 'FluxyHapticsPlugin',
  'logger': 'FluxyLoggerPlugin',
  'device': 'FluxyDevicePlugin',
  'test': 'FluxyTestPlugin',
  'websocket': 'FluxyWebSocketPlugin',
  'sync': 'FluxySyncPlugin',
  'presence': 'FluxyPresencePlugin',
  'bridge': 'FluxyStreamBridgePlugin',
  'geo': 'FluxyGeoPlugin',
};

Future<void> _removeModule(String name) async {
  final moduleName = name.toLowerCase();
  
  _step('CORE', 'Terminating Fluxy Platform Module: $moduleName...');
  
  // 1. Run flutter pub remove
  final packageName = 'fluxy_$moduleName';
  _info('Uninstalling $packageName via flutter pub remove...');
  
  final process = await Process.start(
    'flutter', 
    ['pub', 'remove', packageName], 
    mode: ProcessStartMode.inheritStdio, 
    runInShell: true
  );
  
  final exitCode = await process.exitCode;
  if (exitCode != 0) {
    _error('Failed to remove $packageName.');
    return;
  }
  
  // 2. Regenerate registry
  await _regeneratePluginRegistry();
  
  _success('Module $moduleName removed and registry cleaned successfully.');
}

Future<void> _addModule(String name) async {
  final moduleName = name.toLowerCase();
  if (!_availablePlugins.containsKey(moduleName)) {
    _error(
      'Unknown module: $moduleName. Use "fluxy module list" to see available modules.',
    );
    return;
  }

  _step('CORE', 'Enabling Fluxy Platform Module: $moduleName...');
  
  // 1. Run flutter pub add
  final packageName = 'fluxy_$moduleName';
  _info('Installing $packageName via flutter pub add...');
  
  final process = await Process.start(
    'flutter', 
    ['pub', 'add', packageName], 
    mode: ProcessStartMode.inheritStdio, 
    runInShell: true
  );
  
  final exitCode = await process.exitCode;
  if (exitCode != 0) {
    _error(
      'Failed to install $packageName. Please check your internet connection and pubspec.yaml.',
    );
    return;
  }
  
  // 2. Regenerate registry
  await _regeneratePluginRegistry();
  
  _success('Module $moduleName added and registered successfully.');
  _info(
    'Verify "Fluxy.autoRegister()" or "registerFluxyPlugins()" is called in your main.dart',
  );
}

void _listModules() {
  _step('LIST', 'Available Fluxy Platform Modules:');
  for (var entry in _availablePlugins.entries) {
    print(' $_b- ${entry.key.padRight(15)}$_rs ${_c}(${entry.value})$_rs');
  }
  _info('Use "fluxy module add <name>" to install a module.');
}

Future<void> _regeneratePluginRegistry([String? newPlugin]) async {
  final registryFile = File(
    p.join('lib', 'core', 'registry', 'fluxy_registry.dart'),
  );
  final pubspecFile = File('pubspec.yaml');
  
  Set<String> pluginsToRegister = {};
  if (newPlugin != null) pluginsToRegister.add(newPlugin);
  
  if (pubspecFile.existsSync()) {
    final content = pubspecFile.readAsStringSync();
    // Improved regex to catch fluxy_ deps in any valid YAML format (version, path, git)
    final regExp = RegExp(r'^\s*(fluxy_[a-z_]+)\s*:', multiLine: true);
    final matches = regExp.allMatches(content);
    for (final match in matches) {
      final packageName = match.group(1);
      final pluginKey = packageName?.replaceFirst('fluxy_', '');
      if (pluginKey != null && _availablePlugins.containsKey(pluginKey)) {
        pluginsToRegister.add(pluginKey);
      }
    }
  }

  String imports = "import 'package:fluxy/fluxy.dart';\n";
  String body = 'void registerFluxyPlugins() {\n';

  if (pluginsToRegister.isEmpty) {
    body += '  // No modular plugins detected in pubspec.yaml\n';
  } else {
    for (var p in pluginsToRegister) {
      final className = _availablePlugins[p];
      if (className != null) {
        // Add dynamic import for the plugin package
        imports += "import 'package:fluxy_$p/fluxy_$p.dart';\n";
        
        body += '  try {\n';
        body += '    Fluxy.register($className());\n';
        body += '    debugPrint("[INIT] [Platform] Auto-registered: $className");\n';
        body += '  } catch (e) {\n';
        body += '    debugPrint("[INIT] [Platform] Failed to auto-register $className: \$e");\n';
        body += '  }\n';
      }
    }
  }
  
  body += '}\n';
  
  final fullContent = '''
/// THIS FILE IS AUTO-GENERATED BY THE FLUXY CLI.
/// DO NOT EDIT MANUALLY.

import 'package:flutter/foundation.dart';
$imports

$body
''';

  if (!registryFile.parent.existsSync()) {
    registryFile.parent.createSync(recursive: true);
  }
  
  // Only write if changed to avoid unnecessary rebuilds
  if (!registryFile.existsSync() || registryFile.readAsStringSync() != fullContent) {
    registryFile.writeAsStringSync(fullContent);
    print(
      '[SYNC] Generated lib/core/registry/fluxy_registry.dart (${pluginsToRegister.length} plugins).',
    );
  } else {
    print('[SYNC] Registry is already in sync.');
  }
}

const String _fluxyTestTemplate = """
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxy/fluxy.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('Fluxy App Boot Test', (WidgetTester tester) async {
    // 1. Initialize Minimal Framework
    await Fluxy.init();

    // 2. Build App
    await tester.pumpWidget(
      const FluxyApp(
        title: 'Test App',
        routes: [],
      ),
    );

    // 3. Verify Boot
    expect(find.byType(FluxyApp), findsOneWidget);
  });
}
""";
