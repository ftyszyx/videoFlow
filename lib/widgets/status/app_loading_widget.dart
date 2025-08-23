import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:videoflow/utils/app_style.dart';

class AppLoadingWidget extends StatelessWidget {
  const AppLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: AppStyle.edgeInsetsA12,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).cardColor,
        ),
        child: const CupertinoActivityIndicator(
          radius: 10,
        ),
      ),
    );
  }
}