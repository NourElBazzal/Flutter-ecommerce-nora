enum CategorieVetement {
  pantalon,
  short,
  haut,
  veste;

  String get libelle {
    switch (this) {
      case CategorieVetement.pantalon:
        return 'Pantalon';
      case CategorieVetement.short:
        return 'Short';
      case CategorieVetement.haut:
        return 'Haut';
      case CategorieVetement.veste:
        return 'Veste';
    }
  }

  static CategorieVetement fromLibelle(String libelle) {
    final l = libelle.toLowerCase().trim();
    if (l.contains('pantalon')) return CategorieVetement.pantalon;
    if (l.contains('short')) return CategorieVetement.short;
    if (l.contains('haut')) return CategorieVetement.haut;
    if (l.contains('veste')) return CategorieVetement.veste;
    return CategorieVetement.haut;
  }
}
