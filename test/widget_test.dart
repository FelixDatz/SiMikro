import 'package:flutter_test/flutter_test.dart';

import 'package:simikro/data/simikro_store.dart';
import 'package:simikro/main.dart';
import 'package:simikro/models/borrowing_record.dart';

void main() {
  group('SiMikroStore business rules', () {
    test('handles borrowing lifecycle and updates stock on handover and return', () {
      final store = SiMikroStore();
      final itemBefore = store.findItemById('itm_03')!;
      final initialAvailable = itemBefore.stokTersedia;

      final today = DateTime.now();
      final submitError = store.submitBorrowing(
        user: store.studentUser,
        itemId: 'itm_03',
        jumlah: 2,
        tanggalPinjam: today.add(const Duration(days: 10)),
        tanggalKembali: today.add(const Duration(days: 12)),
        alasan: 'Dokumentasi kegiatan himpunan mahasiswa.',
      );
      expect(submitError, isNull);

      final created = store.borrowings.first;
      expect(created.status, BorrowingStatus.pending);
      expect(store.findItemById('itm_03')!.stokTersedia, initialAvailable);

      expect(
        store.approveBorrowing(created.id, catatanAdmin: 'Siap diambil'),
        isNull,
      );
      expect(store.borrowings.first.status, BorrowingStatus.approved);
      expect(store.findItemById('itm_03')!.stokTersedia, initialAvailable);

      expect(store.handOverBorrowing(created.id), isNull);
      expect(store.borrowings.first.status, BorrowingStatus.borrowed);
      expect(
        store.findItemById('itm_03')!.stokTersedia,
        initialAvailable - 2,
      );

      expect(
        store.returnBorrowing(
          created.id,
          kondisiKembali: 'Baik',
          catatanAdmin: 'Dikembalikan tepat waktu',
        ),
        isNull,
      );
      final returned = store.borrowings.first;
      expect(returned.status, BorrowingStatus.returned);
      expect(returned.kondisiKembali, 'Baik');
      expect(returned.tanggalDikembalikan, isNotNull);
      expect(store.findItemById('itm_03')!.stokTersedia, initialAvailable);
    });

    test('rejects borrowing exceeding available stock and schedule overlap', () {
      final store = SiMikroStore();
      final today = DateTime.now();

      final overStock = store.checkScheduleConflict(
        itemId: 'itm_02',
        jumlah: 5,
        tanggalPinjam: today,
        tanggalKembali: today.add(const Duration(days: 1)),
      );
      expect(overStock.isValid, isFalse);

      // itm_04 has stokTotal 2, stokTersedia 2, and 1 unit already approved
      // for today + 1d .. today + 2d (brw_04).
      final conflict = store.checkScheduleConflict(
        itemId: 'itm_04',
        jumlah: 2,
        tanggalPinjam: today.add(const Duration(days: 1)),
        tanggalKembali: today.add(const Duration(days: 2)),
      );
      expect(conflict.isValid, isFalse);
      expect(conflict.reservedOnRange, 1);
      expect(conflict.maxAvailableForRange, 1);
    });
  });

  group('SiMikro UI navigation tests', () {
    testWidgets('Home screen displays all three entry points', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const SiMikroApp());

      expect(find.text('SiMikro'), findsWidgets);
      expect(find.text('Halaman Utama Peminjaman'), findsOneWidget);
      expect(find.text('Dashboard Mahasiswa'), findsOneWidget);
      expect(find.text('Dashboard Admin'), findsOneWidget);
    });

    testWidgets('Halaman Utama Peminjaman opens catalog and borrowing form', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const SiMikroApp());

      await tester.tap(find.text('Halaman Utama Peminjaman'));
      await tester.pumpAndSettle();

      expect(find.text('Halaman Peminjaman'), findsOneWidget);
      expect(find.text('Proyektor Epson EB-X500'), findsOneWidget);

      await tester.tap(find.text('Ajukan Pinjam'));
      await tester.pumpAndSettle();

      expect(find.text('Form Peminjaman'), findsOneWidget);
      expect(find.text('Ajukan Peminjaman'), findsOneWidget);
    });

    testWidgets('Dashboard Mahasiswa renders and switches all 4 tabs', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const SiMikroApp());

      await tester.tap(find.text('Dashboard Mahasiswa'));
      await tester.pumpAndSettle();

      expect(find.text('Dashboard Mahasiswa'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Katalog'), findsOneWidget);
      expect(find.text('Riwayat'), findsOneWidget);
      expect(find.text('Profil'), findsOneWidget);

      await tester.tap(find.text('Katalog'));
      await tester.pumpAndSettle();
      expect(find.text('Katalog Inventaris'), findsOneWidget);

      await tester.tap(find.text('Riwayat'));
      await tester.pumpAndSettle();
      expect(find.text('Riwayat Peminjaman'), findsOneWidget);

      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();
      expect(find.text('Profil Mahasiswa'), findsOneWidget);
    });

    testWidgets('Dashboard Admin renders and switches all 4 tabs', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const SiMikroApp());

      await tester.ensureVisible(find.text('Dashboard Admin'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dashboard Admin'));
      await tester.pumpAndSettle();

      expect(find.text('Dashboard Admin'), findsOneWidget);
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Permintaan'), findsOneWidget);
      expect(find.text('Inventaris'), findsOneWidget);
      expect(find.text('Profil'), findsOneWidget);

      await tester.tap(find.text('Permintaan'));
      await tester.pumpAndSettle();
      expect(find.text('Permintaan Peminjaman'), findsOneWidget);

      await tester.tap(find.text('Inventaris'));
      await tester.pumpAndSettle();
      expect(find.text('Manajemen Inventaris'), findsOneWidget);

      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();
      expect(find.text('Profil Admin'), findsOneWidget);
    });
  });
}
