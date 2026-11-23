import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../models/borrowing_record.dart';
import '../models/inventory_item.dart';
import '../models/user_model.dart';
import '../utils/date_formatter.dart';

class ScheduleCheckResult {
  const ScheduleCheckResult({
    required this.isValid,
    required this.message,
    required this.reservedOnRange,
    required this.maxAvailableForRange,
  });

  final bool isValid;
  final String message;
  final int reservedOnRange;
  final int maxAvailableForRange;
}

class SiMikroStore extends ChangeNotifier {
  SiMikroStore() {
    _seedInitialData();
  }

  final UserModel studentUser = UserModel(
    id: 'usr_mhs_01',
    name: 'Felix Trinidat',
    nim: 'K3522028',
    email: 'felix@student.uns.ac.id',
    role: UserRole.student,
    createdAt: DateTime(2026, 9, 1),
  );

  final UserModel adminUser = UserModel(
    id: 'usr_adm_01',
    name: 'Eka Putra Noandheli',
    nim: 'K3522021',
    email: 'admin.mikroptik@uns.ac.id',
    role: UserRole.admin,
    createdAt: DateTime(2026, 9, 1),
  );

  final List<InventoryItem> _items = [];
  final List<BorrowingRecord> _borrowings = [];
  int _nextBorrowingSeq = 9;
  int _nextItemSeq = 7;

  void _seedInitialData() {
    final today = dateOnly(DateTime.now());

    _items.addAll(const [
      InventoryItem(
        id: 'itm_01',
        namaAlat: 'Proyektor Epson EB-X500',
        kategori: 'Audio & Visual',
        deskripsi:
            'Proyektor XGA 3600 lumens lengkap dengan kabel HDMI, VGA, dan tas pembawa.',
        stokTotal: 3,
        stokTersedia: 2,
        kondisi: 'Baik',
      ),
      InventoryItem(
        id: 'itm_02',
        namaAlat: 'Kamera Canon EOS M50',
        kategori: 'Dokumentasi',
        deskripsi:
            'Kamera mirrorless lensa kit 15-45mm, baterai cadangan, dan memori 64GB.',
        stokTotal: 2,
        stokTersedia: 1,
        kondisi: 'Baik',
      ),
      InventoryItem(
        id: 'itm_03',
        namaAlat: 'Tripod Takara Eco-193A',
        kategori: 'Dokumentasi',
        deskripsi:
            'Tripod aluminium tinggi maksimal 140 cm dengan quick release plate.',
        stokTotal: 4,
        stokTersedia: 4,
        kondisi: 'Baik',
      ),
      InventoryItem(
        id: 'itm_04',
        namaAlat: 'Speaker Portable Huper 15"',
        kategori: 'Audio & Visual',
        deskripsi:
            'Speaker aktif portable untuk acara seminar, rapat besar, dan kegiatan outdoor.',
        stokTotal: 2,
        stokTersedia: 2,
        kondisi: 'Baik',
      ),
      InventoryItem(
        id: 'itm_05',
        namaAlat: 'Mikrofon Wireless Shure',
        kategori: 'Audio & Visual',
        deskripsi:
            'Set mikrofon nirkabel dual-channel UHF beserta receiver dan adaptor daya.',
        stokTotal: 4,
        stokTersedia: 3,
        kondisi: 'Baik',
      ),
      InventoryItem(
        id: 'itm_06',
        namaAlat: 'Kabel Roll 25 Meter',
        kategori: 'Perlengkapan',
        deskripsi:
            'Kabel rol 4 lubang stopkontak dengan pelindung beban lebih untuk kegiatan lapangan.',
        stokTotal: 5,
        stokTersedia: 4,
        kondisi: 'Perlu Perawatan',
      ),
    ]);

    _borrowings.addAll([
      BorrowingRecord(
        id: 'brw_03',
        userId: studentUser.id,
        namaPeminjam: studentUser.name,
        itemId: 'itm_03',
        namaAlat: 'Tripod Takara Eco-193A',
        jumlah: 2,
        tanggalPinjam: today.add(const Duration(days: 1)),
        tanggalKembali: today.add(const Duration(days: 3)),
        alasan: 'Dokumentasi kegiatan praktikum dan workshop Mikroptik.',
        status: BorrowingStatus.pending,
        createdAt: today.subtract(const Duration(hours: 3)),
      ),
      BorrowingRecord(
        id: 'brw_04',
        userId: 'usr_mhs_02',
        namaPeminjam: 'Yardan Raditya Laksana',
        itemId: 'itm_04',
        namaAlat: 'Speaker Portable Huper 15"',
        jumlah: 1,
        tanggalPinjam: today.add(const Duration(days: 1)),
        tanggalKembali: today.add(const Duration(days: 2)),
        alasan: 'Rapat koordinasi panitia malam keakraban.',
        status: BorrowingStatus.approved,
        catatanAdmin: 'Silakan ambil di sekretariat jam 09.00 WIB.',
        createdAt: today.subtract(const Duration(days: 1)),
      ),
      BorrowingRecord(
        id: 'brw_02',
        userId: studentUser.id,
        namaPeminjam: studentUser.name,
        itemId: 'itm_02',
        namaAlat: 'Kamera Canon EOS M50',
        jumlah: 1,
        tanggalPinjam: today.subtract(const Duration(days: 1)),
        tanggalKembali: today.add(const Duration(days: 2)),
        alasan: 'Peliputan kunjungan industri mahasiswa.',
        status: BorrowingStatus.borrowed,
        catatanAdmin: 'Diserahkan lengkap dengan tas dan baterai cadangan.',
        createdAt: today.subtract(const Duration(days: 2)),
      ),
      BorrowingRecord(
        id: 'brw_01',
        userId: 'usr_mhs_03',
        namaPeminjam: 'Galang Nur Seto',
        itemId: 'itm_01',
        namaAlat: 'Proyektor Epson EB-X500',
        jumlah: 1,
        tanggalPinjam: today.subtract(const Duration(days: 4)),
        tanggalKembali: today.subtract(const Duration(days: 1)),
        alasan: 'Presentasi desain sistem dan evaluasi proker.',
        status: BorrowingStatus.borrowed,
        catatanAdmin: 'Mohon segera dikembalikan ke ruang inventaris.',
        createdAt: today.subtract(const Duration(days: 5)),
      ),
      BorrowingRecord(
        id: 'brw_05',
        userId: 'usr_mhs_04',
        namaPeminjam: 'Narendra Lintang Saputra',
        itemId: 'itm_05',
        namaAlat: 'Mikrofon Wireless Shure',
        jumlah: 1,
        tanggalPinjam: today,
        tanggalKembali: today.add(const Duration(days: 3)),
        alasan: 'Seminar pengembangan teknologi optik.',
        status: BorrowingStatus.borrowed,
        catatanAdmin: 'Sudah dicek baterai dan receiver berfungsi baik.',
        createdAt: today.subtract(const Duration(days: 1)),
      ),
      BorrowingRecord(
        id: 'brw_07',
        userId: 'usr_mhs_05',
        namaPeminjam: 'Aulia Rahma',
        itemId: 'itm_06',
        namaAlat: 'Kabel Roll 25 Meter',
        jumlah: 1,
        tanggalPinjam: today,
        tanggalKembali: today.add(const Duration(days: 4)),
        alasan: 'Kebutuhan daya booth pameran UKM.',
        status: BorrowingStatus.borrowed,
        catatanAdmin: 'Gunakan sesuai kapasitas daya maksimal.',
        createdAt: today.subtract(const Duration(days: 1)),
      ),
      BorrowingRecord(
        id: 'brw_06',
        userId: studentUser.id,
        namaPeminjam: studentUser.name,
        itemId: 'itm_05',
        namaAlat: 'Mikrofon Wireless Shure',
        jumlah: 2,
        tanggalPinjam: today.subtract(const Duration(days: 9)),
        tanggalKembali: today.subtract(const Duration(days: 7)),
        tanggalDikembalikan: today.subtract(const Duration(days: 7)),
        alasan: 'Sidang pleno pengurus HMP Mikroptik.',
        status: BorrowingStatus.returned,
        catatanAdmin: 'Diterima lengkap tanpa kendala.',
        kondisiKembali: 'Baik',
        createdAt: today.subtract(const Duration(days: 10)),
      ),
      BorrowingRecord(
        id: 'brw_08',
        userId: 'usr_mhs_02',
        namaPeminjam: 'Yardan Raditya Laksana',
        itemId: 'itm_06',
        namaAlat: 'Kabel Roll 25 Meter',
        jumlah: 3,
        tanggalPinjam: today.subtract(const Duration(days: 6)),
        tanggalKembali: today.subtract(const Duration(days: 5)),
        alasan: 'Acara bazar luar kampus.',
        status: BorrowingStatus.rejected,
        catatanAdmin: 'Jadwal berbenturan dengan kegiatan wajib himpunan.',
        createdAt: today.subtract(const Duration(days: 7)),
      ),
    ]);
  }

  UnmodifiableListView<InventoryItem> get items => UnmodifiableListView(_items);

  UnmodifiableListView<BorrowingRecord> get borrowings =>
      UnmodifiableListView(_borrowings);

  List<String> get categories {
    final unique = <String>{for (final item in _items) item.kategori};
    return ['Semua', ...unique];
  }

  int get totalItemTypes => _items.length;

  int get totalStockUnits =>
      _items.fold(0, (sum, item) => sum + item.stokTotal);

  int get totalAvailableUnits =>
      _items.fold(0, (sum, item) => sum + item.stokTersedia);

  int get pendingCount =>
      _borrowings.where((b) => b.status == BorrowingStatus.pending).length;

  int get approvedCount =>
      _borrowings.where((b) => b.status == BorrowingStatus.approved).length;

  int get borrowedCount =>
      _borrowings.where((b) => b.status == BorrowingStatus.borrowed).length;

  int get overdueCount => _borrowings.where((b) => b.isOverdue).length;

  InventoryItem? findItemById(String id) {
    for (final item in _items) {
      if (item.id == id) return item;
    }
    return null;
  }

  List<BorrowingRecord> borrowingsForUser(String userId) {
    return _borrowings.where((b) => b.userId == userId).toList(growable: false);
  }

  List<BorrowingRecord> activeScheduleForItem(String itemId) {
    return _borrowings
        .where(
          (b) =>
              b.itemId == itemId &&
              (b.status == BorrowingStatus.approved ||
                  b.status == BorrowingStatus.borrowed),
        )
        .toList(growable: false);
  }

  ScheduleCheckResult checkScheduleConflict({
    required String itemId,
    required int jumlah,
    required DateTime tanggalPinjam,
    required DateTime tanggalKembali,
  }) {
    final item = findItemById(itemId);
    if (item == null) {
      return const ScheduleCheckResult(
        isValid: false,
        message: 'Alat tidak ditemukan.',
        reservedOnRange: 0,
        maxAvailableForRange: 0,
      );
    }

    if (jumlah <= 0) {
      return ScheduleCheckResult(
        isValid: false,
        message: 'Jumlah peminjaman minimal 1 unit.',
        reservedOnRange: 0,
        maxAvailableForRange: item.stokTersedia,
      );
    }

    final start = dateOnly(tanggalPinjam);
    final end = dateOnly(tanggalKembali);
    if (end.isBefore(start)) {
      return ScheduleCheckResult(
        isValid: false,
        message: 'Tanggal kembali tidak boleh sebelum tanggal pinjam.',
        reservedOnRange: 0,
        maxAvailableForRange: item.stokTersedia,
      );
    }

    var reservedOnRange = 0;
    for (final record in _borrowings) {
      if (record.itemId != itemId) continue;
      if (record.status != BorrowingStatus.approved &&
          record.status != BorrowingStatus.borrowed) {
        continue;
      }
      final recStart = dateOnly(record.tanggalPinjam);
      final recEnd = dateOnly(record.tanggalKembali);
      final overlaps = !(recEnd.isBefore(start) || recStart.isAfter(end));
      if (overlaps) {
        reservedOnRange += record.jumlah;
      }
    }

    final maxForSchedule =
        (item.stokTotal - reservedOnRange).clamp(0, item.stokTotal);
    final maxAvailable =
        maxForSchedule < item.stokTersedia ? maxForSchedule : item.stokTersedia;

    if (jumlah > item.stokTersedia) {
      return ScheduleCheckResult(
        isValid: false,
        message:
            'Jumlah melebihi stok tersedia saat ini (${item.stokTersedia} unit).',
        reservedOnRange: reservedOnRange,
        maxAvailableForRange: maxAvailable,
      );
    }

    if (reservedOnRange + jumlah > item.stokTotal) {
      return ScheduleCheckResult(
        isValid: false,
        message:
            'Jadwal bentrok: $reservedOnRange unit sudah terjadwal pada tanggal tersebut (maksimal $maxAvailable unit).',
        reservedOnRange: reservedOnRange,
        maxAvailableForRange: maxAvailable,
      );
    }

    return ScheduleCheckResult(
      isValid: true,
      message:
          'Jadwal tersedia ($maxAvailable unit dapat dipinjam pada rentang tanggal ini).',
      reservedOnRange: reservedOnRange,
      maxAvailableForRange: maxAvailable,
    );
  }

  String? submitBorrowing({
    required UserModel user,
    required String itemId,
    required int jumlah,
    required DateTime tanggalPinjam,
    required DateTime tanggalKembali,
    required String alasan,
  }) {
    final trimmedReason = alasan.trim();
    if (trimmedReason.isEmpty) {
      return 'Alasan peminjaman wajib diisi.';
    }

    final check = checkScheduleConflict(
      itemId: itemId,
      jumlah: jumlah,
      tanggalPinjam: tanggalPinjam,
      tanggalKembali: tanggalKembali,
    );
    if (!check.isValid) {
      return check.message;
    }

    final item = findItemById(itemId)!;
    final id = 'brw_${_nextBorrowingSeq.toString().padLeft(2, '0')}';
    _nextBorrowingSeq++;

    _borrowings.insert(
      0,
      BorrowingRecord(
        id: id,
        userId: user.id,
        namaPeminjam: user.name,
        itemId: item.id,
        namaAlat: item.namaAlat,
        jumlah: jumlah,
        tanggalPinjam: dateOnly(tanggalPinjam),
        tanggalKembali: dateOnly(tanggalKembali),
        alasan: trimmedReason,
        status: BorrowingStatus.pending,
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
    return null;
  }

  String? cancelBorrowing(String borrowingId) {
    final index = _borrowings.indexWhere((b) => b.id == borrowingId);
    if (index == -1) return 'Transaksi tidak ditemukan.';
    final record = _borrowings[index];
    if (record.status != BorrowingStatus.pending) {
      return 'Hanya pengajuan berstatus menunggu yang dapat dibatalkan.';
    }
    _borrowings[index] = record.copyWith(status: BorrowingStatus.cancelled);
    notifyListeners();
    return null;
  }

  String? approveBorrowing(String borrowingId, {String? catatanAdmin}) {
    final index = _borrowings.indexWhere((b) => b.id == borrowingId);
    if (index == -1) return 'Transaksi tidak ditemukan.';
    final record = _borrowings[index];
    if (record.status != BorrowingStatus.pending) {
      return 'Hanya pengajuan menunggu yang dapat disetujui.';
    }

    final item = findItemById(record.itemId);
    if (item == null || record.jumlah > item.stokTersedia) {
      return 'Stok tersedia saat ini tidak mencukupi untuk menyetujui pengajuan ini.';
    }

    final note = catatanAdmin?.trim();
    _borrowings[index] = record.copyWith(
      status: BorrowingStatus.approved,
      catatanAdmin: note != null && note.isNotEmpty ? note : record.catatanAdmin,
    );
    notifyListeners();
    return null;
  }

  String? rejectBorrowing(String borrowingId, {required String catatanAdmin}) {
    final index = _borrowings.indexWhere((b) => b.id == borrowingId);
    if (index == -1) return 'Transaksi tidak ditemukan.';
    final record = _borrowings[index];
    if (record.status != BorrowingStatus.pending) {
      return 'Hanya pengajuan menunggu yang dapat ditolak.';
    }

    final note = catatanAdmin.trim();
    _borrowings[index] = record.copyWith(
      status: BorrowingStatus.rejected,
      catatanAdmin:
          note.isNotEmpty ? note : 'Pengajuan ditolak oleh admin inventaris.',
    );
    notifyListeners();
    return null;
  }

  String? handOverBorrowing(String borrowingId, {String? catatanAdmin}) {
    final index = _borrowings.indexWhere((b) => b.id == borrowingId);
    if (index == -1) return 'Transaksi tidak ditemukan.';
    final record = _borrowings[index];
    if (record.status != BorrowingStatus.approved) {
      return 'Serah terima hanya dapat dilakukan untuk pengajuan yang sudah disetujui.';
    }

    final itemIndex = _items.indexWhere((i) => i.id == record.itemId);
    if (itemIndex == -1) return 'Data alat tidak ditemukan.';
    final item = _items[itemIndex];
    if (item.stokTersedia < record.jumlah) {
      return 'Stok alat (${item.stokTersedia} unit) tidak cukup untuk serah terima.';
    }

    _items[itemIndex] = item.copyWith(
      stokTersedia: item.stokTersedia - record.jumlah,
    );

    final note = catatanAdmin?.trim();
    _borrowings[index] = record.copyWith(
      status: BorrowingStatus.borrowed,
      catatanAdmin: note != null && note.isNotEmpty ? note : record.catatanAdmin,
    );
    notifyListeners();
    return null;
  }

  String? returnBorrowing(
    String borrowingId, {
    required String kondisiKembali,
    String? catatanAdmin,
  }) {
    final index = _borrowings.indexWhere((b) => b.id == borrowingId);
    if (index == -1) return 'Transaksi tidak ditemukan.';
    final record = _borrowings[index];
    if (record.status != BorrowingStatus.borrowed) {
      return 'Pengembalian hanya berlaku untuk barang yang sedang dipinjam.';
    }

    final itemIndex = _items.indexWhere((i) => i.id == record.itemId);
    if (itemIndex == -1) return 'Data alat tidak ditemukan.';
    final item = _items[itemIndex];

    final restoredStock =
        (item.stokTersedia + record.jumlah).clamp(0, item.stokTotal);
    _items[itemIndex] = item.copyWith(
      stokTersedia: restoredStock,
      kondisi: kondisiKembali == 'Baik' ? item.kondisi : kondisiKembali,
    );

    final note = catatanAdmin?.trim();
    _borrowings[index] = record.copyWith(
      status: BorrowingStatus.returned,
      tanggalDikembalikan: DateTime.now(),
      kondisiKembali: kondisiKembali,
      catatanAdmin: note != null && note.isNotEmpty ? note : record.catatanAdmin,
    );
    notifyListeners();
    return null;
  }

  void addInventoryItem({
    required String namaAlat,
    required String kategori,
    required String deskripsi,
    required int stokTotal,
    required String kondisi,
    String imageUrl = '',
  }) {
    final id = 'itm_${_nextItemSeq.toString().padLeft(2, '0')}';
    _nextItemSeq++;

    _items.add(
      InventoryItem(
        id: id,
        namaAlat: namaAlat.trim(),
        kategori: kategori.trim(),
        deskripsi: deskripsi.trim(),
        stokTotal: stokTotal,
        stokTersedia: stokTotal,
        kondisi: kondisi.trim(),
        imageUrl: imageUrl.trim(),
      ),
    );
    notifyListeners();
  }

  void updateInventoryItem(InventoryItem updated) {
    final index = _items.indexWhere((item) => item.id == updated.id);
    if (index == -1) return;
    _items[index] = updated.copyWith(
      stokTersedia: updated.stokTersedia.clamp(0, updated.stokTotal),
    );
    notifyListeners();
  }
}
