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
      _showSnack("Veuillez sélectionner une image.");
      return;
    }
    if (_titreCtrl.text.isEmpty ||
        _tailleCtrl.text.isEmpty ||
        _marqueCtrl.text.isEmpty ||
        _prixCtrl.text.isEmpty) {
      _showSnack("Veuillez remplir tous les champs.");
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
        _showSnack("Vêtement ajouté avec succès ✓");
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Erreur sauvegarde: $e');
      _showSnack("Erreur lors de la sauvegarde.");
    } finally {
      if (mounted) setState(() => _enSauvegarde = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? formatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: formatters,
          style: const TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 15,
          ),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(0xFF1A1A1A), width: 1.5),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Ajouter un vêtement",
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_new,
              size: 18, color: Color(0xFF1A1A1A)),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFF0F0F0)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Image picker
            GestureDetector(
              onTap: _enDetection ? null : _choisirImage,
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE8E8E8)),
                ),
                child: _imageBytes == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined,
                              size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 10),
                          Text(
                            "Appuyer pour sélectionner une image",
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.memory(_imageBytes!, fit: BoxFit.cover),
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // IA detection result
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _categorieDetectee != null
                    ? const Color(0xFFF0F7F0)
                    : const Color(0xFFF8F8F8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _categorieDetectee != null
                      ? const Color(0xFF7A9E7E).withValues(alpha: 0.3)
                      : const Color(0xFFE8E8E8),
                ),
              ),
              child: _enDetection
                  ? const Row(
                      children: [
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          "Analyse IA en cours...",
                          style: TextStyle(
                            color: Color(0xFF888888),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: 18,
                          color: _categorieDetectee != null
                              ? const Color(0xFF7A9E7E)
                              : Colors.grey.shade400,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _categorieDetectee == null
                                ? "La catégorie sera détectée automatiquement par IA"
                                : "IA a détecté : ${_categorieDetectee!.libelle}",
                            style: TextStyle(
                              color: _categorieDetectee == null
                                  ? Colors.grey.shade400
                                  : const Color(0xFF1A1A1A),
                              fontSize: 14,
                              fontWeight: _categorieDetectee == null
                                  ? FontWeight.normal
                                  : FontWeight.w600,
                            ),
                          ),
                        ),
                        if (_categorieDetectee != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1A1A),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _categorieDetectee!.libelle,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
            const SizedBox(height: 24),

            // Form fields
            _buildField(
                controller: _titreCtrl,
                label: "Titre",
                hint: "Ex: T-shirt blanc"),
            const SizedBox(height: 16),
            _buildField(
                controller: _tailleCtrl,
                label: "Taille",
                hint: "Ex: S, M, L, XL"),
            const SizedBox(height: 16),
            _buildField(
                controller: _marqueCtrl,
                label: "Marque",
                hint: "Ex: Zara, H&M"),
            const SizedBox(height: 16),
            _buildField(
              controller: _prixCtrl,
              label: "Prix (€)",
              hint: "Ex: 29.99",
              keyboardType: TextInputType.number,
              formatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
            ),
            const SizedBox(height: 32),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed:
                    (_enSauvegarde || _enDetection) ? null : _sauvegarder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A1A1A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _enSauvegarde
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text(
                        "Valider",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
