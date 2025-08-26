import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:videoflow/entity/qr.dart';
import 'package:videoflow/modules/account/kuaishou/qr_login_control.dart';

class KuaishouQrLoginPage extends GetView<KuaiShouWebLoginControl> {
  const KuaishouQrLoginPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('快手扫码登录'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              controller.loadQrCode();
            },
          ),
        ],
      ),
      body: Center(
        child: Obx(() {
          switch (controller.qrStatus.value) {
            case QRStatus.loading:
              return const CircularProgressIndicator();
            case QRStatus.unscanned:
              final img = controller.qrStartData.value.imageData;
              if (img == null || img.isEmpty) {
                return const Text('二维码加载中...');
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                    ),
                    child: Image.memory(
                      base64Decode(img),
                      width: 220,
                      height: 220,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('请使用快手 App 扫码登录'),
                ],
              );
            case QRStatus.scanned:
              return const Text('已扫码，正在处理...');
            case QRStatus.expired:
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('二维码已过期'),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: () {
                      controller.loadQrCode();
                      controller.startPoll();
                    },
                    child: const Text('重新获取'),
                  ),
                ],
              );
            case QRStatus.failed:
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('加载失败'),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () {
                      controller.loadQrCode();
                      controller.startPoll();
                    },
                    child: const Text('重试'),
                  ),
                ],
              );
          }
        }),
      ),
    );
  }
}
