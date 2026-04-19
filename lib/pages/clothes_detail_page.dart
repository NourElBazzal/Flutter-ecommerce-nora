import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../modeles/vetement.dart';
import '../modeles/user.dart';

class ClothesDetailPage extends StatelessWidget {
  final VetementModel vetement;
  final UserModel user;

  const ClothesDetailPage({
    super.key,
    required this.vetement,
    required this.user,
  });

  Future<void> _addToCart(BuildContext context) async {
    try {
      final cartRef =
          FirebaseFirestore.instance.collection('carts').doc(user.utilisateur);

      await cartRef.set({
        'items': FieldValue.arrayUnion([vetement.docId]),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ajouté au panier ✓")),
      );
    } catch (e) {
      debugPrint("Erreur ajout panier: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur lors de l'ajout au panier.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(vetement.titre)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Image full width
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(32),
              ),
              child: Container(
                color: Colors.white.withValues(alpha: 0.04),
                child: CachedNetworkImage(
                  imageUrl: vetement.imageUrl,
                  width: double.infinity,
                  height: 320,
                  fit: BoxFit.contain,
                  errorWidget: (_, __, ___) => Container(
                    height: 320,
                    color: Colors.white.withValues(alpha: 0.04),
                    child: Icon(
                      Icons.checkroom,
                      size: 80,
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Title
                  Text(
                    vetement.titre,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Info chips
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _InfoChip(
                          label: vetement.categorie,
                          icon: Icons.category_outlined),
                      const SizedBox(width: 8),
                      _InfoChip(
                          label: vetement.taille,
                          icon: Icons.straighten_outlined),
                      const SizedBox(width: 8),
                      _InfoChip(
                          label: vetement.brand,
                          icon: Icons.local_offer_outlined),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Price
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      "${vetement.prix.toStringAsFixed(2)} €",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD4AF37),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Buttons
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Retour"),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _addToCart(context),
                          child: const Text("Ajouter au panier"),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _InfoChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFFD4AF37)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
