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
      debugPrint("Erreur: $e");
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
      );
    }

    if (_vetements.isEmpty) {
      return Center(
        child: Text("Aucun vêtement disponible.",
            style: TextStyle(color: Colors.white.withOpacity(0.5))),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _vetements.length,
      itemBuilder: (context, index) {
        final v = _vetements[index];
        return _AnimatedCard(
          vetement: v,
          onTap: () => Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, animation, __) =>
                  ClothesDetailPage(vetement: v, user: widget.user),
              transitionsBuilder: (_, animation, __, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                      parent: animation, curve: Curves.easeOutCubic)),
                  child: child,
                );
              },
              transitionDuration: const Duration(milliseconds: 400),
            ),
          ),
        );
      },
    );
  }
}

class _AnimatedCard extends StatefulWidget {
  final VetementModel vetement;
  final VoidCallback onTap;
  const _AnimatedCard({required this.vetement, required this.onTap});

  @override
  State<_AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<_AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.vetement;
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.07),
                Colors.white.withOpacity(0.03),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Expanded(
                flex: 4,
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  child: CachedNetworkImage(
                    imageUrl: v.imageUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(
                      color: Colors.white.withOpacity(0.05),
                      child: Icon(Icons.checkroom,
                          size: 50,
                          color: const Color(0xFFD4AF37).withOpacity(0.5)),
                    ),
                  ),
                ),
              ),

              // Info
              Expanded(
                flex: 1,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          v.titre,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "${v.prix.toStringAsFixed(2)}€",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Color(0xFFD4AF37),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
