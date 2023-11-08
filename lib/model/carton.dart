class Carton {
  late final String trackingCarton;
  late final String etat;
  late final List<String> trackingColis;

  Carton(
      {required this.trackingCarton,
      required this.etat,
      required this.trackingColis});
  factory Carton.fromJson(Map<String, dynamic> json) {
    return Carton(
      trackingCarton: json['trackingCarton'],
      etat: json['etat'],
      trackingColis: List<String>.from(json['trackingColis']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trackingCarton': trackingCarton,
      'etat': etat,
      'trackingColis': trackingColis,
    };
  }
}
