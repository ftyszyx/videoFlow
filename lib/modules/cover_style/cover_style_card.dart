import 'dart:io';
import 'package:flutter/material.dart';
import 'package:videoflow/models/db/cover_style.dart';

class CoverStyleCard extends StatelessWidget {
  final CoverStyle style;
  final VoidCallback onDelete;
  final VoidCallback onTap;
  const CoverStyleCard({
    super.key,
    required this.style,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (style.backgroundImagePath != null)
                    Image.file(
                      File(style.backgroundImagePath!),
                      fit: BoxFit.cover,
                    )
                  else
                    Container(color: Colors.grey.shade200),
                  Positioned(
                    left: style.titleX,
                    top: style.titleY,
                    child: Text(
                      '标题示例',
                      style: TextStyle(
                        color: Color(style.titleColor),
                        fontSize: style.titleFontSize,
                      ),
                    ),
                  ),
                  Positioned(
                    left: style.subX,
                    top: style.subY,
                    child: Text(
                      '副标题示例',
                      style: TextStyle(
                        color: Color(style.subColor),
                        fontSize: style.subFontSize,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              title: Text(
                style.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                '标题: ${style.titleFontSize}  副标题: ${style.subFontSize}',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: onDelete,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
