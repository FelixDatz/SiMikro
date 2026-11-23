class InventoryItem {
  const InventoryItem({
    required this.id,
    required this.namaAlat,
    required this.kategori,
    required this.deskripsi,
    required this.stokTotal,
    required this.stokTersedia,
    required this.kondisi,
    this.imageUrl = '',
  });

  final String id;
  final String namaAlat;
  final String kategori;
  final String deskripsi;
  final int stokTotal;
  final int stokTersedia;
  final String kondisi;
  final String imageUrl;

  bool get isAvailable => stokTersedia > 0;

  int get stokDipinjam => (stokTotal - stokTersedia).clamp(0, stokTotal);

  InventoryItem copyWith({
    String? id,
    String? namaAlat,
    String? kategori,
    String? deskripsi,
    int? stokTotal,
    int? stokTersedia,
    String? kondisi,
    String? imageUrl,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      namaAlat: namaAlat ?? this.namaAlat,
      kategori: kategori ?? this.kategori,
      deskripsi: deskripsi ?? this.deskripsi,
      stokTotal: stokTotal ?? this.stokTotal,
      stokTersedia: stokTersedia ?? this.stokTersedia,
      kondisi: kondisi ?? this.kondisi,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nama_alat': namaAlat,
      'kategori': kategori,
      'deskripsi': deskripsi,
      'stok_total': stokTotal,
      'stok_tersedia': stokTersedia,
      'kondisi': kondisi,
      'image_url': imageUrl,
    };
  }
}
