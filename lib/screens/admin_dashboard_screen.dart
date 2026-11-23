import 'package:flutter/material.dart';

import '../data/simikro_store.dart';
import '../models/borrowing_record.dart';
import '../models/inventory_item.dart';
import '../utils/date_formatter.dart';
import '../widgets/status_badge.dart';
import 'borrowing_main_screen.dart';
import 'user_dashboard_screen.dart';

enum _AdminRequestFilter {
  all('Semua'),
  pending('Pending'),
  approved('Serah Terima'),
  borrowed('Dipinjam'),
  history('Riwayat');

  const _AdminRequestFilter(this.label);
  final String label;
}

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({
    super.key,
    required this.store,
    this.isFirebaseReady = false,
  });

  final SiMikroStore store;
  final bool isFirebaseReady;

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;
  _AdminRequestFilter _requestFilter = _AdminRequestFilter.all;
  final _inventorySearchController = TextEditingController();

  static const _titles = [
    'Dashboard Admin',
    'Permintaan Peminjaman',
    'Manajemen Inventaris',
    'Profil Admin',
  ];

  static const _defaultCategories = [
    'Audio & Visual',
    'Dokumentasi',
    'Elektronik',
    'Perlengkapan',
  ];

  static const _conditionOptions = [
    'Baik',
    'Perlu Perawatan',
    'Rusak Ringan',
  ];

  @override
  void dispose() {
    _inventorySearchController.dispose();
    super.dispose();
  }

  void _showFeedback(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _showDecisionDialog(
    BorrowingRecord record, {
    required bool approve,
  }) async {
    final noteController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(approve ? 'Setujui Peminjaman' : 'Tolak Peminjaman'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${record.namaPeminjam} mengajukan ${record.jumlah} unit ${record.namaAlat}.',
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: noteController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: approve
                        ? 'Catatan Admin (opsional)'
                        : 'Alasan Penolakan',
                    hintText: approve
                        ? 'Contoh: Ambil di sekretariat mulai pukul 09.00'
                        : 'Contoh: Alat digunakan untuk agenda wajib himpunan',
                    border: const OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(approve ? 'Setujui' : 'Tolak'),
            ),
          ],
        );
      },
    );

    final note = noteController.text;
    noteController.dispose();

    if (!mounted || confirmed != true) return;

    final error = approve
        ? widget.store.approveBorrowing(record.id, catatanAdmin: note)
        : widget.store.rejectBorrowing(record.id, catatanAdmin: note);

    _showFeedback(
      error ??
          (approve
              ? 'Pengajuan disetujui dan siap serah terima.'
              : 'Pengajuan peminjaman ditolak.'),
    );
  }

  Future<void> _showHandOverDialog(BorrowingRecord record) async {
    final noteController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Serah Terima'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Serahkan ${record.jumlah} unit ${record.namaAlat} kepada ${record.namaPeminjam}? '
                  'Stok tersedia akan berkurang otomatis sesuai jumlah pinjaman.',
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: noteController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Catatan Serah Terima (opsional)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Serahkan Alat'),
            ),
          ],
        );
      },
    );

    final note = noteController.text;
    noteController.dispose();

    if (!mounted || confirmed != true) return;

    final error =
        widget.store.handOverBorrowing(record.id, catatanAdmin: note);
    _showFeedback(
      error ?? 'Serah terima dicatat. Stok tersedia telah diperbarui.',
    );
  }

  Future<void> _showReturnDialog(BorrowingRecord record) async {
    final noteController = TextEditingController();
    var selectedCondition = 'Baik';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Catat Pengembalian Alat'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Terima kembali ${record.jumlah} unit ${record.namaAlat} dari ${record.namaPeminjam}.',
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Kondisi Alat Saat Dikembalikan',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: const ['Baik', 'Rusak Ringan', 'Rusak Berat']
                          .map((option) {
                        return ChoiceChip(
                          label: Text(option),
                          selected: selectedCondition == option,
                          onSelected: (_) => setDialogState(
                            () => selectedCondition = option,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: noteController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Catatan Pengembalian (opsional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Batal'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Selesaikan'),
                ),
              ],
            );
          },
        );
      },
    );

    final note = noteController.text;
    noteController.dispose();

    if (!mounted || confirmed != true) return;

    final error = widget.store.returnBorrowing(
      record.id,
      kondisiKembali: selectedCondition,
      catatanAdmin: note,
    );
    _showFeedback(
      error ?? 'Pengembalian berhasil dicatat dan stok telah dikembalikan.',
    );
  }

  Future<void> _showInventoryFormDialog({InventoryItem? existing}) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: existing?.namaAlat ?? '');
    final descController = TextEditingController(
      text: existing?.deskripsi ?? '',
    );
    final totalController = TextEditingController(
      text: existing != null ? '${existing.stokTotal}' : '1',
    );
    final availableController = TextEditingController(
      text: existing != null ? '${existing.stokTersedia}' : '1',
    );

    var selectedCategory = existing?.kategori ?? _defaultCategories.first;
    var selectedCondition = existing?.kondisi ?? _conditionOptions.first;

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(existing == null ? 'Tambah Alat Baru' : 'Edit Alat'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Alat',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Nama alat wajib diisi.'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Kategori',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: _defaultCategories.map((cat) {
                          return ChoiceChip(
                            label: Text(cat),
                            selected: selectedCategory == cat,
                            onSelected: (_) =>
                                setDialogState(() => selectedCategory = cat),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: descController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Deskripsi Alat',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Deskripsi wajib diisi.'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: totalController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Stok Total',
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) {
                                final parsed = int.tryParse(v?.trim() ?? '');
                                if (parsed == null || parsed <= 0) {
                                  return 'Minimal 1';
                                }
                                return null;
                              },
                            ),
                          ),
                          if (existing != null) ...[
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: availableController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Stok Tersedia',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (v) {
                                  final avail = int.tryParse(v?.trim() ?? '');
                                  final total = int.tryParse(
                                        totalController.text.trim(),
                                      ) ??
                                      0;
                                  if (avail == null ||
                                      avail < 0 ||
                                      avail > total) {
                                    return '0 - $total';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Kondisi Alat',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: _conditionOptions.map((cond) {
                          return ChoiceChip(
                            label: Text(cond),
                            selected: selectedCondition == cond,
                            onSelected: (_) =>
                                setDialogState(() => selectedCondition = cond),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Batal'),
                ),
                FilledButton(
                  onPressed: () {
                    if (formKey.currentState?.validate() ?? false) {
                      Navigator.of(dialogContext).pop(true);
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );

    final nama = nameController.text.trim();
    final deskripsi = descController.text.trim();
    final stokTotal = int.tryParse(totalController.text.trim()) ?? 1;
    final stokTersedia =
        int.tryParse(availableController.text.trim()) ?? stokTotal;

    nameController.dispose();
    descController.dispose();
    totalController.dispose();
    availableController.dispose();

    if (!mounted || saved != true) return;

    if (existing == null) {
      widget.store.addInventoryItem(
        namaAlat: nama,
        kategori: selectedCategory,
        deskripsi: deskripsi,
        stokTotal: stokTotal,
        kondisi: selectedCondition,
      );
      _showFeedback('Alat "$nama" berhasil ditambahkan ke inventaris.');
    } else {
      widget.store.updateInventoryItem(
        existing.copyWith(
          namaAlat: nama,
          kategori: selectedCategory,
          deskripsi: deskripsi,
          stokTotal: stokTotal,
          stokTersedia: stokTersedia,
          kondisi: selectedCondition,
        ),
      );
      _showFeedback('Data alat "$nama" berhasil diperbarui.');
    }
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
              0 => _buildDashboardTab(context),
              1 => _buildRequestsTab(context),
              2 => _buildInventoryTab(context),
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
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Permintaan',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_outlined),
            selectedIcon: Icon(Icons.inventory),
            label: 'Inventaris',
          ),
          NavigationDestination(
            icon: Icon(Icons.admin_panel_settings_outlined),
            selectedIcon: Icon(Icons.admin_panel_settings),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardTab(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final admin = widget.store.adminUser;

    final pendingList = widget.store.borrowings
        .where((b) => b.status == BorrowingStatus.pending)
        .toList();
    final activeHandoverList = widget.store.borrowings
        .where(
          (b) =>
              b.status == BorrowingStatus.approved ||
              b.status == BorrowingStatus.borrowed,
        )
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 0,
          color: colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  child: const Icon(Icons.admin_panel_settings_outlined),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dashboard Admin SiMikro',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${admin.name} • Pengelola Inventaris HMP Mikroptik',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: MetricCard(
                icon: Icons.category_outlined,
                label: 'Total Inventaris',
                value: '${widget.store.totalItemTypes} alat',
                subtitle: '${widget.store.totalStockUnits} total unit',
                accentColor: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: MetricCard(
                icon: Icons.check_box_outlined,
                label: 'Stok Tersedia',
                value: '${widget.store.totalAvailableUnits} unit',
                subtitle: 'Siap dipinjam',
                accentColor: Colors.green.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: MetricCard(
                icon: Icons.pending_actions,
                label: 'Perlu Persetujuan',
                value: '${widget.store.pendingCount}',
                subtitle: 'Status pending',
                accentColor: Colors.orange.shade800,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: MetricCard(
                icon: Icons.sync_alt,
                label: 'Sedang Dipinjam',
                value: '${widget.store.borrowedCount}',
                subtitle: widget.store.overdueCount > 0
                    ? '${widget.store.overdueCount} terlambat kembali'
                    : 'Semua tepat waktu',
                accentColor: widget.store.overdueCount > 0
                    ? Colors.red.shade700
                    : Colors.indigo.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(
              child: Text(
                'Menunggu Persetujuan (${pendingList.length})',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () => setState(() {
                _requestFilter = _AdminRequestFilter.pending;
                _currentIndex = 1;
              }),
              child: const Text('Kelola'),
            ),
          ],
        ),
        const SizedBox(height: 6),
        if (pendingList.isEmpty)
          const Card(
            elevation: 0,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Tidak ada pengajuan yang menunggu persetujuan.'),
            ),
          )
        else
          ...pendingList.map(
            (record) => _TransactionActionCard(
              record: record,
              onApprove: () => _showDecisionDialog(record, approve: true),
              onReject: () => _showDecisionDialog(record, approve: false),
              onHandOver: () => _showHandOverDialog(record),
              onReturn: () => _showReturnDialog(record),
            ),
          ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Text(
                'Serah Terima & Pengembalian (${activeHandoverList.length})',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () => setState(() {
                _requestFilter = _AdminRequestFilter.all;
                _currentIndex = 1;
              }),
              child: const Text('Semua'),
            ),
          ],
        ),
        const SizedBox(height: 6),
        if (activeHandoverList.isEmpty)
          const Card(
            elevation: 0,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Belum ada serah terima atau pengembalian aktif.'),
            ),
          )
        else
          ...activeHandoverList.map(
            (record) => _TransactionActionCard(
              record: record,
              onApprove: () => _showDecisionDialog(record, approve: true),
              onReject: () => _showDecisionDialog(record, approve: false),
              onHandOver: () => _showHandOverDialog(record),
              onReturn: () => _showReturnDialog(record),
            ),
          ),
      ],
    );
  }

  Widget _buildRequestsTab(BuildContext context) {
    final borrowings = widget.store.borrowings.where((record) {
      return switch (_requestFilter) {
        _AdminRequestFilter.all => true,
        _AdminRequestFilter.pending => record.status == BorrowingStatus.pending,
        _AdminRequestFilter.approved =>
          record.status == BorrowingStatus.approved,
        _AdminRequestFilter.borrowed =>
          record.status == BorrowingStatus.borrowed,
        _AdminRequestFilter.history =>
          record.status == BorrowingStatus.returned ||
              record.status == BorrowingStatus.rejected ||
              record.status == BorrowingStatus.cancelled,
      };
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _AdminRequestFilter.values.map((filter) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(filter.label),
                  selected: _requestFilter == filter,
                  onSelected: (_) => setState(() => _requestFilter = filter),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 14),
        if (borrowings.isEmpty)
          const Card(
            elevation: 0,
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Tidak ada transaksi peminjaman pada kategori ini.',
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          ...borrowings.map(
            (record) => _TransactionActionCard(
              record: record,
              onApprove: () => _showDecisionDialog(record, approve: true),
              onReject: () => _showDecisionDialog(record, approve: false),
              onHandOver: () => _showHandOverDialog(record),
              onReturn: () => _showReturnDialog(record),
            ),
          ),
      ],
    );
  }

  Widget _buildInventoryTab(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final query = _inventorySearchController.text.trim().toLowerCase();

    final items = widget.store.items.where((item) {
      if (query.isEmpty) return true;
      return item.namaAlat.toLowerCase().contains(query) ||
          item.kategori.toLowerCase().contains(query) ||
          item.kondisi.toLowerCase().contains(query);
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _inventorySearchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Cari alat inventaris...',
                  prefixIcon: const Icon(Icons.search),
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            FilledButton.icon(
              onPressed: () => _showInventoryFormDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Tambah'),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ...items.map(
          (item) => Card(
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
                            Text(
                              item.kategori,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () =>
                            _showInventoryFormDialog(existing: item),
                        tooltip: 'Edit alat',
                        icon: const Icon(Icons.edit_outlined),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
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
                  const SizedBox(height: 8),
                  Text(
                    item.deskripsi,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
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
    final admin = widget.store.adminUser;

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
                  child: const Icon(Icons.admin_panel_settings, size: 32),
                ),
                const SizedBox(height: 12),
                Text(
                  admin.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  admin.email,
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
                      avatar: const Icon(Icons.verified_user_outlined, size: 16),
                      label: Text('Peran: ${admin.role.label}'),
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
                subtitle: const Text('Buka tampilan peminjaman mahasiswa'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BorrowingMainScreen(store: widget.store),
                    ),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.school_outlined),
                title: const Text('Beralih ke Dashboard Mahasiswa'),
                subtitle: const Text('Lihat tampilan sisi peminjam'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => UserDashboardScreen(
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

class _TransactionActionCard extends StatelessWidget {
  const _TransactionActionCard({
    required this.record,
    required this.onApprove,
    required this.onReject,
    required this.onHandOver,
    required this.onReturn,
  });

  final BorrowingRecord record;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onHandOver;
  final VoidCallback onReturn;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
                      const SizedBox(height: 2),
                      Text(
                        '${record.namaPeminjam} • ${record.jumlah} unit',
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
            const SizedBox(height: 8),
            Text(
              'Jadwal: ${formatDateRange(record.tanggalPinjam, record.tanggalKembali)}',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Alasan: ${record.alasan}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (record.isOverdue) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.shade700.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Terlambat dikembalikan (melewati ${formatDate(record.tanggalKembali)})',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            if (record.catatanAdmin != null &&
                record.catatanAdmin!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Catatan: ${record.catatanAdmin}',
                style: theme.textTheme.bodySmall,
              ),
            ],
            if (record.status == BorrowingStatus.returned &&
                record.tanggalDikembalikan != null) ...[
              const SizedBox(height: 6),
              Text(
                'Dikembalikan ${formatDate(record.tanggalDikembalikan!)} • Kondisi: ${record.kondisiKembali ?? '-'}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            if (record.status == BorrowingStatus.pending) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onReject,
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Tolak'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onApprove,
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Setujui'),
                    ),
                  ),
                ],
              ),
            ] else if (record.status == BorrowingStatus.approved) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onHandOver,
                  icon: const Icon(Icons.handshake_outlined, size: 18),
                  label: const Text('Serah Terima Barang'),
                ),
              ),
            ] else if (record.status == BorrowingStatus.borrowed) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonalIcon(
                  onPressed: onReturn,
                  icon: const Icon(Icons.assignment_return_outlined, size: 18),
                  label: const Text('Catat Pengembalian'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
