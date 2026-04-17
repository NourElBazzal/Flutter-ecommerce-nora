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
      // Récupérer les IDs du panier
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

      // Récupérer chaque vêtement depuis Firestore
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
      return const Center(child: CircularProgressIndicator());
    }

    if (_items.isEmpty) {
      return const Center(child: Text("Votre panier est vide."));
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _items.length,
            itemBuilder: (context, index) {
              final v = _items[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: v.imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) =>
                          const Icon(Icons.image_not_supported, size: 40),
                    ),
                  ),
                  title: Text(v.titre,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      "Taille : ${v.taille}  •  ${v.prix.toStringAsFixed(2)} €"),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () => _removeItem(v),
                  ),
                ),
              );
            },
          ),
        ),
        // Total général
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            border: Border(top: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text("${_total.toStringAsFixed(2)} €",
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange)),
            ],
          ),
        ),
      ],
    );
  }
}
