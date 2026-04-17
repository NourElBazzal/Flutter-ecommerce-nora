# LUMIS - Application Flutter de vente de vêtements

Projet réalisé dans le cadre du TP2 - MIAGE IA2  
Développement Mobile en Flutter

---

## Description

LUMIS est une application mobile de e-commerce de vêtements développée avec Flutter et Firebase.  
Elle permet aux utilisateurs de parcourir un catalogue de vêtements, de gérer leur panier,  
de modifier leur profil et d'ajouter de nouveaux vêtements grâce à une détection automatique  
de catégorie par Intelligence Artificielle (TFLite).

---

## Fonctionnalités réalisées

### MVP (12/20)
- [x] **US#1** - Interface de login avec vérification Firebase
- [x] **US#2** - Liste des vêtements récupérée depuis Firestore (vue en grille)
- [x] **US#3** - Détail d'un vêtement avec ajout au panier
- [x] **US#4** - Panier avec total et suppression d'articles
- [x] **US#5** - Profil utilisateur avec modification et déconnexion
- [x] **US#6** - Ajout d'un vêtement avec détection automatique de catégorie par IA (TFLite + TensorFlow.js)

---

## Intelligence Artificielle

Le modèle de détection de catégorie a été entraîné avec **Google Teachable Machine**  
sur des images de vêtements réparties en 4 catégories :

- 👖 Pantalon
- 🩳 Short  
- 👕 Haut
- 🧥 Veste

Le modèle TFLite est chargé dans le navigateur via **TensorFlow.js**  
et prédit automatiquement la catégorie d'un vêtement à partir d'une photo.

Images utilisées pour l'entraînement : disponibles dans `assets/images/training_ia/`

---

## Utilisateurs de test

| Login | Password |
|-------|----------|
| user1 | user1    |
| user2 | user2    |

---

## Technologies utilisées

- **Flutter** (Web)
- **Firebase Firestore** - base de données
- **Firebase Storage** - stockage des images
- **TensorFlow Lite** - modèle IA de classification
- **Google Teachable Machine** - entraînement du modèle
- **Cached Network Image** - affichage optimisé des images

---

## Lancer le projet

### Prérequis
- Flutter SDK installé
- Chrome ou Edge

### Installation

```bash
git clone https://github.com/TON_USERNAME/MIAGE-TP2-Flutter.git
cd MIAGE-TP2-Flutter
flutter pub get
flutter run -d chrome
```

---

## 📁 Structure du projet

```
projet_td2/
  lib/
    modeles/
      user.dart                  — Modèle utilisateur
      vetement.dart              — Modèle vêtement
      categorie_vetement.dart    — Enum catégories IA
    services/
      vetement_classifier.dart   — Service détection IA TFLite
    pages/
      login_page.dart            — Page de connexion
      home_page.dart             — Navigation principale
      clothes_list_page.dart     — Liste des vêtements
      clothes_detail_page.dart   — Détail d'un vêtement
      cart_page.dart             — Panier
      profile_page.dart          — Profil utilisateur
      ajout_vetement_page.dart   — Ajout vêtement avec IA
    firebase_options.dart        — Configuration Firebase
    main.dart                    — Point d'entrée
  assets/
    images/
      model_unquant.tflite       — Modèle TFLite entraîné
      labels.txt                 — Labels du modèle
      logo.png                   — Logo de l'application
  web/
    index.html                   — TensorFlow.js + TFLite bridge
  pubspec.yaml                   — Dépendances Flutter
  README.md                      — Documentation
```

---

## Auteur

**Nour B.**  
MIAGE IA2 - 2025/2026