class VetementModel {
  final String docId;
  final String titre;
  final String brand;
  final String categorie;
  final String taille;
  final double prix;
  final String imageUrl;

  VetementModel({
    required this.docId,
    required this.titre,
    required this.brand,
    required this.categorie,
    required this.taille,
    required this.prix,
    required this.imageUrl,
  });

  factory VetementModel.fromFirestore(String docId, Map<String, dynamic> data) {
    return VetementModel(
      docId: docId,
      titre: data['titre'] ?? '',
      brand: data['brand'] ?? '',
      categorie: data['categorie'] ?? '',
      taille: data['taille'] ?? '',
      prix: (data['prix'] ?? 0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
    );
  }
}
