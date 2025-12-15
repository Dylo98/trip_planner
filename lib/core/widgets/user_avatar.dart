import 'package:flutter/material.dart';
import 'package:trip_planner/core/theme/colors.dart';
import 'package:trip_planner/core/theme/text_style.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.displayName,
    this.avatarUrl,
    this.radius,
    this.backgroundColor,
    this.textColor,
    this.textStyle,
  });

  final String displayName;
  final String? avatarUrl;
  final double? radius;
  final Color? backgroundColor;
  final Color? textColor;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final hasAvatar = avatarUrl != null && avatarUrl!.isNotEmpty;

    final effectiveBgColor =
        backgroundColor ?? AppColors.limeSliceDark.withValues(alpha: 0.1);

    final effectiveTextStyle = (textStyle ?? AppTextStyles.bodySmall).copyWith(
      color: textColor ?? AppColors.limeSliceDark,
    );

    return CircleAvatar(
      radius: radius,
      backgroundColor: effectiveBgColor,
      backgroundImage: hasAvatar ? NetworkImage(avatarUrl!) : null,
      child: !hasAvatar
          ? Text(
              displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
              style: effectiveTextStyle,
            )
          : null,
    );
  }
}
