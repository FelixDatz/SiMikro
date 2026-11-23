import 'package:flutter_test/flutter_test.dart';

import 'package:simikro/main.dart';

void main() {
  testWidgets('SiMikro home screen renders initial UI', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SiMikroApp());

    expect(find.text('SiMikro'), findsWidgets);
    expect(
      find.text('Sistem Informasi Peminjaman Inventaris Mikroptik'),
      findsOneWidget,
    );
    expect(find.text('Katalog Inventaris'), findsOneWidget);
    expect(find.text('Ajukan Peminjaman'), findsOneWidget);
    expect(find.text('Riwayat Peminjaman'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
    expect(find.text('Daftar Akun'), findsOneWidget);
  });
}
