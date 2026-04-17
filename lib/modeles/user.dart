class UserModel {
  final String docId;
  final String utilisateur;
  final String motDePasse;
  final String dateDeNaissance;
  final String adresse;
  final String codePostal;
  final String ville;

  UserModel({
    required this.docId,
    required this.utilisateur,
    required this.motDePasse,
    required this.dateDeNaissance,
    required this.adresse,
    required this.codePostal,
    required this.ville,
  });

  // Créer un UserModel depuis un document Firestore
  factory UserModel.fromFirestore(String docId, Map<String, dynamic> data) {
    return UserModel(
      docId: docId,
      utilisateur: data['utilisateur'] ?? '',
      motDePasse: data['motDePasse'] ?? '',
      dateDeNaissance: data['dateDeNaissance'] ?? '',
      adresse: data['adresse'] ?? '',
      codePostal: data['codePostal'] ?? '',
      ville: data['ville'] ?? '',
    );
  }

  // Convertir en Map pour sauvegarder dans Firestore
  Map<String, dynamic> toMap() {
    return {
      'utilisateur': utilisateur,
      'motDePasse': motDePasse,
      'dateDeNaissance': dateDeNaissance,
      'adresse': adresse,
      'codePostal': codePostal,
      'ville': ville,
    };
  }
}
