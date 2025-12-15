import 'package:flutter/material.dart';

class ProfileEditButton extends StatelessWidget {
  final IconData icon;

  final double size;

  final VoidCallback? onTap;

  const ProfileEditButton({
    super.key,
    required this.icon,
    this.size = 45,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(size / 2),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: size * 0.5,
            color: Colors.grey[700],
          ),
        ),
      ),
    );
  }
}
