class TaxAnalysisModel {
  final int id;
  final int userId;
  final int tahunPajak;
  final double penghasilanBulanan;
  final double penghasilanTidakTeratur;
  final double biayaJabatan;
  final double iuranPensiun;
  final double zakat;
  final double kreditPajak;
  final String statusWajibPajak;
  final String metodePerhitungan;
  final double estimasiPajak;
  final TaxResultModel hasilJson;
  final String createdAt;

  TaxAnalysisModel({
    required this.id,
    required this.userId,
    required this.tahunPajak,
    required this.penghasilanBulanan,
    required this.penghasilanTidakTeratur,
    required this.biayaJabatan,
    required this.iuranPensiun,
    required this.zakat,
    required this.kreditPajak,
    required this.statusWajibPajak,
    required this.metodePerhitungan,
    required this.estimasiPajak,
    required this.hasilJson,
    required this.createdAt,
  });

  factory TaxAnalysisModel.fromJson(Map<String, dynamic> json) {
    return TaxAnalysisModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      tahunPajak: json['tahun_pajak'] ?? 0,
      penghasilanBulanan: (json['penghasilan_bulanan'] ?? 0).toDouble(),
      penghasilanTidakTeratur: (json['penghasilan_tidak_teratur'] ?? 0).toDouble(),
      biayaJabatan: (json['biaya_jabatan'] ?? 0).toDouble(),
      iuranPensiun: (json['iuran_pensiun'] ?? 0).toDouble(),
      zakat: (json['zakat'] ?? 0).toDouble(),
      kreditPajak: (json['kredit_pajak'] ?? 0).toDouble(),
      statusWajibPajak: json['status_wajib_pajak'] ?? '',
      metodePerhitungan: json['metode_perhitungan'] ?? '',
      estimasiPajak: (json['estimasi_pajak'] ?? 0).toDouble(),
      hasilJson: TaxResultModel.fromJson(json['hasil_json'] ?? {}),
      createdAt: json['created_at'] ?? '',
    );
  }
}

class TaxResultModel {
  final int tahunPajak;
  final String metode;
  final String statusWajibPajak;
  final double penghasilanBulanan;
  final double penghasilanTidakTeratur;
  final double biayaJabatanBulanan;
  final double iuranPensiun;
  final double zakat;
  final double kreditPajak;
  final double penghasilanTahunan;
  final double pengurangTahunan;
  final double penghasilanNeto;
  final double ptkp;
  final double pkp;
  final double estimasiPajakTahunan;
  final double estimasiPajakBulanan;
  final double pajakKurangBayar;
  final String statusPajak;
  final String catatan;
  final List<TaxBreakdownModel> breakdown;
  final String terCategory;
  final double terRate;

  TaxResultModel({
    required this.tahunPajak,
    required this.metode,
    required this.statusWajibPajak,
    required this.penghasilanBulanan,
    required this.penghasilanTidakTeratur,
    required this.biayaJabatanBulanan,
    required this.iuranPensiun,
    required this.zakat,
    required this.kreditPajak,
    required this.penghasilanTahunan,
    required this.pengurangTahunan,
    required this.penghasilanNeto,
    required this.ptkp,
    required this.pkp,
    required this.estimasiPajakTahunan,
    required this.estimasiPajakBulanan,
    required this.pajakKurangBayar,
    required this.statusPajak,
    required this.catatan,
    required this.breakdown,
    required this.terCategory,
    required this.terRate,
  });

  factory TaxResultModel.fromJson(Map<String, dynamic> json) {
    return TaxResultModel(
      tahunPajak: json['tahun_pajak'] ?? 0,
      metode: json['metode'] ?? '',
      statusWajibPajak: json['status_wajib_pajak'] ?? '',
      penghasilanBulanan: (json['penghasilan_bulanan'] ?? 0).toDouble(),
      penghasilanTidakTeratur: (json['penghasilan_tidak_teratur'] ?? 0).toDouble(),
      biayaJabatanBulanan: (json['biaya_jabatan_bulanan'] ?? 0).toDouble(),
      iuranPensiun: (json['iuran_pensiun'] ?? 0).toDouble(),
      zakat: (json['zakat'] ?? 0).toDouble(),
      kreditPajak: (json['kredit_pajak'] ?? 0).toDouble(),
      penghasilanTahunan: (json['penghasilan_tahunan'] ?? 0).toDouble(),
      pengurangTahunan: (json['pengurang_tahunan'] ?? 0).toDouble(),
      penghasilanNeto: (json['penghasilan_neto'] ?? 0).toDouble(),
      ptkp: (json['ptkp'] ?? 0).toDouble(),
      pkp: (json['pkp'] ?? 0).toDouble(),
      estimasiPajakTahunan: (json['estimasi_pajak_tahunan'] ?? 0).toDouble(),
      estimasiPajakBulanan: (json['estimasi_pajak_bulanan'] ?? 0).toDouble(),
      pajakKurangBayar: (json['pajak_kurang_bayar'] ?? 0).toDouble(),
      statusPajak: json['status_pajak'] ?? '',
      catatan: json['catatan'] ?? '',
      breakdown: (json['breakdown'] as List?)
              ?.map((item) => TaxBreakdownModel.fromJson(item))
              .toList() ??
          [],
      terCategory: json['ter_category'] ?? '',
      terRate: (json['ter_rate'] ?? 0).toDouble(),
    );
  }
}

class TaxBreakdownModel {
  final String label;
  final double rate;
  final double taxableAmount;
  final double tax;

  TaxBreakdownModel({
    required this.label,
    required this.rate,
    required this.taxableAmount,
    required this.tax,
  });

  factory TaxBreakdownModel.fromJson(Map<String, dynamic> json) {
    return TaxBreakdownModel(
      label: json['label'] ?? '',
      rate: (json['rate'] ?? 0).toDouble(),
      taxableAmount: (json['taxable_amount'] ?? 0).toDouble(),
      tax: (json['tax'] ?? 0).toDouble(),
    );
  }
}
