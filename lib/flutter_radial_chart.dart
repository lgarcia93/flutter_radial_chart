library flutter_radial_chart;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'chart_painter.dart';

typedef ItemSelectedDelegate = Function(ChartItem);

class ChartItem {
  final double value;
  final Color color;
  final bool selected;

  ChartItem({
    required this.value,
    required this.color,
    this.selected = false,
  });
}

class Chart extends StatefulWidget {
  final List<ChartItem> items;
  final double strokeWidth;
  final double selectedStrokeWidth;
  final ItemSelectedDelegate? onItemSelected;
  final VoidCallback? onItemDeselected;

  const Chart({
    Key? key,
    required this.items,
    this.strokeWidth = 60.0,
    this.onItemSelected,
    this.onItemDeselected,
    this.selectedStrokeWidth = 40.0,
  }) : super(key: key);

  @override
  _ChartState createState() => _ChartState();
}

class _ChartState extends State<Chart> {
  late final ChartPainterController _controller;

  ChartItem? selectedItem;

  @override
  void initState() {
    super.initState();

    _controller = ChartPainterController(
      onItemTapped: (ChartItem? item) {
        setState(
          () {
            selectedItem = item;
          },
        );

        if (item != null) {
          widget.onItemSelected?.call(item);
        } else {
          widget.onItemDeselected?.call();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final maxWidthHeight = math.min(
          constraints.biggest.height,
          constraints.biggest.width,
        );

        final _size = Size(maxWidthHeight, maxWidthHeight);

        return GestureDetector(
          onTapDown: (TapDownDetails? tapDownDetails) {
            _controller.tapChart(
              ChartTapInfo(
                tapDownDetails: tapDownDetails!,
                currentWidgetSize: _size,
              ),
            );
          },
          child: CustomPaint(
            painter: ChartPainter(
              selectedItem: selectedItem,
              items: widget.items,
              controller: _controller,
              strokeWidth: widget.strokeWidth,
              selectedStrokeWidth: widget.selectedStrokeWidth,
            ),
            size: _size,
          ),
        );
      },
    );
  }
}
