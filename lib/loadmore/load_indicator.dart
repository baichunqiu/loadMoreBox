import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:loadmore/loadmore/Indicator.dart';

/// This is a default PullRefreshIndicator.
class DefLoadIndicator implements Indicator {
  DefLoadIndicator(
      {this.style = Indicator.def_style,
      this.loadingTip,
      this.progressIndicator});

  final TextStyle style;
  final String loadingTip;
  ProgressIndicator progressIndicator;

  @override
  double get displacement => Indicator.split_load;

  @override
  double get height => displacement;

  @override
  Widget build(BuildContext context, IndicatorState mode, offset,
      ScrollDirection direction) {
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
          child: Text(loadingTip ?? "加载中...", style: style),
        )
      ],
    );
//    return Container(color:Colors.grey,child: Row(
//      mainAxisAlignment: MainAxisAlignment.center,
//      children: <Widget>[
//        progressIndicator ??
//            SizedBox(
//              width:Indicator.def_progress_size,
//              height: Indicator.def_progress_size,
//              child: CircularProgressIndicator(
//                strokeWidth: 2.5,
//              ),
//            ),
//        Padding(
//          padding: const EdgeInsets.only(left: 15.0),
//          child: Text(loadingTip ?? "加载中...", style: style),
//        )
//      ],
//    ),);
  }
}
