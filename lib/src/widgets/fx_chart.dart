import 'package:flutter/material.dart';
import '../dsl/fx.dart';
import '../reactive/signal.dart';
import 'fx_widget.dart';

enum FxChartType { bar, line }

class FxChartPoint {
  final String label;
  final double value;
  final Color? color;

  const FxChartPoint({
    required this.label,
    required this.value,
    this.color,
  });
}

/// A high-performance, reactive charting primitive for Fluxy.
class FxChart extends FxWidget {
  final dynamic data; // List<FxChartPoint> or Flux<List<FxChartPoint>>
  final FxChartType type;
  @override
  final FxStyle style;
  @override
  final FxResponsiveStyle? responsive;
  final double height;
  final Duration animationDuration;
  final Curve animationCurve;
  final bool showLabels;
  final bool showValues;

  const FxChart({
    super.key,
    super.id,
    super.className,
    required this.data,
    this.type = FxChartType.bar,
    this.style = FxStyle.none,
    this.responsive,
    this.height = 200,
    this.animationDuration = const Duration(milliseconds: 800),
    this.animationCurve = Curves.easeOutCubic,
    this.showLabels = true,
    this.showValues = true,
  });

  @override
  State<FxChart> createState() => _FxChartState();

  @override
  FxWidget copyWithStyle(FxStyle additionalStyle) {
    return FxChart(
      id: id,
      className: className,
      data: data,
      type: type,
      style: style.merge(additionalStyle),
      responsive: responsive,
      height: height,
      animationDuration: animationDuration,
      animationCurve: animationCurve,
      showLabels: showLabels,
      showValues: showValues,
    );
  }

  @override
  FxWidget copyWithResponsive(FxResponsiveStyle additionalResponsive) {
    return FxChart(
      id: id,
      className: className,
      data: data,
      type: type,
      style: style,
      responsive: responsive?.merge(additionalResponsive) ?? additionalResponsive,
      height: height,
      animationDuration: animationDuration,
      animationCurve: animationCurve,
      showLabels: showLabels,
      showValues: showValues,
    );
  }
}

class _FxChartState extends State<FxChart> with SingleTickerProviderStateMixin, ReactiveSubscriberMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  List<FxChartPoint> _currentData = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.animationDuration);
    _animation = CurvedAnimation(parent: _controller, curve: widget.animationCurve);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    clearDependencies();
    super.dispose();
  }

  @override
  void notify() {
    if (mounted) {
      setState(() {});
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    FluxyReactiveContext.push(this);
    try {
      if (widget.data is Flux<List<FxChartPoint>>) {
        _currentData = (widget.data as Flux<List<FxChartPoint>>).value;
      } else if (widget.data is List<FxChartPoint>) {
        _currentData = widget.data as List<FxChartPoint>;
      } else {
        _currentData = [];
      }

      if (_currentData.isEmpty) {
        return SizedBox(height: widget.height, child: const Center(child: Text("No Data")));
      }

      return Container(
        height: widget.height,
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return CustomPaint(
              painter: _ChartPainter(
                data: _currentData,
                type: widget.type,
                progress: _animation.value,
                primaryColor: widget.style.color ?? Fx.primary,
                showLabels: widget.showLabels,
                showValues: widget.showValues,
              ),
            );
          },
        ),
      );
    } finally {
      FluxyReactiveContext.pop();
    }
  }
}

class _ChartPainter extends CustomPainter {
  final List<FxChartPoint> data;
  final FxChartType type;
  final double progress;
  final Color primaryColor;
  final bool showLabels;
  final bool showValues;

  _ChartPainter({
    required this.data,
    required this.type,
    required this.progress,
    required this.primaryColor,
    required this.showLabels,
    required this.showValues,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final maxVal = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final chartHeight = size.height * 0.8;
    final chartWidth = size.width;

    if (type == FxChartType.bar) {
      _paintBars(canvas, size, maxVal, chartHeight, chartWidth);
    } else {
      _paintLine(canvas, size, maxVal, chartHeight, chartWidth);
    }
  }

  void _paintBars(Canvas canvas, Size size, double maxVal, double chartHeight, double chartWidth) {
    final barWidth = (chartWidth / data.length) * 0.7;
    final spacing = (chartWidth / data.length) * 0.3;

    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < data.length; i++) {
      final point = data[i];
      final h = (point.value / maxVal) * chartHeight * progress;
      final x = i * (barWidth + spacing) + spacing / 2;
      final y = chartHeight - h;

      paint.color = point.color ?? primaryColor;
      
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, h),
        const Radius.circular(4),
      );
      
      canvas.drawRRect(rect, paint);

      if (showLabels) {
        _drawText(canvas, point.label, Offset(x + barWidth / 2, chartHeight + 10), TextAlign.center, barWidth + spacing);
      }
      
      if (showValues && h > 20) {
        _drawText(canvas, point.value.toStringAsFixed(0), Offset(x + barWidth / 2, y + 5), TextAlign.center, barWidth, color: Colors.white, fontSize: 10);
      }
    }
  }

  void _paintLine(Canvas canvas, Size size, double maxVal, double chartHeight, double chartWidth) {
    final stepX = chartWidth / (data.length - 1);
    
    final path = Path();
    final fillPath = Path();
    
    final paint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [primaryColor.withValues(alpha: 0.4), primaryColor.withValues(alpha: 0.0)],
      ).createShader(Rect.fromLTWH(0, 0, chartWidth, chartHeight));

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final h = (data[i].value / maxVal) * chartHeight * progress;
      final y = chartHeight - h;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, chartHeight);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
      
      if (i == data.length - 1) {
        fillPath.lineTo(x, chartHeight);
        fillPath.close();
      }
    }

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // Draw points
    final dotPaint = Paint()..color = Colors.white..style = PaintingStyle.fill;
    final borderPaint = Paint()..color = primaryColor..style = PaintingStyle.stroke..strokeWidth = 2;

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final h = (data[i].value / maxVal) * chartHeight * progress;
      final y = chartHeight - h;

      canvas.drawCircle(Offset(x, y), 5, dotPaint);
      canvas.drawCircle(Offset(x, y), 5, borderPaint);

      if (showLabels) {
        _drawText(canvas, data[i].label, Offset(x, chartHeight + 10), TextAlign.center, stepX);
      }
    }
  }

  void _drawText(Canvas canvas, String text, Offset offset, TextAlign align, double maxWidth, {Color? color, double fontSize = 11}) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color ?? Colors.grey[600],
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: align,
    );
    textPainter.layout(minWidth: 0, maxWidth: maxWidth);
    textPainter.paint(canvas, offset - Offset(textPainter.width / 2, 0));
  }

  @override
  bool shouldRepaint(covariant _ChartPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.data != data || oldDelegate.type != type;
  }
}
