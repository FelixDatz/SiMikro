import 'package:flutter/material.dart';

import '../data/simikro_store.dart';
import '../widgets/inventory_catalog_view.dart';
import 'borrowing_form_screen.dart';

class BorrowingMainScreen extends StatelessWidget {
  const BorrowingMainScreen({super.key, required this.store});

  final SiMikroStore store;

  void _openBorrowForm(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BorrowingFormScreen(store: store),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Halaman Peminjaman'),
        actions: [
          IconButton(
            onPressed: () => _openBorrowForm(context),
            tooltip: 'Ajukan Peminjaman',
            icon: const Icon(Icons.assignment_add),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openBorrowForm(context),
        icon: const Icon(Icons.add_box_outlined),
        label: const Text('Ajukan Pinjam'),
      ),
      body: SafeArea(
        child: InventoryCatalogView(
          store: store,
          header: _BorrowingHeroCard(
            store: store,
            onQuickBorrow: () => _openBorrowForm(context),
          ),
        ),
      ),
    );
  }
}

class _BorrowingHeroCard extends StatelessWidget {
  const _BorrowingHeroCard({
    required this.store,
    required this.onQuickBorrow,
  });

  final SiMikroStore store;
  final VoidCallback onQuickBorrow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  child: const Icon(Icons.inventory_2_rounded),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Peminjaman Inventaris HMP Mikroptik',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Pilih alat dari katalog, periksa jadwal, lalu ajukan peminjaman.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _HeroMetricChip(
                  icon: Icons.category_outlined,
                  label: '${store.totalItemTypes} Jenis Alat',
                ),
                _HeroMetricChip(
                  icon: Icons.check_circle_outline,
                  label: '${store.totalAvailableUnits} Unit Tersedia',
                ),
                _HeroMetricChip(
                  icon: Icons.schedule,
                  label: '${store.pendingCount} Menunggu Persetujuan',
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surface.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: const [
                  Expanded(
                    child: _StepIndicator(
                      number: '1',
                      label: 'Pilih Alat',
                    ),
                  ),
                  Icon(Icons.chevron_right, size: 18),
                  Expanded(
                    child: _StepIndicator(
                      number: '2',
                      label: 'Isi Jadwal',
                    ),
                  ),
                  Icon(Icons.chevron_right, size: 18),
                  Expanded(
                    child: _StepIndicator(
                      number: '3',
                      label: 'Verifikasi Admin',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onQuickBorrow,
                icon: const Icon(Icons.assignment_outlined),
                label: const Text('Buka Form Peminjaman'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroMetricChip extends StatelessWidget {
  const _HeroMetricChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.number, required this.label});

  final String number;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 10,
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          child: Text(
            number,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
