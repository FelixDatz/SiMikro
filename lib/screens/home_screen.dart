import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.isFirebaseReady = false});

  final bool isFirebaseReady;

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('$feature sedang dalam pengembangan.')),
      );
  }

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
        child: SingleChildScrollView(
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
              const SizedBox(height: 24),
              Text(
                'Menu Utama',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              _MenuCard(
                icon: Icons.category_outlined,
                title: 'Katalog Inventaris',
                subtitle: 'Lihat daftar alat dan ketersediaan stok',
                onTap: () => _showComingSoon(context, 'Fitur Katalog Inventaris'),
              ),
              const SizedBox(height: 10),
              _MenuCard(
                icon: Icons.assignment_outlined,
                title: 'Ajukan Peminjaman',
                subtitle: 'Buat pengajuan peminjaman inventaris',
                onTap: () => _showComingSoon(context, 'Fitur Pengajuan Peminjaman'),
              ),
              const SizedBox(height: 10),
              _MenuCard(
                icon: Icons.history,
                title: 'Riwayat Peminjaman',
                subtitle: 'Pantau status dan jadwal pengembalian',
                onTap: () => _showComingSoon(context, 'Fitur Riwayat Peminjaman'),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => _showComingSoon(context, 'Halaman Masuk'),
                icon: const Icon(Icons.login),
                label: const Text('Masuk'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => _showComingSoon(context, 'Halaman Daftar Akun'),
                icon: const Icon(Icons.person_add_outlined),
                label: const Text('Daftar Akun'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: ListTile(
        leading: Icon(icon, color: colorScheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
