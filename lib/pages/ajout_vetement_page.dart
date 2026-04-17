import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../modeles/categorie_vetement.dart';
import '../services/vetement_classifier.dart';

class AjoutVetementPage extends StatefulWidget {
  const AjoutVetementPage({super.key});

  @override
  State<AjoutVetementPage> createState() => _AjoutVetementPageState();
}

class _AjoutVetementPageState extends State<AjoutVetementPage> {
  final _titreCtrl = TextEditingController();
  final _tailleCtrl = TextEditingController();
  final _marqueCtrl = TextEditingController();
  final _prixCtrl = TextEditingController();

  Uint8List? _imageBytes;
  CategorieVetement? _categorieDetectee;
  bool _enDetection = false;
  bool _enSauvegarde = false;

  @override
  void dispose() {
    _titreCtrl.dispose();
    _tailleCtrl.dispose();
    _marqueCtrl.dispose();
    _prixCtrl.dispose();
    super.dispose();
  }

  Future<void> _choisirImage() async {
    final picker = ImagePicker();
    final fichier = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 400,
      maxHeight: 400,
    );
    if (fichier == null) return;

    final bytes = await fichier.readAsBytes();
    setState(() {
      _imageBytes = bytes;
      _categorieDetectee = null;
      _enDetection = true;
    });

    try {
      final categorie =
          await VetementClassifier.instance.detecterDepuisBytes(bytes);
      setState(() {
        _categorieDetectee = categorie;
        _enDetection = false;
      });
    } catch (e) {
      debugPrint('Erreur détection: $e');
      setState(() => _enDetection = false);
    }
  }

  Future<void> _sauvegarder() async {
    if (_imageBytes == null) {
      _afficherMessage("Veuillez sélectionner une image.");
      return;
    }
    if (_titreCtrl.text.isEmpty ||
        _tailleCtrl.text.isEmpty ||
        _marqueCtrl.text.isEmpty ||
        _prixCtrl.text.isEmpty) {
      _afficherMessage("Veuillez remplir tous les champs.");
      return;
    }

    setState(() => _enSauvegarde = true);

    try {
      final base64Image = base64Encode(_imageBytes!);
      await FirebaseFirestore.instance.collection('clothes').add({
        'titre': _titreCtrl.text.trim(),
        'categorie': _categorieDetectee?.libelle ?? 'Haut',
        'taille': _tailleCtrl.text.trim(),
        'brand': _marqueCtrl.text.trim(),
        'prix': double.parse(_prixCtrl.text.trim()),
        'imageUrl': 'data:image/jpeg;base64,$base64Image',
      });

      if (mounted) {
        _afficherMessage("Vêtement ajouté avec succès ✓");
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Erreur sauvegarde: $e');
      _afficherMessage("Erreur lors de la sauvegarde.");
    } finally {
      if (mounted) setState(() => _enSauvegarde = false);
    }
  }

  void _afficherMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ajouter un vêtement")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Image picker
            GestureDetector(
              onTap: _enDetection ? null : _choisirImage,
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4E6D5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF7A9E7E)),
                ),
                child: _imageBytes == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate,
                              size: 60, color: Color(0xFF7A9E7E)),
                          SizedBox(height: 8),
                          Text(
                            "Appuyer pour sélectionner une image",
                            style: TextStyle(color: Color(0xFF7A9E7E)),
                          ),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.memory(_imageBytes!, fit: BoxFit.cover),
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Catégorie détectée
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD4E6D5)),
              ),
              child: _enDetection
                  ? const Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Color(0xFF7A9E7E)),
                        ),
                        SizedBox(width: 12),
                        Text("Analyse IA en cours..."),
                      ],
                    )
                  : Row(
                      children: [
                        const Icon(Icons.auto_awesome,
                            color: Color(0xFF7A9E7E), size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _categorieDetectee == null
                                ? "Catégorie détectée automatiquement par IA"
                                : "IA a détecté : ${_categorieDetectee!.libelle}",
                            style: TextStyle(
                              color: _categorieDetectee == null
                                  ? Colors.grey
                                  : const Color(0xFF2D2D2D),
                              fontWeight: _categorieDetectee == null
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                            ),
                          ),
                        ),
                        if (_categorieDetectee != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4E6D5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _categorieDetectee!.libelle,
                              style: const TextStyle(
                                color: Color(0xFF7A9E7E),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _titreCtrl,
              decoration: const InputDecoration(labelText: "Titre"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _tailleCtrl,
              decoration: const InputDecoration(labelText: "Taille"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _marqueCtrl,
              decoration: const InputDecoration(labelText: "Marque"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _prixCtrl,
              decoration: const InputDecoration(labelText: "Prix (€)"),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    (_enSauvegarde || _enDetection) ? null : _sauvegarder,
                child: _enSauvegarde
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text("Valider"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
