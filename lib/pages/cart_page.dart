import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../modeles/vetement.dart';
import '../modeles/user.dart';

class CartPage extends StatefulWidget {
  final UserModel user;
  const CartPage({super.key, required this.user});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<VetementModel> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    try {
      final cartDoc = await FirebaseFirestore.instance
          .collection('carts')
          .doc(widget.user.utilisateur)
          .get();

      if (!cartDoc.exists) {
        setState(() => _loading = false);
        return;
      }

      final List<dynamic> itemIds = cartDoc.data()?['items'] ?? [];
      if (itemIds.isEmpty) {
        setState(() => _loading = false);
        return;
      }

      final List<VetementModel> vetements = [];
      for (final id in itemIds) {
        final doc = await FirebaseFirestore.instance
            .collection('clothes')
            .doc(id as String)
            .get();
        if (doc.exists) {
          vetements.add(VetementModel.fromFirestore(doc.id, doc.data()!));
        }
      }

      setState(() {
        _items = vetements;
        _loading = false;
      });
    } catch (e) {
      debugPrint("Erreur chargement panier: $e");
      setState(() => _loading = false);
    }
  }

  Future<void> _removeItem(VetementModel v) async {
    try {
      await FirebaseFirestore.instance
          .collection('carts')
          .doc(widget.user.utilisateur)
          .update({
        'items': FieldValue.arrayRemove([v.docId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      setState(() => _items.remove(v));
    } catch (e) {
      debugPrint("Erreur suppression: $e");
    }
  }

  double get _total => _items.fold(0, (sum, v) => sum + v.prix);

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF1A1A1A)),
      );
    }

    if (_items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined,
                size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              "Votre panier est vide",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Ajoutez des vêtements pour commencer",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${_items.length} article${_items.length > 1 ? 's' : ''}",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),

        // Items list
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final v = _items[index];
              return _CartItem(
                vetement: v,
                onRemove: () => _removeItem(v),
              );
            },
          ),
        ),

        // Total + checkout area
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Color(0xFFF0F0F0)),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    "${_total.toStringAsFixed(2)} €",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CartItem extends StatelessWidget {
  final VetementModel vetement;
  final VoidCallback onRemove;

  const _CartItem({required this.vetement, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: vetement.imageUrl,
              width: 75,
              height: 75,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(
                width: 75,
                height: 75,
                color: const Color(0xFFF5F5F5),
                child: const Icon(Icons.checkroom, color: Color(0xFFDDDDDD)),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vetement.titre,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        vetement.taille,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF888888),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  "${vetement.prix.toStringAsFixed(2)} €",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
          ),

          // Remove button
          GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 16, color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
