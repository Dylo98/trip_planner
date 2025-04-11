import 'package:flutter/material.dart';
import 'package:trip_planner/widgets/bottomsheets/login_bottom_sheet.dart';

void showLoginBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: FractionallySizedBox(
          heightFactor: 0.6,
          child: SingleChildScrollView(
            child: LoginBottomSheet(context),
          ),
        ),
      );
    },
  );
}
