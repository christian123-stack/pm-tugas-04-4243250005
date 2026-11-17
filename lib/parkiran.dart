import 'dart:async';

import 'kendaraan.dart';

class ParkirPenuh implements Exception {
  const ParkirPenuh(this.kapasitas);

  final int kapasitas;

  @override
  String toString() => 'Parkiran penuh (kapasitas $kapasitas)';
}

class Parkiran {
  Parkiran({required this.kapasitas}) {
    if (kapasitas < 1) {
      throw ArgumentError.value(
        kapasitas,
        'kapasitas',
        'Kapasitas harus lebih besar dari nol.',
      );
    }
  }

  static const _durasiPalang = Duration(milliseconds: 150);

  final int kapasitas;
  final Map<String, Kendaraan> _kendaraan = {};
  final StreamController<String> _streamController =
      StreamController<String>.broadcast();
  int _pendapatan = 0;
  bool _ditutup = false;

  int get sisa => kapasitas - _kendaraan.length;
  int get pendapatan => _pendapatan;
  Stream<String> get kejadian => _streamController.stream;

  Future<void> masuk(Kendaraan kendaraan) async {
    _pastikanAktif();
    await Future<void>.delayed(_durasiPalang);
    _pastikanAktif();

    if (sisa == 0) {
      throw ParkirPenuh(kapasitas);
    }
    if (_kendaraan.containsKey(kendaraan.plat)) {
      throw StateError('Plat ${kendaraan.plat} sudah berada di parkiran.');
    }

    _kendaraan[kendaraan.plat] = kendaraan;
    _streamController.add(
      'MASUK ${kendaraan.jenis} ${kendaraan.plat} (sisa $sisa)',
    );
  }

  Future<int> keluar(String plat, DateTime waktuKeluar) async {
    _pastikanAktif();
    final platNormal = plat.trim().toUpperCase();
    final kendaraan = _kendaraan[platNormal];
    if (kendaraan == null) {
      throw StateError('Kendaraan dengan plat $platNormal tidak ditemukan.');
    }

    final biaya = kendaraan.biaya(waktuKeluar);
    await Future<void>.delayed(_durasiPalang);
    _pastikanAktif();

    final kendaraanKeluar = _kendaraan.remove(platNormal);
    if (kendaraanKeluar == null) {
      throw StateError('Kendaraan dengan plat $platNormal tidak ditemukan.');
    }

    _pendapatan += biaya;
    _streamController.add(
      'KELUAR ${kendaraanKeluar.jenis} ${kendaraanKeluar.plat} '
      'bayar ${formatRupiah(biaya)}',
    );
    return biaya;
  }

  Future<void> tutup() {
    if (_ditutup) {
      return Future<void>.value();
    }
    _ditutup = true;
    return _streamController.close();
  }

  void _pastikanAktif() {
    if (_ditutup) {
      throw StateError('Parkiran sudah ditutup.');
    }
  }
}
