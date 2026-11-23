import 'package:flutter/material.dart';

import '../data/simikro_store.dart';
import '../models/borrowing_record.dart';
import '../utils/date_formatter.dart';
import '../widgets/inventory_catalog_view.dart';
import '../widgets/status_badge.dart';
import 'admin_dashboard_screen.dart';
import 'borrowing_form_screen.dart';
import 'borrowing_main_screen.dart';

enum _HistoryFilter {
  all('Semua'),
  pending('Menunggu'),
  approved('Disetujui'),
  borrowed('Dipinjam'),
  returned('Dikembalikan'),
  other('Lainnya');

  const _HistoryFilter(this.label);
  final String label;
}

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({
    super.key,
    required this.store,
    this.isFirebaseReady = false,
  });

  final SiMikroStore store;
  final bool isFirebaseReady;

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  int _currentIndex = 0;
  _HistoryFilter _historyFilter = _HistoryFilter.all;

  static const _titles = [
    'Dashboard Mahasiswa',
    'Katalog Inventaris',
    'Riwayat Peminjaman',
    'Profil Mahasiswa',
  ];

  void _openBorrowingMain() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BorrowingMainScreen(store: widget.store),
      ),
    );
  }

  void _openBorrowForm({String? itemId}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BorrowingFormScreen(
          store: widget.store,
          initialItemId: itemId,
        ),
      ),
    );
  }

  Future<void> _confirmCancel(BorrowingRecord record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Batalkan Pengajuan?'),
          content: Text(
            'Pengajuan peminjaman ${record.namaAlat} (${record.jumlah} unit) akan dibatalkan.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Kembali'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Ya, Batalkan'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) return;

    final error = widget.store.cancelBorrowing(record.id);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(error ?? 'Pengajuan peminjaman dibatalkan.'),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_currentIndex])),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: widget.store,
          builder: (context, _) {
            return switch (_currentIndex) {
              0 => _buildHomeTab(context),
              1 => InventoryCatalogView(store: widget.store),
              2 => _buildHistoryTab(context),
              _ => _buildProfileTab(context),
            };
          },
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Katalog',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            selectedIcon: Icon(Icons.history),
            label: 'Riwayat',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final student = widget.store.studentUser;
    final myBorrowings = widget.store.borrowingsForUser(student.id);

    final pendingCount =
        myBorrowings.where((b) => b.status == BorrowingStatus.pending).length;
    final borrowedCount =
        myBorrowings.where((b) => b.status == BorrowingStatus.borrowed).length;
    final returnedCount =
        myBorrowings.where((b) => b.status == BorrowingStatus.returned).length;

    final recentBorrowings = myBorrowings.take(3).toList();
    final availableItems =
        widget.store.items.where((item) => item.isAvailable).take(3).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
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
                      radius: 24,
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      child: const Icon(Icons.school_outlined),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Halo, ${student.name}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'NIM ${student.nim} • ${student.role.label}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _openBorrowingMain,
                        icon: const Icon(Icons.inventory_2_outlined, size: 18),
                        label: const Text('Ajukan Peminjaman'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton.icon(
                      onPressed: () => _openBorrowForm(),
                      icon: const Icon(Icons.edit_note, size: 18),
                      label: const Text('Form'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _MiniStatCard(
                label: 'Pending',
                value: '$pendingCount',
                color: Colors.orange.shade800,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MiniStatCard(
                label: 'Dipinjam',
                value: '$borrowedCount',
                color: Colors.indigo.shade700,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MiniStatCard(
                label: 'Selesai',
                value: '$returnedCount',
                color: Colors.green.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(
              child: Text(
                'Peminjaman Aktif & Terbaru',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () => setState(() => _currentIndex = 2),
              child: const Text('Lihat Semua'),
            ),
          ],
        ),
        const SizedBox(height: 6),
        if (recentBorrowings.isEmpty)
          const Card(
            elevation: 0,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Belum ada riwayat peminjaman.'),
            ),
          )
        else
          ...recentBorrowings.map(
            (record) => Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: colorScheme.outlineVariant),
              ),
              child: ListTile(
                title: Text(
                  record.namaAlat,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  '${record.jumlah} unit • ${formatDateRange(record.tanggalPinjam, record.tanggalKembali)}',
                ),
                trailing: BorrowingStatusBadge(status: record.status),
              ),
            ),
          ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Text(
                'Alat Tersedia',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () => setState(() => _currentIndex = 1),
              child: const Text('Lihat Katalog'),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ...availableItems.map(
          (item) => Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: colorScheme.outlineVariant),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: colorScheme.primaryContainer,
                foregroundColor: colorScheme.onPrimaryContainer,
                child: Icon(categoryIcon(item.kategori)),
              ),
              title: Text(
                item.namaAlat,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                '${item.kategori} • Tersedia ${item.stokTersedia}/${item.stokTotal}',
              ),
              trailing: FilledButton.tonal(
                onPressed: () => _openBorrowForm(itemId: item.id),
                child: const Text('Pinjam'),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryTab(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final myBorrowings =
        widget.store.borrowingsForUser(widget.store.studentUser.id);

    final filtered = myBorrowings.where((record) {
      return switch (_historyFilter) {
        _HistoryFilter.all => true,
        _HistoryFilter.pending => record.status == BorrowingStatus.pending,
        _HistoryFilter.approved => record.status == BorrowingStatus.approved,
        _HistoryFilter.borrowed => record.status == BorrowingStatus.borrowed,
        _HistoryFilter.returned => record.status == BorrowingStatus.returned,
        _HistoryFilter.other => record.status == BorrowingStatus.rejected ||
            record.status == BorrowingStatus.cancelled,
      };
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _HistoryFilter.values.map((filter) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(filter.label),
                  selected: _historyFilter == filter,
                  onSelected: (_) => setState(() => _historyFilter = filter),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 14),
        if (filtered.isEmpty)
          Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.history_toggle_off,
                    size: 40,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Belum ada transaksi pada filter ini.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          ...filtered.map(
            (record) => Card(
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                record.namaAlat,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${record.jumlah} unit • ${formatDateRange(record.tanggalPinjam, record.tanggalKembali)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        BorrowingStatusBadge(status: record.status),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Alasan: ${record.alasan}',
                      style: theme.textTheme.bodySmall,
                    ),
                    if (record.isOverdue) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Perhatian: Peminjaman melewati batas tanggal pengembalian.',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    if (record.catatanAdmin != null &&
                        record.catatanAdmin!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Catatan Admin: ${record.catatanAdmin}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                    if (record.status == BorrowingStatus.returned &&
                        record.tanggalDikembalikan != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Dikembalikan ${formatDate(record.tanggalDikembalikan!)} • Kondisi: ${record.kondisiKembali ?? '-'}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    if (record.status == BorrowingStatus.pending) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () => _confirmCancel(record),
                          icon: Icon(
                            Icons.cancel_outlined,
                            size: 18,
                            color: Colors.red.shade700,
                          ),
                          label: Text(
                            'Batalkan Pengajuan',
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProfileTab(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final student = widget.store.studentUser;
    final total = widget.store.borrowingsForUser(student.id).length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: colorScheme.primaryContainer,
                  foregroundColor: colorScheme.onPrimaryContainer,
                  child: const Icon(Icons.person, size: 32),
                ),
                const SizedBox(height: 12),
                Text(
                  student.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'NIM ${student.nim} • ${student.email}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    Chip(
                      avatar: const Icon(Icons.badge_outlined, size: 16),
                      label: Text('Peran: ${student.role.label}'),
                    ),
                    Chip(
                      avatar: const Icon(Icons.receipt_long_outlined, size: 16),
                      label: Text('$total Total Pengajuan'),
                    ),
                    Chip(
                      avatar: Icon(
                        widget.isFirebaseReady
                            ? Icons.cloud_done_outlined
                            : Icons.cloud_outlined,
                        size: 16,
                      ),
                      label: Text(
                        widget.isFirebaseReady
                            ? 'Firebase Terhubung'
                            : 'Mode Pratinjau',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: colorScheme.outlineVariant),
          ),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.assignment_add),
                title: const Text('Halaman Utama Peminjaman'),
                subtitle: const Text('Buka katalog dan pengajuan alat'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _openBorrowingMain,
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.admin_panel_settings_outlined),
                title: const Text('Beralih ke Dashboard Admin'),
                subtitle: const Text('Lihat mode pengelola inventaris'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => AdminDashboardScreen(
                        store: widget.store,
                        isFirebaseReady: widget.isFirebaseReady,
                      ),
                    ),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.home_outlined),
                title: const Text('Kembali ke Beranda Awal'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        child: Column(
          children: [
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
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
      ),
    );
  }
}
