abstract class Kendaraan {
  Kendaraan({required String plat, required this.waktuMasuk})
      : plat = plat.trim().toUpperCase() {
    if (this.plat.isEmpty) {
      throw ArgumentError.value(
          plat, 'plat', 'Plat kendaraan tidak boleh kosong.');
    }
  }

  final String plat;
  final DateTime waktuMasuk;

  String get jenis;
  int get tarifPerJam;

  int biaya(DateTime keluar) {
    if (keluar.isBefore(waktuMasuk)) {
      throw ArgumentError.value(
        keluar,
        'keluar',
        'Waktu keluar tidak boleh sebelum waktu masuk.',
      );
    }

    final durasiMikrodetik = keluar.difference(waktuMasuk).inMicroseconds;
    const mikrodetikPerJam = 3600000000;
    final jamDitagih = durasiMikrodetik == 0
        ? 1
        : (durasiMikrodetik + mikrodetikPerJam - 1) ~/ mikrodetikPerJam;
    return jamDitagih * tarifPerJam;
  }
}

class Motor extends Kendaraan {
  Motor({required super.plat, required super.waktuMasuk});

  @override
  String get jenis => 'Motor';

  @override
  int get tarifPerJam => 6000;
}

class Mobil extends Kendaraan {
  Mobil({required super.plat, required super.waktuMasuk});

  @override
  String get jenis => 'Mobil';

  @override
  int get tarifPerJam => 15000;
}

class Truk extends Kendaraan {
  Truk({required super.plat, required super.waktuMasuk});

  @override
  String get jenis => 'Truk';

  @override
  int get tarifPerJam => 30000;
}

mixin Berlangganan on Kendaraan {
  @override
  int biaya(DateTime keluar) => super.biaya(keluar) ~/ 2;
}

class MobilBerlangganan extends Mobil with Berlangganan {
  MobilBerlangganan({required super.plat, required super.waktuMasuk});

  @override
  String get jenis => 'Mobil (member)';
}

String formatRupiah(int jumlah) => 'Rp$jumlah';
