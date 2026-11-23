import 'package:flutter/material.dart';

import '../data/simikro_store.dart';
import '../models/inventory_item.dart';
import '../utils/date_formatter.dart';
import '../widgets/status_badge.dart';

class BorrowingFormScreen extends StatefulWidget {
  const BorrowingFormScreen({
    super.key,
    required this.store,
    this.initialItemId,
  });

  final SiMikroStore store;
  final String? initialItemId;

  @override
  State<BorrowingFormScreen> createState() => _BorrowingFormScreenState();
}

class _BorrowingFormScreenState extends State<BorrowingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();

  late String _selectedItemId;
  int _jumlah = 1;
  late DateTime _tanggalPinjam;
  late DateTime _tanggalKembali;

  @override
  void initState() {
    super.initState();
    final today = dateOnly(DateTime.now());
    _tanggalPinjam = today;
    _tanggalKembali = today.add(const Duration(days: 1));

    final items = widget.store.items;
    if (widget.initialItemId != null &&
        widget.store.findItemById(widget.initialItemId!) != null) {
      _selectedItemId = widget.initialItemId!;
    } else {
      final firstAvailable = items.where((item) => item.isAvailable).toList();
      _selectedItemId = firstAvailable.isNotEmpty
          ? firstAvailable.first.id
          : items.first.id;
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final today = dateOnly(DateTime.now());
    final firstDate = isStart ? today : _tanggalPinjam;
    final initialDate = isStart ? _tanggalPinjam : _tanggalKembali;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(firstDate) ? firstDate : initialDate,
      firstDate: firstDate,
      lastDate: today.add(const Duration(days: 180)),
    );
    if (!mounted || picked == null) return;

    setState(() {
      if (isStart) {
        _tanggalPinjam = dateOnly(picked);
        if (_tanggalKembali.isBefore(_tanggalPinjam)) {
          _tanggalKembali = _tanggalPinjam;
        }
      } else {
        _tanggalKembali = dateOnly(picked);
      }
    });
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final error = widget.store.submitBorrowing(
      user: widget.store.studentUser,
      itemId: _selectedItemId,
      jumlah: _jumlah,
      tanggalPinjam: _tanggalPinjam,
      tanggalKembali: _tanggalKembali,
      alasan: _reasonController.text,
    );

    if (error != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Pengajuan peminjaman berhasil dikirim.'),
        ),
      );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final student = widget.store.studentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Form Peminjaman')),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: widget.store,
          builder: (context, _) {
            final items = widget.store.items;
            final selectedItem =
                widget.store.findItemById(_selectedItemId) ?? items.first;
            final scheduleCheck = widget.store.checkScheduleConflict(
              itemId: selectedItem.id,
              jumlah: _jumlah,
              tanggalPinjam: _tanggalPinjam,
              tanggalKembali: _tanggalKembali,
            );
            final maxStepper =
                selectedItem.stokTotal > 0 ? selectedItem.stokTotal : 1;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      elevation: 0,
                      color: colorScheme.surfaceContainerLow,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: colorScheme.primaryContainer,
                          foregroundColor: colorScheme.onPrimaryContainer,
                          child: const Icon(Icons.person_outline),
                        ),
                        title: Text(student.name),
                        subtitle: Text('NIM ${student.nim} • ${student.email}'),
                      ),
                    ),
                    const SizedBox(height: 18),
                    DropdownButtonFormField<String>(
                      initialValue: selectedItem.id,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Pilih Alat Inventaris',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.inventory_2_outlined),
                      ),
                      items: items
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item.id,
                              child: Text(
                                '${item.namaAlat} (Tersedia ${item.stokTersedia}/${item.stokTotal})',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _selectedItemId = value;
                          _jumlah = 1;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    _SelectedItemInfo(item: selectedItem),
                    const SizedBox(height: 18),
                    Text(
                      'Jumlah Peminjaman',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colorScheme.outlineVariant),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: _jumlah > 1
                                ? () => setState(() => _jumlah--)
                                : null,
                            icon: const Icon(Icons.remove_circle_outline),
                            tooltip: 'Kurangi jumlah',
                          ),
                          Expanded(
                            child: Text(
                              '$_jumlah unit',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: _jumlah < maxStepper
                                ? () => setState(() => _jumlah++)
                                : null,
                            icon: const Icon(Icons.add_circle_outline),
                            tooltip: 'Tambah jumlah',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Jadwal Peminjaman',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _DateFieldCard(
                            label: 'Tanggal Pinjam',
                            value: formatDate(_tanggalPinjam),
                            onTap: () => _pickDate(isStart: true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _DateFieldCard(
                            label: 'Tanggal Kembali',
                            value: formatDate(_tanggalKembali),
                            onTap: () => _pickDate(isStart: false),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _ScheduleStatusBanner(result: scheduleCheck),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _reasonController,
                      maxLines: 3,
                      textInputAction: TextInputAction.newline,
                      decoration: const InputDecoration(
                        labelText: 'Alasan / Tujuan Peminjaman',
                        hintText:
                            'Contoh: Digunakan untuk seminar atau praktikum HMP Mikroptik',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().length < 5) {
                          return 'Jelaskan alasan peminjaman minimal 5 karakter.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: scheduleCheck.isValid ? _submit : null,
                      icon: const Icon(Icons.send_outlined),
                      label: const Text('Ajukan Peminjaman'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SelectedItemInfo extends StatelessWidget {
  const _SelectedItemInfo({required this.item});

  final InventoryItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
            '${item.kategori} • ${item.deskripsi}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _DateFieldCard extends StatelessWidget {
  const _DateFieldCard({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
        ),
        child: Text(value, style: theme.textTheme.bodyMedium),
      ),
    );
  }
}

class _ScheduleStatusBanner extends StatelessWidget {
  const _ScheduleStatusBanner({required this.result});

  final ScheduleCheckResult result;

  @override
  Widget build(BuildContext context) {
    final color =
        result.isValid ? Colors.green.shade700 : Colors.red.shade700;
    final icon =
        result.isValid ? Icons.event_available : Icons.event_busy_outlined;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              result.message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
