import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_cloner/modules/splash/splash_controller.dart';

class SplashPage extends GetView<SplashController> {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Container(
          width: 420,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 24, offset: const Offset(0, 12)),
            ],
          ),
          child: Obx(() => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  Text('准备资源中', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(value: controller.progress.value),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(controller.message.value, style: theme.textTheme.bodySmall),
                  ),
                ],
              )),
        ),
      ),
    );
  }
}


