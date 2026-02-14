// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:flutter/material.dart';
import 'package:fluxy/fluxy.dart';
import 'marketplace_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FluxyPlayApp());
}

class FluxyPlayApp extends StatelessWidget {
  const FluxyPlayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FluxyApp(
      title: 'Fluxy Play',
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      initialRoute: FxRoute(
        path: '/',
        builder: (_, __) => const PlayHomeScreen(),
      ),
      routes: [
        FxRoute(path: '/', builder: (_, __) => const PlayHomeScreen()),
        FxRoute(
          path: '/marketplace',
          builder: (_, __) => const MarketplaceScreen(),
        ),
        FxRoute(
          path: '/preview',
          builder: (_, args) {
            final url = (args as Map?)?['url'] as String? ?? '';
            return PreviewScreen(url: url);
          },
        ),
      ],
    );
  }
}

class PlayHomeScreen extends StatelessWidget {
  const PlayHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fluxy Play ✨'),
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHero(context),
            const SizedBox(height: 20),
            _buildQuickAccess(context),
            const SizedBox(height: 20),
            _buildFeatured(context),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUrlDialog(context),
        child: const Icon(Icons.qr_code_scanner),
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Welcome Back!",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Test your Fluxy apps instantly without building.",
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.flash_on),
            label: const Text("Enter Project URL"),
            onPressed: () => _showUrlDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccess(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Explore",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => FluxyRouter.to('/marketplace'),
                child: const Text("View All"),
              ),
            ],
          ),
          SizedBox(
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildCard(
                  context,
                  "Starter",
                  Icons.rocket_launch,
                  Colors.orange,
                ),
                _buildCard(
                  context,
                  "E-Commerce",
                  Icons.shopping_bag,
                  Colors.blue,
                ),
                _buildCard(context, "SaaS", Icons.bar_chart, Colors.purple),
                _buildCard(context, "Todo", Icons.check_circle, Colors.green),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
  ) {
    return GestureDetector(
      onTap: () {
        // Find template by name/id roughly
        final tpl = MarketplaceData.templates.firstWhere(
          (t) => t['name'].contains(title),
          orElse: () => MarketplaceData.templates.first,
        );
        FluxyRouter.to('/preview', arguments: {'url': tpl['manifestUrl']});
      },
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatured(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Community Apps",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...MarketplaceData.communityApps.map(
            (app) => ListTile(
              leading: CircleAvatar(child: Text(app['name'][0])),
              title: Text(app['name']),
              subtitle: Text(" by ${app['author']}"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => FluxyRouter.to(
                '/preview',
                arguments: {'url': app['manifestUrl']},
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showUrlDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Open Remote App'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Manifest URL',
            hintText: 'https://...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (controller.text.isNotEmpty) {
                FluxyRouter.to('/preview', arguments: {'url': controller.text});
              }
            },
            child: const Text('Load'),
          ),
        ],
      ),
    );
  }
}

class MarketplaceScreen extends StatelessWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Template Marketplace')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: MarketplaceData.templates.length,
        itemBuilder: (context, index) {
          final tpl = MarketplaceData.templates[index];
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              onTap: () => FluxyRouter.to(
                '/preview',
                arguments: {'url': tpl['manifestUrl']},
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      child: const Center(
                        child: Icon(Icons.image, size: 48, color: Colors.grey),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tpl['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tpl['description'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class PreviewScreen extends StatefulWidget {
  final String url;
  const PreviewScreen({super.key, required this.url});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  @override
  void initState() {
    super.initState();
    // In a real implementation, we would call Fluxy.update(widget.url) here
    // But since simulated, we just try to load simulated path if possible or fallback.
    // However, FxRemoteView in sdui_renderer.dart uses FluxyRemote.getJson(path).
    // If URL is full URL, FluxyRemote needs to handle it.
    // FluxyRemote.getJson expects filename.
    // Fluxy.update expects manifest URL.
    // Here we will simulate 'update' logic via Fluxy.update first.
    _load();
  }

  Future<void> _load() async {
    await Fluxy.update(widget.url);
    setState(() {}); // Rebuild to refresh views if needed
  }

  @override
  Widget build(BuildContext context) {
    // Extract filename from URL (simplistic)
    final filename = widget.url
        .split('/')
        .lastWhere(
          (element) => element.endsWith('.json'),
          orElse: () => 'home.json',
        );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => FluxyRouter.back(),
        ),
      ),
      body: FxRemoteView(
        path: filename,
        placeholder: const Center(child: CircularProgressIndicator()),
        errorBuilder: (e) => Center(
          child: Text(
            'Failed to load $filename\nError: $e\nURL: ${widget.url}',
          ),
        ),
      ),
    );
  }
}
