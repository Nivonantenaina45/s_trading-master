class Carton {
  late final String tracking;
  late final String etat;
  late final List<String> trackingColis;

  Carton({required this.tracking, required this.etat, required this.trackingColis});
  factory Carton.fromJson(Map<String, dynamic> json) {
    return Carton(
      tracking: json['tracking'],
      etat: json['etat'],
      trackingColis: List<String>.from(json['trackingColis']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tracking': tracking,
      'etat': etat,
      'trackingColis': trackingColis,
    };
  }
}
