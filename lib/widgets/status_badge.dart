import 'package:flutter/material.dart';

import '../models/borrowing_record.dart';

IconData categoryIcon(String kategori) {
  final lower = kategori.toLowerCase();
  if (lower.contains('audio') || lower.contains('visual')) {
    return Icons.speaker_outlined;
  }
  if (lower.contains('dokumentasi') || lower.contains('kamera')) {
    return Icons.camera_alt_outlined;
  }
  if (lower.contains('perlengkapan') || lower.contains('kabel')) {
    return Icons.electrical_services_outlined;
  }
  return Icons.inventory_2_outlined;
}

class BorrowingStatusBadge extends StatelessWidget {
  const BorrowingStatusBadge({super.key, required this.status});

  final BorrowingStatus status;

  @override
  Widget build(BuildContext context) {
    final (Color color, IconData icon) = switch (status) {
      BorrowingStatus.pending => (Colors.orange.shade800, Icons.schedule),
      BorrowingStatus.approved => (
        Colors.blue.shade700,
        Icons.check_circle_outline,
      ),
      BorrowingStatus.borrowed => (
        Colors.indigo.shade700,
        Icons.inventory_2_outlined,
      ),
      BorrowingStatus.returned => (
        Colors.green.shade700,
        Icons.assignment_turned_in_outlined,
      ),
      BorrowingStatus.rejected => (Colors.red.shade700, Icons.cancel_outlined),
      BorrowingStatus.cancelled => (Colors.grey.shade700, Icons.block),
    };

    return _StatusPill(label: status.label, color: color, icon: icon);
  }
}

class ConditionBadge extends StatelessWidget {
  const ConditionBadge({super.key, required this.kondisi});

  final String kondisi;

  @override
  Widget build(BuildContext context) {
    final lower = kondisi.toLowerCase();
    final Color color;
    final IconData icon;

    if (lower == 'baik') {
      color = Colors.green.shade700;
      icon = Icons.verified_outlined;
    } else if (lower.contains('perawatan')) {
      color = Colors.orange.shade800;
      icon = Icons.build_circle_outlined;
    } else {
      color = Colors.red.shade700;
      icon = Icons.report_problem_outlined;
    }

    return _StatusPill(label: kondisi, color: color, icon: icon);
  }
}

class StockBadge extends StatelessWidget {
  const StockBadge({
    super.key,
    required this.tersedia,
    required this.total,
  });

  final int tersedia;
  final int total;

  @override
  Widget build(BuildContext context) {
    final String label;
    final Color color;
    final IconData icon;

    if (tersedia <= 0) {
      label = 'Habis 0/$total';
      color = Colors.red.shade700;
      icon = Icons.remove_shopping_cart_outlined;
    } else if (tersedia == 1) {
      label = 'Terbatas $tersedia/$total';
      color = Colors.orange.shade800;
      icon = Icons.inventory_outlined;
    } else {
      label = 'Tersedia $tersedia/$total';
      color = Colors.green.shade700;
      icon = Icons.check_box_outlined;
    }

    return _StatusPill(label: label, color: color, icon: icon);
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle,
    required this.accentColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? subtitle;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: accentColor),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
