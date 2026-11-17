import 'dart:io';

import 'package:pm_tugas_04_4243250005/kendaraan.dart';
import 'package:pm_tugas_04_4243250005/parkiran.dart';

Future<void> main() async {
  final parkiran = Parkiran(kapasitas: 3);
  final langganan = parkiran.kejadian.listen(stdout.writeln);
  final waktuMasuk = DateTime.now();

  final kendaraan = <Kendaraan>[
    Motor(plat: 'BK1234AB', waktuMasuk: waktuMasuk),
    Mobil(plat: 'BK88UN', waktuMasuk: waktuMasuk),
    MobilBerlangganan(plat: 'BK7MIPA', waktuMasuk: waktuMasuk),
    Truk(plat: 'BK99TR', waktuMasuk: waktuMasuk),
  ];

  for (final item in kendaraan.take(3)) {
    await parkiran.masuk(item);
  }

  try {
    await parkiran.masuk(kendaraan.last);
  } on ParkirPenuh catch (error) {
    stdout.writeln('Ditolak: $error');
  }

  final waktuKeluar = waktuMasuk.add(const Duration(hours: 1));
  for (final item in kendaraan.take(3)) {
    await parkiran.keluar(item.plat, waktuKeluar);
  }

  await parkiran.tutup();
  await langganan.cancel();
  stdout.writeln('Pendapatan: ${formatRupiah(parkiran.pendapatan)}');
}
