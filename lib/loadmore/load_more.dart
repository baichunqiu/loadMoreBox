import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:loadmore/loadmore/Indicator.dart';
import 'package:loadmore/loadmore/load_indicator.dart';

/// The signature for a function that's called when the user has dragged a
/// [LoadMoreBox] far enough to demonstrate that they want the app to
/// refresh. The returned [Future] must complete when the refresh operation is
/// finished.
///
/// Used by [LoadMoreBox.onLoad].
typedef Future LoadCallback();

/// A widget that supports "swipe to refresh" idiom.
///
/// When the child's [Scrollable] descendant overscrolls, an indicator is
/// faded into view. When the scroll ends, if the
/// indicator has been dragged far enough for it to become completely visible,
/// the [onLoad] callback is called. The callback is expected to update the
/// scrollable's contents and then complete the [Future] it returns. The refresh
/// indicator disappears after the callback's [Future] has completed.
///
/// If the [Scrollable] might not have enough content to overscroll, consider
/// settings its `physics` property to [AlwaysScrollableScrollPhysics]:
///
/// ```dart
/// new ListView(
///   physics: const AlwaysScrollableScrollPhysics(),
///   children: ...
//  )
/// ```
///
/// Using [AlwaysScrollableScrollPhysics] will ensure that the scroll view is
/// always scrollable and, therefore, can trigger the [LoadMoreBox].
///
/// See also:
///
///  * [_LoadMoreBoxState], can be used to programmatically show the refresh indicator.
///
class LoadMoreBox extends StatefulWidget {
  LoadMoreBox(
      {Key key,
      this.child,
      @required this.onLoad,
      Indicator indicator,
      this.overScrollEffect})
      : this.indicator = indicator ?? DefLoadIndicator(),
        super(key: key);

  final LoadCallback onLoad;
  final Widget child;
  final TargetPlatform overScrollEffect;
  final Indicator indicator;

  @override
  State createState() => new _LoadMoreBoxState();
}

/// Contains the state for a [LoadMoreBox]. This class can be used to
/// programmatically show the refresh indicator, see the [show] method.
/// [RefreshIndicatorState], can be used to programmatically show the refresh indicator.

class _LoadMoreBoxState extends State<LoadMoreBox>
    with TickerProviderStateMixin {
  IndicatorState _loadState;
  AnimationController _controller;
  double _dragOffset = .0;
  ScrollDirection _direction;
  bool _refreshing = false;

  bool get _androidEffect =>
      widget.overScrollEffect == TargetPlatform.android ||
      (widget.overScrollEffect == null &&
          defaultTargetPlatform == TargetPlatform.android);

  double get _indicatorHeight =>
      widget.indicator.height ??
      widget.indicator.displacement;

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

  /// Show the refresh indicator and run the refresh callback as if it had
  /// been started interactively. If this method is called while the refresh
  /// callback is running, it quietly does nothing.
  ///
  /// Creating the [LoadMoreBox] with a [GlobalKey<_LoadMoreBoxState>]
  /// makes it possible to refer to the [_LoadMoreBoxState].
  ///
  /// The future returned from this method completes when the
  /// [LoadMoreBox.onLoad] callback's future completes.
  ///
  /// If you await the future returned by this function from a [State], you
  /// should check that the state is still [mounted] before calling [setState].

  Future<void> show() {
    _loadState = IndicatorState.load;
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
        _loadState = IndicatorState.done;
      });
    }
  }

  Future _checkIfNeedRefresh() {
    if (_loadState == IndicatorState.load && !_refreshing) {
      _refreshing = true;
      _controller.animateTo(widget.indicator.displacement,
          duration: Duration(milliseconds: 200));
      return widget.onLoad().whenComplete(() {
        _loadState = IndicatorState.done;
        _goBack();
        _refreshing = false;
      });
    }
    return Future.value(null);
  }

  @override
  Widget build(BuildContext context) {
    _checkIfNeedRefresh();
    double height = MediaQuery.of(context).size.height;
    return Stack(
      children: <Widget>[
        AnimatedBuilder(
          builder: (BuildContext context, Widget child) {
            return Transform.translate(
              offset: Offset(0.0, -1 * _controller.value),
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
                offset: Offset(
                    0.0, height -_indicatorHeight - _controller.value),
                child: SizedBox(
                    height: _indicatorHeight,
                    width: double.infinity,
                    child: widget.indicator.build(
                      context,
                      _loadState,
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
    if (_loadState == IndicatorState.load) {
      return true;
    }
    if (notification is OverscrollNotification) {
      if (_loadState != IndicatorState.load) {
        double _temp = _dragOffset;
        _dragOffset += notification.overscroll / 3.0;
        _loadState = IndicatorState.drag;
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
        _dragOffset += notification.scrollDelta;
        _controller.value = _dragOffset;
      }
    } else if (notification is ScrollEndNotification) {
      if (_dragOffset >= (widget.indicator.displacement) &&
          _loadState != IndicatorState.load) {
        setState(() {
          _loadState = IndicatorState.load;
        });
      }
      if (_loadState != IndicatorState.load) {
        _loadState = IndicatorState.canceled;
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
