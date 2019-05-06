import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:loadmore/loadmore/Indicator.dart';
import 'package:loadmore/loadmore/refresh_indicator.dart';

typedef Future PullRefreshCallback();

class PullRefreshBox extends StatefulWidget {
  PullRefreshBox(
      {Key key,
      this.child,
      @required this.onRefresh,
      Indicator indicator,
      this.overScrollEffect})
      : this.indicator = indicator ?? DefRefreshIndicator(),
        super(key: key);

  final PullRefreshCallback onRefresh;
  final Widget child;
  final TargetPlatform overScrollEffect;
  final Indicator indicator;

  @override
  State createState() => new _PullRefreshBoxState();
}

/// Contains the state for a [PullRefreshBox]. This class can be used to
/// programmatically show the refresh indicator, see the [show] method.
/// [RefreshIndicatorState], can be used to programmatically show the refresh indicator.

class _PullRefreshBoxState extends State<PullRefreshBox>
    with TickerProviderStateMixin {
  IndicatorState _mode;
  AnimationController _controller;
  double _dragOffset = .0;
  ScrollDirection _direction;
  bool _refreshing = false;

  bool get _androidEffect =>
      widget.overScrollEffect == TargetPlatform.android ||
      (widget.overScrollEffect == null &&
          defaultTargetPlatform == TargetPlatform.android);

  double get _indicatorHeight =>
      widget.indicator.height ?? widget.indicator.displacement;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this,
        duration: Duration(seconds: 2),
        lowerBound: -300.0,
        upperBound: 300.0);
    _controller.value = 0.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> show() {
    print("show");
    _mode = IndicatorState.refresh;
    return _checkIfNeedRefresh();
  }

  _goBack() {
    _dragOffset = .0;
    if (mounted) {
      _controller
          .animateTo(
        0.0,
        duration: Duration(milliseconds: 200),
        curve: Curves.easeOut,
      )
          .then((e) {
        _mode = IndicatorState.done;
      });
    }
  }

  Future _checkIfNeedRefresh() {
    if (_mode == IndicatorState.refresh && !_refreshing) {
      _refreshing = true;
      _controller.animateTo(widget.indicator.displacement,
          duration: Duration(milliseconds: 200));
      return widget.onRefresh().whenComplete(() {
        _mode = IndicatorState.done;
        _goBack();
        _refreshing = false;
      });
    }
    return Future.value(null);
  }

  @override
  Widget build(BuildContext context) {
    _checkIfNeedRefresh();
    print("_indicatorHeight = "+_indicatorHeight.toString());
    return Stack(
      children: <Widget>[
        AnimatedBuilder(
          builder: (BuildContext context, Widget child) {
            return Transform.translate(
              offset: Offset(0.0, _controller.value),
              child: NotificationListener<ScrollNotification>(
                onNotification: _handleScrollNotification,
                child:
                    new NotificationListener<OverscrollIndicatorNotification>(
                        onNotification: _handleGlowNotification,
                        child: Theme(
                          data: Theme.of(context)
                              .copyWith(platform: TargetPlatform.android),
                          child: widget.child,
                        )),
              ),
            );
          },
          animation: _controller,
        ),
        //Header
        AnimatedBuilder(
          builder: (BuildContext context, Widget child) {
            return Transform.translate(
                offset: Offset(0.0, -_indicatorHeight + _controller.value + 1),
                child: SizedBox(
                    height: _indicatorHeight,
                    width: double.infinity,
                    child: widget.indicator.build(
                      context,
                      _mode,
                      _dragOffset,
                      _direction,
                    )));
          },
          animation: _controller,
        )
      ],
    );
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (_mode == IndicatorState.refresh) {
      return true;
    }
    if (notification is OverscrollNotification) {
      if (_mode != IndicatorState.refresh) {
        double _temp = _dragOffset;
        _dragOffset -= notification.overscroll / 3.0;
        _mode = IndicatorState.drag;
        if (_androidEffect) {
          if (_dragOffset < .0) {
            _dragOffset = .0;
          }
        }
        if (_temp != _dragOffset) {
          _controller.value = _dragOffset;
        }
      }
    } else if (notification is ScrollUpdateNotification) {
      if (_dragOffset > 0.0) {
        _dragOffset -= notification.scrollDelta;
        _controller.value = _dragOffset;
      }
    } else if (notification is ScrollEndNotification) {
      if (_dragOffset >= (widget.indicator.displacement) &&
          _mode != IndicatorState.refresh) {
        setState(() {
          _mode = IndicatorState.refresh;
        });
      }
      if (_mode != IndicatorState.refresh) {
        _mode = IndicatorState.canceled;
        _goBack();
      }
    } else if (notification is UserScrollNotification) {
      _direction = notification.direction;
    }
    return false;
  }

  bool _handleGlowNotification(OverscrollIndicatorNotification notification) {
    if (!_androidEffect || notification.leading) {
      notification.disallowGlow();
    }
    return true;
  }
}
