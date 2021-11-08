import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

import 'flutter_radial_chart.dart';

typedef ChartTappedDelegate = Function(ChartTapInfo info);

class ChartTapInfo {
  final TapDownDetails tapDownDetails;
  final Size currentWidgetSize;

  ChartTapInfo({
    required this.tapDownDetails,
    required this.currentWidgetSize,
  });
}

class ChartPainterController {
  late ChartTappedDelegate chartTappedDelegate;

  final Function(ChartItem?) onItemTapped;

  ChartPainterController({
    required this.onItemTapped,
  });

  set onChartTappedDelegate(ChartTappedDelegate _callback) {
    chartTappedDelegate = _callback;
  }

  ChartTappedDelegate get onChartTappedDelegate {
    return chartTappedDelegate;
  }

  void tapChart(ChartTapInfo info) {
    onChartTappedDelegate(info);
  }
}

class ChartPainter extends CustomPainter {
  final List<ChartItem> items;
  final ChartItem? selectedItem;
  final ChartPainterController controller;
  final double strokeWidth;
  final double selectedStrokeWidth;

  //how distant from the chart item the tap is considered a hit.
  final double tapDetectionTolerance;

  ChartPainter({
    required this.items,
    required this.controller,
    required this.selectedItem,
    this.tapDetectionTolerance = 10,
    this.strokeWidth = 60.0,
    this.selectedStrokeWidth = 50.0,
  }) {
    controller.onChartTappedDelegate = _chartTapped;
  }

  void _chartTapped(ChartTapInfo info) {
    double x =
        info.tapDownDetails.localPosition.dx - info.currentWidgetSize.width / 2;
    double y = info.tapDownDetails.localPosition.dy -
        info.currentWidgetSize.height / 2;

    double vectorLength = math.sqrt((x * x) + (y * y)).abs();

    if ((vectorLength - info.currentWidgetSize.width / 2).abs() <
        tapDetectionTolerance) {
      double angle = math.acos(x / vectorLength);

      if (y < 0.0) {
        angle = math.pi + (math.pi - angle.abs());
      }

      double sum = 0;

      for (var item in items) {
        sum += _getRadiansFromValue(item.value);

        if (sum >= angle) {
          controller.onItemTapped(item);

          return;
        }
      }

      return;
    }

    //no item was hit
    controller.onItemTapped(null);
  }

  double get totalValue =>
      items.fold(0, (previousValue, element) => previousValue + element.value);

  double _getRadiansFromValue(double value) {
    final ratio = value * 100 / totalValue;

    return ratio * (2 * math.pi) / 100;
  }

  void _drawArc(
    Canvas canvas,
    ChartItem item,
    Rect rect,
    double start,
    bool itemSelected,
  ) {
    final paint = Paint();

    paint.style = PaintingStyle.stroke;
    paint.strokeCap = StrokeCap.butt;

    paint.color = item.color;
    paint.strokeWidth = itemSelected ? selectedStrokeWidth : strokeWidth;

    canvas.drawArc(
      rect,
      //start
      _getRadiansFromValue(start),
      //length
      _getRadiansFromValue(item.value),
      false,
      paint,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final minDimension = math.min(size.width, size.height);

    final rect = Rect.fromCenter(
      center: Offset(minDimension / 2, minDimension / 2),
      width: minDimension,
      height: minDimension,
    );

    double sum = 0;

    double selectedItemStart = 0;

    for (var item in items) {
      bool isSelected = selectedItem == item;

      if (isSelected) {
        selectedItemStart = sum;

        sum += item.value;

        continue;
      }

      _drawArc(canvas, item, rect, sum, false);

      sum += item.value;
    }

    if (selectedItem == null) return;

    _drawArc(canvas, selectedItem!, rect, selectedItemStart, true);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
