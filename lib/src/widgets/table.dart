import 'package:flutter/material.dart';
import '../dsl/fx.dart';

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
class FxTable<T> extends StatelessWidget {
  final List<T> data;
  final List<FxTableColumn<T>> columns;
  final bool striped;
  final VoidCallback? onRowTap;

  const FxTable({
    super.key,
    required this.data,
    required this.columns,
    this.striped = true,
    this.onRowTap,
  });

  @override
  Widget build(BuildContext context) {
    // Responsive wrapping: Horizontal scroll on small screens
    return Fx.box(
      style: const FxStyle(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        border: Border.fromBorderSide(BorderSide(color: Color(0xFFE2E8F0))),
        backgroundColor: Colors.white,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 600), // Min width to trigger scroll
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              _buildHeader(),
              // Rows
              ...data.asMap().entries.map((entry) => _buildRow(entry.key, entry.value)),
            ],
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
        children: columns.map((col) {
          final widget = Text(
            col.header.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF64748B), // Slate 500
              letterSpacing: 0.5,
            ),
          );

          if (col.width != null) {
            return SizedBox(width: col.width, child: widget);
          }
          return Expanded(flex: col.expand ? 1 : 0, child: widget);
        }).toList(),
      ),
    );
  }

  Widget _buildRow(int index, T item) {
    final isStripe = striped && index.isOdd;
    
    return Fx.box(
      style: FxStyle(
        backgroundColor: isStripe ? const Color(0xFFF8FAFC) : Colors.white,
        hover: const FxStyle(backgroundColor: Color(0xFFF1F5F9)), // Hover effect
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: index != data.length - 1 
            ? const Border(bottom: BorderSide(color: Color(0xFFF1F5F9))) 
            : null,
      ),
      child: Row(
        children: columns.map((col) {
          final widget = col.cellBuilder(item);
          if (col.width != null) {
            return SizedBox(width: col.width, child: widget);
          }
          return Expanded(flex: col.expand ? 1 : 0, child: widget);
        }).toList(),
      ),
      onTap: onRowTap,
    );
  }
}
