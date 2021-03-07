import 'package:flutter/material.dart';
import 'package:onehub/style/borderRadiuses.dart';
import 'package:onehub/style/colors.dart';

class BranchLabel extends StatelessWidget {
  final String name;
  final double size;
  BranchLabel(this.name, {this.size = 16});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size / 2),
      child: Container(
        decoration: BoxDecoration(
            color: AppColor.accent,
            borderRadius: AppThemeBorderRadius.smallBorderRadius),
        child: Padding(
          padding:
              EdgeInsets.symmetric(vertical: size / 3, horizontal: size / 2),
          child: Text(
            name,
            style: TextStyle(fontSize: size),
          ),
        ),
      ),
    );
  }
}