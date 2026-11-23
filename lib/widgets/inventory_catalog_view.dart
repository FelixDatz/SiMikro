import 'package:flutter/material.dart';

import '../data/simikro_store.dart';
import '../models/inventory_item.dart';
import '../screens/borrowing_form_screen.dart';
import '../utils/date_formatter.dart';
import 'status_badge.dart';

class InventoryCatalogView extends StatefulWidget {
  const InventoryCatalogView({
    super.key,
    required this.store,
    this.header,
  });

  final SiMikroStore store;
  final Widget? header;

  @override
  State<InventoryCatalogView> createState() => _InventoryCatalogViewState();
}

class _InventoryCatalogViewState extends State<InventoryCatalogView> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'Semua';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openBorrowForm(InventoryItem item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BorrowingFormScreen(
          store: widget.store,
          initialItemId: item.id,
        ),
      ),
    );
  }

  void _showItemDetail(BuildContext context, InventoryItem item) {
    final schedules = widget.store.activeScheduleForItem(item.id);
    final theme = Theme.of(context);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        foregroundColor: theme.colorScheme.onPrimaryContainer,
                        child: Icon(categoryIcon(item.kategori)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.namaAlat,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              item.kategori,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
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
                    runSpacing: 6,
                    children: [
                      StockBadge(
                        tersedia: item.stokTersedia,
                        total: item.stokTotal,
                      ),
                      ConditionBadge(kondisi: item.kondisi),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Deskripsi Alat',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(item.deskripsi, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 16),
                  Text(
                    'Informasi Stok',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _DetailCountBox(
                          label: 'Total Stok',
                          value: '${item.stokTotal}',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _DetailCountBox(
                          label: 'Tersedia',
                          value: '${item.stokTersedia}',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _DetailCountBox(
                          label: 'Dipinjam',
                          value: '${item.stokDipinjam}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Jadwal Terpakai (${schedules.length})',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (schedules.isEmpty)
                    Text(
                      'Belum ada jadwal peminjaman aktif untuk alat ini.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    )
                  else
                    ...schedules.map(
                      (rec) => Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 8),
                        color: theme.colorScheme.surfaceContainerLow,
                        child: ListTile(
                          dense: true,
                          title: Text('${rec.namaPeminjam} (${rec.jumlah} unit)'),
                          subtitle: Text(
                            formatDateRange(
                              rec.tanggalPinjam,
                              rec.tanggalKembali,
                            ),
                          ),
                          trailing: BorrowingStatusBadge(status: rec.status),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: item.isAvailable
                        ? () {
                            Navigator.of(sheetContext).pop();
                            _openBorrowForm(item);
                          }
                        : null,
                    icon: const Icon(Icons.assignment_add),
                    label: Text(
                      item.isAvailable
                          ? 'Ajukan Peminjaman Alat Ini'
                          : 'Stok Sedang Habis',
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.store,
      builder: (context, _) {
        final categories = widget.store.categories;
        final query = _searchController.text.trim().toLowerCase();

        final filteredItems = widget.store.items.where((item) {
          final matchCategory =
              _selectedCategory == 'Semua' || item.kategori == _selectedCategory;
          final matchQuery = query.isEmpty ||
              item.namaAlat.toLowerCase().contains(query) ||
              item.deskripsi.toLowerCase().contains(query) ||
              item.kategori.toLowerCase().contains(query);
          return matchCategory && matchQuery;
        }).toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (widget.header != null) ...[
              widget.header!,
              const SizedBox(height: 16),
            ],
            TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Cari nama alat atau deskripsi...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories.map((category) {
                  final selected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(category),
                      selected: selected,
                      onSelected: (_) =>
                          setState(() => _selectedCategory = category),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 14),
            if (filteredItems.isEmpty)
              Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: 40,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tidak ada alat yang cocok dengan pencarian.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              ...filteredItems.map(
                (item) => _InventoryItemCard(
                  item: item,
                  onDetail: () => _showItemDetail(context, item),
                  onBorrow: () => _openBorrowForm(item),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _InventoryItemCard extends StatelessWidget {
  const _InventoryItemCard({
    required this.item,
    required this.onDetail,
    required this.onBorrow,
  });

  final InventoryItem item;
  final VoidCallback onDetail;
  final VoidCallback onBorrow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final stockRatio =
        item.stokTotal == 0 ? 0.0 : item.stokTersedia / item.stokTotal;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: colorScheme.primaryContainer,
                  foregroundColor: colorScheme.onPrimaryContainer,
                  child: Icon(categoryIcon(item.kategori)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.namaAlat,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.kategori,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                StockBadge(
                  tersedia: item.stokTersedia,
                  total: item.stokTotal,
                ),
                ConditionBadge(kondisi: item.kondisi),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              item.deskripsi,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: stockRatio,
                minHeight: 6,
                backgroundColor: colorScheme.surfaceContainerHighest,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onDetail,
                    icon: const Icon(Icons.info_outline, size: 18),
                    label: const Text('Detail'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: item.isAvailable ? onBorrow : null,
                    icon: const Icon(Icons.assignment_add, size: 18),
                    label: const Text('Pinjam'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailCountBox extends StatelessWidget {
  const _DetailCountBox({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
