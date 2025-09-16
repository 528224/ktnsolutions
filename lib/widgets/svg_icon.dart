import 'package:flutter/material.dart';

class SvgIcon extends StatelessWidget {
  final String iconPath;
  final double? size;
  final Color? color;
  final double? strokeWidth;

  const SvgIcon({
    super.key,
    required this.iconPath,
    this.size,
    this.color,
    this.strokeWidth,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size ?? 24,
      height: size ?? 24,
      child: Image.network(
        iconPath,
        width: size ?? 24,
        height: size ?? 24,
        color: color,
        errorBuilder: (context, error, stackTrace) {
          // Fallback to a simple colored circle if SVG fails to load
          return Container(
            width: size ?? 24,
            height: size ?? 24,
            decoration: BoxDecoration(
              color: color?.withOpacity(0.3) ?? Colors.grey.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.help_outline,
              size: (size ?? 24) * 0.6,
              color: color ?? Colors.grey,
            ),
          );
        },
      ),
    );
  }
}
