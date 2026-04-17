import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../modeles/vetement.dart';
import '../modeles/user.dart';
import 'clothes_detail_page.dart';

class ClothesListPage extends StatefulWidget {
  final UserModel user;
  const ClothesListPage({super.key, required this.user});

  @override
  State<ClothesListPage> createState() => _ClothesListPageState();
}

class _ClothesListPageState extends State<ClothesListPage> {
  List<VetementModel> _vetements = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadVetements();
  }

  Future<void> _loadVetements() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('clothes').get();

      setState(() {
        _vetements = snapshot.docs
            .map((doc) => VetementModel.fromFirestore(doc.id, doc.data()))
            .toList();
        _loading = false;
      });
    } catch (e) {
      debugPrint("Erreur chargement vêtements: $e");
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFF7A9E7E)));
    }

    if (_vetements.isEmpty) {
      return const Center(child: Text("Aucun vêtement disponible."));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _vetements.length,
      itemBuilder: (context, index) {
        final v = _vetements[index];
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ClothesDetailPage(vetement: v, user: widget.user),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image takes 75% of the card height
                Expanded(
                  flex: 4,
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                    child: CachedNetworkImage(
                      imageUrl: v.imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover, // ← back to cover
                      errorWidget: (_, __, ___) => Container(
                        color: const Color(0xFFD4E6D5),
                        child: const Icon(Icons.checkroom,
                            size: 50, color: Color(0xFF7A9E7E)),
                      ),
                    ),
                  ),
                ),
                // Info takes 25% of the card height
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            v.titre,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "${v.prix.toStringAsFixed(2)}€",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Color(0xFF7A9E7E)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
