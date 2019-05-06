import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:loadmore/loadmore/Indicator.dart';
import 'package:loadmore/loadmore/turn_box.dart';

/// This is a default PullRefreshIndicator.
class DefRefreshIndicator implements Indicator {
  DefRefreshIndicator(
      {this.style = Indicator.def_style,
      this.arrowColor = Indicator.def_color,
      this.loadingTip,
      this.pullTip,
      this.loosenTip,
      this.progressIndicator});

  final TextStyle style;
  final Color arrowColor;
  final String loadingTip;
  final String pullTip;
  final String loosenTip;

//  static const double Split = 75.0;
  ProgressIndicator progressIndicator;

  @override
  double get displacement => Indicator.split_refresh;

  @override
  double get height => displacement;

  @override
  Widget build(BuildContext context, IndicatorState mode, offset,
      ScrollDirection direction) {
    if (mode == IndicatorState.refresh) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          progressIndicator ??
              SizedBox(
                width: Indicator.def_progress_size,
                height: Indicator.def_progress_size,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                ),
              ),
          Padding(
            padding: const EdgeInsets.only(left: 15.0),
            child: Text(loadingTip ?? "正在刷新...", style: style),
          )
        ],
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 15.0),
          child: TurnBox(
            turns: offset > Indicator.split_refresh ? 0.5 : .0,
            child: SizedBox(
              width: Indicator.def_progress_size,
              height: Indicator.def_progress_size,
              child: Icon(
                Icons.arrow_upward,
                color: arrowColor,
              ),
            ),
          ),
        ),
        Text(
            offset > Indicator.split_refresh
                ? loosenTip ?? "松开刷新"
                : pullTip ?? "继续下拉",
            style: style)
      ],
    );
  }
}
