import 'package:flutter/material.dart';
import '../dsl/fx.dart';
import '../widgets/fx_widget.dart';
import '../engine/style_resolver.dart';

/// Defines a column in FxTable.
class FxTableColumn<T> {
  final String header;
  final Widget Function(T item) cellBuilder;
  final double? width;
  final bool expand;

  const FxTableColumn({
    required this.header,
    required this.cellBuilder,
    this.width,
    this.expand = true,
  });
}

/// A premium, responsive data table.
class FxTable<T> extends FxWidget {
  final List<T> data;
  final List<FxTableColumn<T>> columns;
  final bool striped;
  final VoidCallback? onRowTap;
  final FxStyle style;
  final FxResponsiveStyle? responsive;

  const FxTable({
    super.key,
    super.id,
    super.className,
    required this.data,
    required this.columns,
    this.striped = true,
    this.onRowTap,
    this.style = FxStyle.none,
    this.responsive,
  });

  @override
  FxTable<T> copyWithStyle(FxStyle additionalStyle) {
    return copyWith(style: style.merge(additionalStyle));
  }

  @override
  FxTable<T> copyWithResponsive(FxResponsiveStyle additionalResponsive) {
    return copyWith(
      responsive: responsive?.merge(additionalResponsive) ?? additionalResponsive,
    );
  }

  FxTable<T> copyWith({
    List<T>? data,
    List<FxTableColumn<T>>? columns,
    bool? striped,
    VoidCallback? onRowTap,
    FxStyle? style,
    FxResponsiveStyle? responsive,
    String? className,
  }) {
    return FxTable<T>(
      key: key,
      id: id,
      className: className ?? this.className,
      data: data ?? this.data,
      columns: columns ?? this.columns,
      striped: striped ?? this.striped,
      onRowTap: onRowTap ?? this.onRowTap,
      style: style ?? this.style,
      responsive: responsive ?? this.responsive,
    );
  }

  @override
  State<FxTable<T>> createState() => _FxTableState<T>();
}

class _FxTableState<T> extends State<FxTable<T>> {
  @override
  Widget build(BuildContext context) {
    final s = FxStyleResolver.resolve(
      context,
      style: widget.style,
      className: widget.className,
      responsive: widget.responsive,
    );

    // Responsive wrapping: Horizontal scroll on small screens
    return Fx.box(
      style: const FxStyle(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        border: Border.fromBorderSide(BorderSide(color: Color(0xFFE2E8F0))),
        backgroundColor: Colors.white,
      ).merge(s),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: 600,
          ), // Min width to trigger scroll
          child: IntrinsicWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                _buildHeader(),
                // Rows
                ...widget.data.asMap().entries.map(
                  (entry) => _buildRow(entry.key, entry.value),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF1F5F9), // Slate 100
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: widget.columns.map((col) {
          final widgetChild = Text(
            col.header.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF64748B), // Slate 500
              letterSpacing: 0.5,
            ),
          );

          if (col.width != null) {
            return SizedBox(width: col.width, child: widgetChild);
          }
          return Expanded(flex: col.expand ? 1 : 0, child: widgetChild);
        }).toList(),
      ),
    );
  }

  Widget _buildRow(int index, T item) {
    final isStripe = widget.striped && index.isOdd;

    return Fx.box(
      style: FxStyle(
        backgroundColor: isStripe ? const Color(0xFFF8FAFC) : Colors.white,
        hover: const FxStyle(
          backgroundColor: Color(0xFFF1F5F9),
        ), // Hover effect
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: index != widget.data.length - 1
            ? const Border(bottom: BorderSide(color: Color(0xFFF1F5F9)))
            : null,
      ),
      child: Row(
        children: widget.columns.map((col) {
          final widgetChild = col.cellBuilder(item);
          if (col.width != null) {
            return SizedBox(width: col.width, child: widgetChild);
          }
          return Expanded(flex: col.expand ? 1 : 0, child: widgetChild);
        }).toList(),
      ),
      onTap: widget.onRowTap,
    );
  }
}
