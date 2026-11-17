import 'package:pm_tugas_04_4243250005/kendaraan.dart';
import 'package:pm_tugas_04_4243250005/parkiran.dart';
import 'package:test/test.dart';

void main() {
  group('Kendaraan.biaya', () {
    final waktuMasuk = DateTime(2026, 1, 1, 8);

    test('charges at least one hour and rounds partial hours up', () {
      final motor = Motor(plat: 'bk1234ab', waktuMasuk: waktuMasuk);

      expect(motor.biaya(waktuMasuk), 6000);
      expect(motor.biaya(waktuMasuk.add(const Duration(minutes: 30))), 6000);
      expect(motor.biaya(waktuMasuk.add(const Duration(hours: 1))), 6000);
      expect(
        motor.biaya(waktuMasuk.add(const Duration(hours: 1, milliseconds: 1))),
        12000,
      );
      expect(motor.plat, 'BK1234AB');
      expect(
        Truk(plat: 'BK99TR', waktuMasuk: waktuMasuk)
            .biaya(waktuMasuk.add(const Duration(hours: 1))),
        30000,
      );
    });

    test('rejects an exit time before entry', () {
      final mobil = Mobil(plat: 'BK88UN', waktuMasuk: waktuMasuk);

      expect(
        () => mobil.biaya(waktuMasuk.subtract(const Duration(minutes: 1))),
        throwsArgumentError,
      );
    });
  });

  group('Berlangganan', () {
    test('applies a 50 percent discount to the full parking fee once', () {
      final waktuMasuk = DateTime(2026, 1, 1, 8);
      final member = MobilBerlangganan(
        plat: 'BK7MIPA',
        waktuMasuk: waktuMasuk,
      );

      expect(
        member.biaya(waktuMasuk.add(const Duration(hours: 2))),
        15000,
      );
    });
  });

  group('Parkiran', () {
    test('reports full capacity, broadcasts events, and tracks revenue',
        () async {
      final parkiran = Parkiran(kapasitas: 1);
      final kejadian = <String>[];
      final langganan = parkiran.kejadian.listen(kejadian.add);
      final waktuMasuk = DateTime(2026, 1, 1, 8);
      final motor = Motor(plat: 'BK1234AB', waktuMasuk: waktuMasuk);

      await parkiran.masuk(motor);
      expect(parkiran.sisa, 0);

      await expectLater(
        parkiran.masuk(Mobil(plat: 'BK88UN', waktuMasuk: waktuMasuk)),
        throwsA(isA<ParkirPenuh>()),
      );

      final biaya = await parkiran.keluar(
        motor.plat,
        waktuMasuk.add(const Duration(hours: 1)),
      );
      expect(biaya, 6000);
      expect(parkiran.pendapatan, 6000);
      expect(parkiran.sisa, 1);

      await parkiran.tutup();
      await langganan.cancel();

      expect(kejadian, [
        'MASUK Motor BK1234AB (sisa 0)',
        'KELUAR Motor BK1234AB bayar Rp6000',
      ]);
    });

    test('does not exceed capacity when arrivals race', () async {
      final parkiran = Parkiran(kapasitas: 1);
      final waktuMasuk = DateTime(2026, 1, 1, 8);
      final hasil = await Future.wait<Object?>([
        parkiran
            .masuk(Motor(plat: 'BK1234AB', waktuMasuk: waktuMasuk))
            .then<Object?>((_) => null, onError: (Object error) => error),
        parkiran
            .masuk(Mobil(plat: 'BK88UN', waktuMasuk: waktuMasuk))
            .then<Object?>((_) => null, onError: (Object error) => error),
      ]);

      expect(hasil.whereType<ParkirPenuh>(), hasLength(1));
      expect(parkiran.sisa, 0);
      await parkiran.tutup();
    });
  });
}
