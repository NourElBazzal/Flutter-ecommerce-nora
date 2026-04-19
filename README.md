# NORA - Application Flutter de vente de vêtements

Projet réalisé dans le cadre du TP2 - MIAGE IA2  
Développement Mobile en Flutter

---

## Description

NORA est une application mobile de e-commerce de vêtements développée avec Flutter et Firebase.  
Elle permet aux utilisateurs de parcourir un catalogue de vêtements, de gérer leur panier,  
de modifier leur profil et d'ajouter de nouveaux vêtements grâce à une détection automatique  
de catégorie par Intelligence Artificielle (TFLite).

<div align="center">

![Aperçu de l'application main](docs/main.png)

</div>

---

## Application en ligne

👉 **[Accéder à l'application](https://ecommerce-project-2e1b6.web.app)**

### Sur ordinateur (Chrome/Edge)

1. Ouvre le lien dans Chrome ou Edge
2. Appuie sur **F12** pour ouvrir les DevTools
3. Clique sur l'icône 📱 **"Toggle device toolbar"** (ou **Ctrl + Shift + M**)
4. Choisis **iPhone 12 Pro** ou **Galaxy S20**
5. Rafraîchis la page (**F5**)

### Sur téléphone

Ouvre simplement le lien directement dans ton navigateur mobile - l'application est optimisée pour mobile et fonctionne nativement sur iOS et Android !

---

## Fonctionnalités réalisées

### MVP

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

| Catégorie | Nombre d'images |
| --------- | --------------- |
| Pantalon  | 40 images       |
| Short     | 40 images       |
| Haut      | 40 images       |
| Veste     | 40 images       |

Les images d'entraînement sont disponibles dans `assets/images/training_model_images/`

---

## Performance du modèle IA

<div align="center">

| Accuracy par classe                                  | Confusion Matrix                                   |
| ---------------------------------------------------- | -------------------------------------------------- |
| <img src="docs/accuracy_per_class.png" width="400"/> | <img src="docs/confusion_matrix.png" width="400"/> |

</div>

---

## Aperçu de l'application

<div align="center">

| Login                                       | Découvrir                                   | Détail                                   |
| ------------------------------------------- | ------------------------------------------- | ---------------------------------------- |
| <img src="docs/connexion.png" width="200"/> | <img src="docs/decouvrir.png" width="200"/> | <img src="docs/detail.png" width="200"/> |

| Panier                                   | Profil                                    | Ajouter (IA)                             |
| ---------------------------------------- | ----------------------------------------- | ---------------------------------------- |
| <img src="docs/panier.png" width="200"/> | <img src="docs/profile.png" width="200"/> | <img src="docs/add_ai.png" width="200"/> |

</div>

---

## Utilisateurs de test

| Login | Password |
| ----- | -------- |
| user1 | user1    |
| user2 | user2    |

---

## Technologies utilisées

- **Flutter** (Web)
- **Firebase Firestore** - base de données
- **Firebase Hosting** - hébergement de l'application
- **TensorFlow Lite** - modèle IA de classification
- **Google Teachable Machine** - entraînement du modèle
- **Cached Network Image** - affichage optimisé des images

---

## Lancer le projet

### Prérequis

- Flutter SDK installé
- Google Chrome ou Microsoft Edge
- Git

### Installation

```bash
git clone https://github.com/NourElBazzal/Flutter-ecommerce-nora.git
cd Flutter-ecommerce-nora
flutter pub get
flutter run -d chrome
```

### ⚠️ Vue mobile obligatoire

Ce projet est optimisé pour une **vue mobile sur navigateur**.

1. Une fois Chrome ouvert, appuie sur **F12**
2. Clique sur l'icône 📱 **"Toggle device toolbar"** (**Ctrl + Shift + M**)
3. Choisis **iPhone 12 Pro** ou **Galaxy S20**
4. Rafraîchis la page (**F5**)

> Le design est optimisé pour ~390px de large. En plein écran desktop les grids peuvent sembler déformés.

---

## Structure du projet

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
      training_model_images/     — Images d'entraînement du modèle IA
        Haut/                    — Photos de hauts
        Pantalon/                — Photos de pantalons
        Short/                   — Photos de shorts
        Veste/                   — Photos de vestes
      model_unquant.tflite       — Modèle TFLite entraîné
      labels.txt                 — Labels du modèle (4 catégories)
      logo_transparent.png       — Logo de l'application (fond transparent)
      login_bg.jpg               — Image de fond page de connexion
  docs/
    accuracy_per_class.png       — Screenshot Accuracy par classe du modèle IA
    confusion_matrix.png         — Screenshot Confusion Matrix du modèle IA
    connexion.png                — Screenshot page de connexion
    decouvrir.png                — Screenshot liste des vêtements
    detail.png                   — Screenshot détail vêtement
    panier.png                   — Screenshot panier
    profile.png                  — Screenshot profil
    add_ai.png                   — Screenshot ajout avec IA
  web/
    index.html                   — TensorFlow.js + TFLite bridge
  pubspec.yaml                   — Dépendances Flutter
  README.md                      — Documentation
```

---

## Auteur

**Nour EL BAZZAL**  
MIAGE IA2 - 2025/2026
