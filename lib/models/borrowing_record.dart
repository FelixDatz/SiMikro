import '../utils/date_formatter.dart';

enum BorrowingStatus {
  pending,
  approved,
  borrowed,
  returned,
  rejected,
  cancelled;

  String get label {
    switch (this) {
      case BorrowingStatus.pending:
        return 'Menunggu';
      case BorrowingStatus.approved:
        return 'Disetujui';
      case BorrowingStatus.borrowed:
        return 'Dipinjam';
      case BorrowingStatus.returned:
        return 'Dikembalikan';
      case BorrowingStatus.rejected:
        return 'Ditolak';
      case BorrowingStatus.cancelled:
        return 'Dibatalkan';
    }
  }

  String get firestoreValue => name;
}

class BorrowingRecord {
  const BorrowingRecord({
    required this.id,
    required this.userId,
    required this.namaPeminjam,
    required this.itemId,
    required this.namaAlat,
    required this.jumlah,
    required this.tanggalPinjam,
    required this.tanggalKembali,
    this.tanggalDikembalikan,
    required this.alasan,
    required this.status,
    this.catatanAdmin,
    this.kondisiKembali,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String namaPeminjam;
  final String itemId;
  final String namaAlat;
  final int jumlah;
  final DateTime tanggalPinjam;
  final DateTime tanggalKembali;
  final DateTime? tanggalDikembalikan;
  final String alasan;
  final BorrowingStatus status;
  final String? catatanAdmin;
  final String? kondisiKembali;
  final DateTime createdAt;

  bool get isOverdue {
    if (status != BorrowingStatus.borrowed) return false;
    final today = dateOnly(DateTime.now());
    return today.isAfter(dateOnly(tanggalKembali));
  }

  BorrowingRecord copyWith({
    String? id,
    String? userId,
    String? namaPeminjam,
    String? itemId,
    String? namaAlat,
    int? jumlah,
    DateTime? tanggalPinjam,
    DateTime? tanggalKembali,
    DateTime? tanggalDikembalikan,
    String? alasan,
    BorrowingStatus? status,
    String? catatanAdmin,
    String? kondisiKembali,
    DateTime? createdAt,
  }) {
    return BorrowingRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      namaPeminjam: namaPeminjam ?? this.namaPeminjam,
      itemId: itemId ?? this.itemId,
      namaAlat: namaAlat ?? this.namaAlat,
      jumlah: jumlah ?? this.jumlah,
      tanggalPinjam: tanggalPinjam ?? this.tanggalPinjam,
      tanggalKembali: tanggalKembali ?? this.tanggalKembali,
      tanggalDikembalikan: tanggalDikembalikan ?? this.tanggalDikembalikan,
      alasan: alasan ?? this.alasan,
      status: status ?? this.status,
      catatanAdmin: catatanAdmin ?? this.catatanAdmin,
      kondisiKembali: kondisiKembali ?? this.kondisiKembali,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'nama_peminjam': namaPeminjam,
      'item_id': itemId,
      'nama_alat': namaAlat,
      'jumlah': jumlah,
      'tanggal_pinjam': tanggalPinjam.toIso8601String(),
      'tanggal_kembali': tanggalKembali.toIso8601String(),
      'tanggal_dikembalikan': tanggalDikembalikan?.toIso8601String(),
      'alasan': alasan,
      'status': status.firestoreValue,
      'catatan_admin': catatanAdmin,
      'kondisi_kembali': kondisiKembali,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
