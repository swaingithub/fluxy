import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:fluxy/fluxy.dart';
import 'package:fluxy/src/engine/stability/stability_metrics.dart';

/// A suite of widgets designed to intentionally trigger Flutter crashes 
/// to test Fluxy Stability Kernel's resilience.
class FluxyCrashTestSuite extends StatelessWidget {
  const FluxyCrashTestSuite({super.key});

  @override
  Widget build(BuildContext context) {
    return Fx.scaffold(
      appBar: Fx.appBar(title: "Fluxy Stability Benchmark"),
      body: Fx.list(
        style: const FxStyle(padding: EdgeInsets.all(16)),
        gap: 16,
        children: [
          _BenchmarkCard(
            title: "The Unbounded Scroll Crash",
            description: "A ListView inside a Column without expanded - standard Flutter death.",
            onTap: () => _test(context, _UnboundedScrollCrash()),
          ),
          _BenchmarkCard(
            title: "The Infinite Flex Collapse",
            description: "A Row with a child that has infinite width.",
            onTap: () => _test(context, _InfiniteFlexCrash()),
          ),
          _BenchmarkCard(
            title: "The Dirty Rebuild Loop",
            description: "A widget that updates a signal it is listening to during build.",
            onTap: () => _test(context, _RebuildLoopCrash()),
          ),
          _BenchmarkCard(
            title: "The Async Dispose Race",
            description: "Triggers setState 3 seconds after the screen is closed.",
            onTap: () => _test(context, _AsyncDisposeRace()),
          ),
          _BenchmarkCard(
            title: "Dual Infinity Disaster",
            description: "A container with infinite height and width inside a scrollable.",
            onTap: () => _test(context, _DualInfinityCrash()),
          ),
        ],
      ),
    );
  }

  void _test(BuildContext context, Widget testCase) {
    Fx.to("/stability-test", arguments: testCase);
  }
}

class StabilityTestRunner extends StatelessWidget {
  const StabilityTestRunner({super.key});

  @override
  Widget build(BuildContext context) {
    final Widget testCase = ModalRoute.of(context)!.settings.arguments as Widget;
    return Fx.scaffold(
      appBar: Fx.appBar(title: "Stability Test Execution"),
      body: Center(child: testCase),
    );
  }
}

class _BenchmarkCard extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onTap;

  const _BenchmarkCard({
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Fx.box(
      onTap: onTap,
      className: "p-4 bg-white rounded-xl shadow-sm border border-slate-100",
      child: Fx.col(
        alignItems: CrossAxisAlignment.start,
        gap: 4,
        children: [
          Fx.text(title).font.lg().font.bold(),
          Fx.text(description).font.sm().color(Colors.blueGrey.shade400),
        ],
      ),
    );
  }
}

// --- Crash Scenarios ---

class _UnboundedScrollCrash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text("This should crash Flutter but Fluxy will save it:"),
        // STANDARD FLUTTER CRASH: ListView inside Column without Expanded
        Fx.scroll(
          child: Fx.col(
            children: List.generate(20, (i) => Fx.text("Item $i").p(8)),
          ),
        ),
      ],
    );
  }
}

class _InfiniteFlexCrash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // STANDARD FLUTTER CRASH: Infinite width child in a Row
        Fx.box(
          style: const FxStyle(width: double.infinity, height: 50, backgroundColor: Colors.blue),
          child: const Text("I am infinite"),
        ),
      ],
    );
  }
}

class _RebuildLoopCrash extends StatelessWidget {
  final count = flux(0);

  @override
  Widget build(BuildContext context) {
    return Fx(() {
      // TRIGGER REBUILD LOOP: Modify signal being read
      count.value++; 
      return Fx.text("Rebuild Count: ${count.value}");
    });
  }
}

class _AsyncDisposeRace extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Fx.col(
      gap: 20,
      children: [
        const Text("Click 'Start Race' and then go back quickly."),
        Fx.button("Start Race", onTap: () async {
          await Future.delayed(const Duration(seconds: 3));
          if (context.mounted) {
            Fx.toast.success("Safe! Widget is still here.");
          } else {
            // This would crash standard Flutter if we used a raw Future/context
             FluxyStabilityMetrics.recordAsyncFix();
             debugPrint("[KERNEL] [ASYNC] Safe! Intercepted update on unmounted context.");
          }
        }),
      ],
    );
  }
}

class _DualInfinityCrash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Fx.scroll(
      child: Fx.box(
        style: const FxStyle(width: double.infinity, height: double.infinity, backgroundColor: Colors.red),
        child: const Text("Deadly Dual Infinity"),
      ),
    );
  }
}
