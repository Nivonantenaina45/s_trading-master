import 'dart:core';

class ColisModel {
  int?id;
  String? tracking;
  String? codeClient;
  double? poids;
  double? volume;
  int? frais;
  String? modeEnvoie;
  String? etat;
  int? facture;
  //DateTime? dateSaisie;

  ColisModel({
    this.id,
    this.tracking,
    this.codeClient,
    this.poids,
    this.volume,
    this.frais,
    this.modeEnvoie,
    this.etat,
    this.facture,
    //this.dateSaisie,
  });

  ColisModel.fromJson(Map<String, dynamic> json) {
    id=int.tryParse(json['id']?? '0');
    tracking = json['tracking'] as String;
    codeClient = json['codeClient'] as String;
    poids = double.tryParse(json['poids'] ?? '0.0');
    volume = double.tryParse(json['volume'] ?? '0.0');
    frais = int.tryParse(json['frais'] ?? '0');
    modeEnvoie = json['modeEnvoie'] as String;
    etat = json['etat'] as String;
    facture = int.tryParse(json['facture'] ?? '0');
  }

  Map<String, dynamic> toMap() {
    return {
      'id':id,
      'tracking': tracking,
      'codeClient': codeClient,
      'poids': poids,
      'volume': volume,
      'frais': frais,
      'modeEnvoie': modeEnvoie,
      'etat': etat,
      'facture': facture,
      //'dateSaisie':dateSaisie,
    };
  }
}
