import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

const double defaultMargins = 24;
const double defaultMarginn = 30;
double defaultWidth(BuildContext context) =>
    deviceWidth(context) - 2 * defaultMarginn;
double defaultHeight(BuildContext context) =>
    deviceHeight(context) - 2 * defaultMarginn;
double deviceWidth(BuildContext context) => MediaQuery.of(context).size.width;
double deviceHeight(BuildContext context) => MediaQuery.of(context).size.height;
double statusBarHeight(BuildContext context) =>
    MediaQuery.of(context).padding.top;

class PaddingCustom {
  paddingAll(double value) {
    return EdgeInsets.all(value.sp);
  }

  paddingHorizontalVertical(double horizontal, double vertical) {
    return EdgeInsets.symmetric(horizontal: horizontal.h, vertical: vertical.w);
  }

  paddingHorizontal(double horizontal) {
    return EdgeInsets.symmetric(horizontal: horizontal.h);
  }

  paddingVertical(double vertical) {
    return EdgeInsets.symmetric(vertical: vertical.w);
  }

  paddingOnly({
    double left = 0.0,
    double top = 0.0,
    double right = 0.0,
    double bottom = 0.0,
  }) {
    return EdgeInsets.only(
        left: left.sp, top: top.sp, right: right.sp, bottom: bottom.sp);
  }
}

class GapCustom {
  gapValue(double value, bool columnTrue) {
    if (columnTrue == true) {
      return SizedBox(height: value.h);
    } else {
      return SizedBox(width: value.w);
    }
  }
}
