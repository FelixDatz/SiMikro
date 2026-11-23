import 'package:flutter/material.dart';

import '../data/simikro_store.dart';
import 'admin_dashboard_screen.dart';
import 'borrowing_main_screen.dart';
import 'user_dashboard_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.store,
    this.isFirebaseReady = false,
  });

  final SiMikroStore store;
  final bool isFirebaseReady;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SiMikro'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: store,
          builder: (context, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 0,
                    color: colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: colorScheme.primary,
                                foregroundColor: colorScheme.onPrimary,
                                child: const Icon(Icons.inventory_2_rounded),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'SiMikro',
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.onPrimaryContainer,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Sistem Informasi Peminjaman Inventaris Mikroptik',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: colorScheme.onPrimaryContainer,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isFirebaseReady
                                      ? Icons.cloud_done_outlined
                                      : Icons.cloud_outlined,
                                  size: 16,
                                  color: isFirebaseReady
                                      ? Colors.green.shade700
                                      : colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  isFirebaseReady
                                      ? 'Firebase Terhubung'
                                      : 'Mode Pratinjau',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: isFirebaseReady
                                        ? Colors.green.shade700
                                        : colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickStatPill(
                          label: 'Jenis Alat',
                          value: '${store.totalItemTypes}',
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _QuickStatPill(
                          label: 'Unit Tersedia',
                          value: '${store.totalAvailableUnits}',
                          color: Colors.green.shade700,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _QuickStatPill(
                          label: 'Pending',
                          value: '${store.pendingCount}',
                          color: Colors.orange.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Akses Halaman Aplikasi',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _EntryCard(
                    icon: Icons.assignment_add,
                    title: 'Halaman Utama Peminjaman',
                    subtitle:
                        'Katalog alat, cek jadwal pemakaian, dan form pengajuan peminjaman',
                    accentColor: colorScheme.primary,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BorrowingMainScreen(store: store),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  _EntryCard(
                    icon: Icons.school_outlined,
                    title: 'Dashboard Mahasiswa',
                    subtitle:
                        'Home, Katalog, Riwayat peminjaman, dan Profil mahasiswa',
                    accentColor: Colors.teal.shade700,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => UserDashboardScreen(
                            store: store,
                            isFirebaseReady: isFirebaseReady,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  _EntryCard(
                    icon: Icons.admin_panel_settings_outlined,
                    title: 'Dashboard Admin',
                    subtitle:
                        'Kelola permintaan, serah terima, pengembalian, dan inventaris',
                    accentColor: Colors.indigo.shade700,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AdminDashboardScreen(
                            store: store,
                            isFirebaseReady: isFirebaseReady,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _QuickStatPill extends StatelessWidget {
  const _QuickStatPill({
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
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
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
              textAlign: TextAlign.center,
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

class _EntryCard extends StatelessWidget {
  const _EntryCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accentColor;
  final VoidCallback onTap;

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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: accentColor),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(subtitle),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
