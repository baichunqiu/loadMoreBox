import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

enum IndicatorState {
  ///Pointer is down(over scroll)
  drag,

  /// Running the load More callback.
  load,

  /// Running the refresh callback.
  refresh,

  /// Animating the indicator's fade-out after refreshing.
  done,

  /// Animating the indicator's fade-out after not arming.
  canceled,
}

abstract class Indicator {
  static const double split_load = 70.0;
  static const double split_refresh = 60.0;
  static const double def_progress_size = 20.0;
  static const Color def_color = Colors.blue;
  static const TextStyle def_style = TextStyle(color: def_color,fontSize: 15.5);
  double get displacement;

  /// Header height
  double get height;

  Widget build(
      BuildContext context,
      IndicatorState mode,
      double offset, //drag offset(over scroll)
      ScrollDirection direction);
}
