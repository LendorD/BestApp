import 'package:flutter/material.dart';

abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 22;
  static const double xl = 28;
  static const double xxl = 36;
  static const double section = 28;

  static const EdgeInsets pageDesktop = EdgeInsets.fromLTRB(28, 24, 28, 44);
  static const EdgeInsets pageMobile = EdgeInsets.fromLTRB(16, 14, 16, 28);
  static const EdgeInsets card = EdgeInsets.all(lg);
  static const EdgeInsets cardCompact = EdgeInsets.all(md);
}
