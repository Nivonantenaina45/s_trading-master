import 'dart:core';

class ColisModel {
  String? colisid;
  String? tracking;
  String? codeClient;
  double? poids;
  double? volume;
  int? frais;
  String? modeEnvoie;
  String? etat;
  int? facture;

  ColisModel({
    this.colisid,
    this.tracking,
    this.codeClient,
    this.poids,
    this.volume,
    this.frais,
    this.modeEnvoie,
    this.etat,
    this.facture,
  });
  factory ColisModel.fromMap(map) {
    return ColisModel(
        colisid: map['colisid'],
        tracking: map['tracking'],
        codeClient: map['codeClient'],
        poids: map['poids'],
        volume: map['volume'],
        frais: map['frais'],
        modeEnvoie: map['modeEnvoie'],
        etat: map['etat'],
        facture: map['facture']);
  }
  Map<String, dynamic> toMap() {
    return {
      'colisid': colisid,
      'tracking': tracking,
      'codeClient': codeClient,
      'poids': poids,
      'volume': volume,
      'frais': frais,
      'modeEnvoie': modeEnvoie,
      'etat': etat,
      'facture': facture,
    };
  }
}
