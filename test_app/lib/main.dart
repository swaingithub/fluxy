import 'package:flutter/material.dart';
import 'package:fluxy/fluxy.dart';

void main() async {
  // 1. Framework Initialization
  WidgetsFlutterBinding.ensureInitialized();
  await Fluxy.init();
  
  // 2. Setup Debug Features & Launch
  runApp(Fluxy.debug(child: const FluxyUltimateApp()));
}

class FluxyUltimateApp extends StatelessWidget {
  const FluxyUltimateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const FluxyApp(
      title: 'Fluxy Enterprise Feature Showcase',
      home: MainNavigationWrapper(),
    );
  }
}

class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  final currentIndex = flux<int>(0);

  @override
  Widget build(BuildContext context) {
    return Fx.scaffold(
      bottomNavigationBar: Fx(() => Fx.bottomNav(
        currentIndex: currentIndex.value,
        onTap: (v) => currentIndex.value = v,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey.shade400,
        containerStyle: FxStyle(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          backgroundColor: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          shadows: [
            BoxShadow(
              color: Colors.indigo.withValues(alpha: 0.1),
              blurRadius: 30,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.hub_outlined), activeIcon: Icon(Icons.hub), label: 'Core'),
          BottomNavigationBarItem(icon: Icon(Icons.palette_outlined), activeIcon: Icon(Icons.palette), label: 'Design'),
          BottomNavigationBarItem(icon: Icon(Icons.business_outlined), activeIcon: Icon(Icons.business), label: 'Enterprise'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings), label: 'System'),
        ],
      )),
      body: Fx(() => AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: [
          const CoreReactiveTab(key: ValueKey(0)),
          const PremiumUITab(key: ValueKey(1)),
          const EnterpriseTab(key: ValueKey(2)),
          const SystemSettingsTab(key: ValueKey(3)),
        ][currentIndex.value],
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: animation.drive(Tween(
                begin: const Offset(0.0, 0.05),
                end: Offset.zero,
              )),
              child: child,
            ),
          );
        },
      )),
    );
  }
}

// --- Tab 1: Core Reactivity ---
class CoreReactiveTab extends StatelessWidget {
  const CoreReactiveTab({super.key});

  @override
  Widget build(BuildContext context) {
    final counter = flux<int>(0, label: 'core_counter');
    final isPremium = flux<bool>(false);
    final status = fluxComputed(() => counter.value > 10 ? 'VIP Status' : 'Standard');

    return Fx.page(
      appBar: Fx.appBar(title: 'Reactive Kernel'),
      child: Fx.col(
        gap: 20,
        children: [
          Fx.text('Atomic State').font.xl2().bold(),
          Fx(() => Fx.box(
            style: FxStyle(
              padding: const EdgeInsets.all(24),
              backgroundColor: isPremium.value ? Colors.amber.shade50 : Colors.blue.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isPremium.value ? Colors.amber : Colors.blue),
            ),
            child: Fx.col(
              children: [
                Fx.text('${counter.value}').font.xl6().bold(),
                Fx.text(status.value).font.sm().color(Colors.grey),
              ],
            ),
          )),
          Fx.row(
            gap: 12,
            children: [
              Fx.button('Decrement', onTap: () => counter.value--).secondary.sizeSm(),
              Fx.button('Increment', onTap: () => counter.value++).primary,
            ],
          ).center(),
          Fx.divider(),
          Fx.text('Collections (Reactive List)').bold(),
          Fx.list(
            shrinkWrap: true,
            children: [
              Fx.text('Fluxy allows managing nested state without full rebuilds.').p(12).bg.color(Colors.grey.shade50).rounded(8),
            ],
          ),
        ],
      ).p(20).scrollable(),
    );
  }
}

// --- Tab 2: Premium UI ---
class PremiumUITab extends StatelessWidget {
  const PremiumUITab({super.key});

  @override
  Widget build(BuildContext context) {
    return Fx.page(
      appBar: Fx.appBar(title: 'Premium Design DSL'),
      child: Fx.col(
        gap: 24,
        children: [
          Fx.box(
            style: const FxStyle(
              height: 150,
              width: double.infinity,
              imageSrc: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe',
              fit: BoxFit.cover,
            ),
            child: Fx.box(
              style: const FxStyle(
                glass: 20,
                padding: EdgeInsets.all(20),
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              child: Fx.text('Glassmorphism').whiteText().bold().font.xl(),
            ).center(),
          ).rounded(24).clip(),
          Fx.text('Button Variations').bold(),
          Fx.wrap(
             spacing: 8, runSpacing: 8,
             children: [
               Fx.primaryButton('Primary'),
               Fx.secondaryButton('Secondary'),
               Fx.dangerButton('Danger'),
               Fx.successButton('Success'),
               Fx.outlineButton('Outline'),
               Fx.ghostButton('Ghost'),
             ],
          ),
          Fx.row(
            gap: 20,
            children: [
              Fx.avatar(image: 'https://i.pravatar.cc/150?u=1', size: FxAvatarSize.lg),
              Fx.col(
                alignItems: CrossAxisAlignment.start,
                children: [
                  Fx.text('Sarah Jenkins').bold(),
                  Fx.badge(child: Fx.text('PRO'), label: 'Verified').bg.color(Colors.green),
                ],
              ),
            ],
          ),
          Fx.divider(),
          Fx.text('Modifiers & Layout').bold(),
          Fx.text('Chain modifiers for infinite combinations:').textSm().color(Colors.grey),
          Fx.box(
            style: FxStyle(
              backgroundColor: Colors.indigo.shade900,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Fx.text('Modern Styling System').whiteText().bold(),
          ),
        ],
      ).p(20).scrollable(),
    );
  }
}

// --- Tab 3: Enterprise Flow ---
class EnterpriseTab extends StatefulWidget {
  const EnterpriseTab({super.key});

  @override
  State<EnterpriseTab> createState() => _EnterpriseTabState();
}

class _EnterpriseTabState extends State<EnterpriseTab> {
  // Form State
  final loginForm = fluxForm({
    'email': fluxField('').required().email(),
    'password': fluxField('').required().minLength(8),
  });

  // Isolate state
  final worker = flux<AsyncStatus>(AsyncStatus.idling);
  final workerResult = flux<String>('No data processed');

  void startHeavyTask() async {
    worker.value = AsyncStatus.loading;
    // Simulate heavy computation in isolate
    final result = await fluxIsolate<String>(() {
      // Busy wait simulation
      int count = 0;
      for (int i = 0; i < 100000000; i++) { count += i; }
      return 'Processed $count items in background isolate';
    });
    workerResult.value = result;
    worker.value = AsyncStatus.success;
  }

  @override
  Widget build(BuildContext context) {
    return Fx.page(
      appBar: Fx.appBar(title: 'Industrial Core'),
      child: Fx.col(
        gap: 24,
        children: [
          // 1. Reactive Forms
          Fx.text('FluxForm Validation').font.xl().bold(),
          Fx.form(
            form: loginForm,
            onSubmit: () => Fx.toast.success('Login authorized!'),
            children: [
              Fx.input(
                signal: loginForm.field('email'),
                placeholder: 'Corporate Email',
                icon: Icons.business,
              ),
              Fx.gap(12),
              Fx.password(
                signal: loginForm.field('password'),
                placeholder: 'Security Key',
              ),
              Fx.gap(16),
              Fx.button('Sign In', onTap: () => loginForm.validate())
                  .primary.wFull(),
            ],
          ),

          Fx.divider(),

          // 2. Isolate Worker
          Fx.text('Performance Isolates').font.xl().bold(),
          Fx(() => Fx.col(
            children: [
              Fx.text(workerResult.value).textSm().color(Colors.grey).mb(12),
              Fx.button(
                worker.value == AsyncStatus.loading ? 'Calculating...' : 'Run Isolate Task',
                onTap: worker.value == AsyncStatus.loading ? null : startHeavyTask,
              ).secondary.wFull().loading(worker.value == AsyncStatus.loading),
            ],
          )),

          Fx.divider(),

          // 3. Modern Tables
          Fx.text('Modern Data Table').font.xl().bold(),
          Fx.table<Map<String, String>>(
            data: [
              {'id': 'TX-001', 'status': 'Paid', 'amount': r'$1,200'},
              {'id': 'TX-002', 'status': 'Pending', 'amount': r'$850'},
              {'id': 'TX-003', 'status': 'Failed', 'amount': r'$45'},
            ],
            columns: [
              FxTableColumn(header: 'Transaction', cellBuilder: (item) => Fx.text(item['id']!).bold()),
              FxTableColumn(header: 'Status', cellBuilder: (item) => Fx.text(item['status']!)),
              FxTableColumn(header: 'Amount', cellBuilder: (item) => Fx.text(item['amount']!)),
            ],
          ).p(4),
        ],
      ).p(20).scrollable(),
    );
  }
}

// --- Tab 4: System & Infrastructure ---
class SystemSettingsTab extends StatelessWidget {
  const SystemSettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Fx.page(
      appBar: Fx.appBar(title: 'High Performance Infrastructure'),
      child: Fx.col(
        gap: 16,
        children: [
          Fx.text('Network Architecture').bold(),
          Fx.button('Fetch API Mock (AsyncFlux)', 
            onTap: () => Fx.toast.info('Consult Data tab for Fetching implementation')).outline.wFull(),
            
          Fx.divider(),
          
          Fx.text('Safety & Feedback').bold(),
          Fx.row(
            gap: 10,
            children: [
              Fx.button('Dialog', onTap: () => Fx.dialog.alert(
                title: 'Operation Safe',
                content: 'Fluxy handles error boundaries automatically.',
              )).ghost.flex(),
              Fx.button('Loader', onTap: () async {
                Fx.loader.show(label: 'Syncing...');
                await Future.delayed(const Duration(seconds: 1));
                Fx.loader.hide();
              }).outline.flex(),
            ],
          ),

          Fx.divider(),

          Fx.text('Touch Engine (Haptics)').bold(),
          Fx.row(
            gap: 10,
            children: [
              Fx.button('Light', onTap: () => Fx.haptic.light()).sizeSm().flex(),
              Fx.button('Medium', onTap: () => Fx.haptic.medium()).sizeSm().flex(),
              Fx.button('Heavy', onTap: () => Fx.haptic.heavy()).sizeSm().flex(),
            ],
          ),

          Fx.divider(),

          Fx.text('Ecosystem Theme').bold(),
          Fx.row(
            children: [
              Fx.text('Industrial Dark Mode'),
              Fx.spacer(),
              Fx.button(FxTheme.isDarkMode ? 'Dark' : 'Light', 
                onTap: () => FxTheme.toggle()).sizeSm().outline,
            ],
          ),
          
          Fx.spacer(flex: 1),
          Fx.text('Fluxy Framework v1.0.0-Stable').font.xs().muted().center(),
        ],
      ).p(20).intrinsicH(),
    );
  }
}
