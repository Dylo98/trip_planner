import 'package:flutter/material.dart';

class AuthBottomSheetWrapper {
  static void show({
    required BuildContext context,
    required Widget child,
    double heightFactor = 0.6,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: FractionallySizedBox(
              heightFactor: heightFactor,
              child: SingleChildScrollView(
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}
