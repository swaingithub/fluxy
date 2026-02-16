import 'package:flutter/material.dart';
import 'package:fluxy/fluxy.dart';
import 'news.controller.dart';

class NewsView extends StatelessWidget {
  const NewsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Fluxy.find<NewsController>();

    return Scaffold(
      appBar: AppBar(title: Fx.text('News').bold()),
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
