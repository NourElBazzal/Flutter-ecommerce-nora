import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math;
import '../modeles/user.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _loginCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;

  late AnimationController _floatController;
  late AnimationController _shimmerController;
  late Animation<double> _float1;
  late Animation<double> _float2;
  late Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _float1 = Tween<double>(begin: -15, end: 15).animate(
        CurvedAnimation(parent: _floatController, curve: Curves.easeInOut));
    _float2 = Tween<double>(begin: 10, end: -10).animate(
        CurvedAnimation(parent: _floatController, curve: Curves.easeInOut));
    _shimmer = Tween<double>(begin: -1, end: 2).animate(
        CurvedAnimation(parent: _shimmerController, curve: Curves.linear));
  }

  @override
  void dispose() {
    _floatController.dispose();
    _shimmerController.dispose();
    _loginCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final login = _loginCtrl.text.trim();
    final password = _passCtrl.text;

    if (login.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs.")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final q = await FirebaseFirestore.instance
          .collection('users')
          .where('utilisateur', isEqualTo: login)
          .limit(1)
          .get();

      if (q.docs.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Identifiants incorrects.")),
          );
        }
        return;
      }

      final doc = q.docs.first;
      final data = doc.data();
      if ((data['motDePasse'] ?? '') != password) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Identifiants incorrects.")),
          );
        }
        return;
      }

      final user = UserModel.fromFirestore(doc.id, data);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, animation, __) => HomePage(user: user),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    } catch (e) {
      debugPrint("Login error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur Firebase.")),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-0.5, -0.5),
                radius: 1.5,
                colors: [
                  Color(0xFF1A1500),
                  Color(0xFF0A0A0A),
                  Color(0xFF000000),
                ],
              ),
            ),
          ),

          // Floating orbs
          AnimatedBuilder(
            animation: _floatController,
            builder: (_, __) => Stack(
              children: [
                Positioned(
                  top: 100 + _float1.value,
                  right: 50,
                  child: _GlowOrb(
                      size: 200,
                      color: const Color(0xFFD4AF37).withOpacity(0.06)),
                ),
                Positioned(
                  bottom: 150 + _float2.value,
                  left: 30,
                  child: _GlowOrb(
                      size: 150,
                      color: const Color(0xFF7A9E7E).withOpacity(0.06)),
                ),
                Positioned(
                  top: 300 + _float2.value,
                  left: 100,
                  child: _GlowOrb(
                      size: 100,
                      color: const Color(0xFFD4AF37).withOpacity(0.04)),
                ),
              ],
            ),
          ),

          // Main content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo with glow
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFD4AF37).withOpacity(0.3),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // App name with shimmer
                    AnimatedBuilder(
                      animation: _shimmer,
                      builder: (_, __) => ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: const [
                            Color(0xFFD4AF37),
                            Color(0xFFFFF5CC),
                            Color(0xFFD4AF37),
                          ],
                          stops: [
                            (_shimmer.value - 0.3).clamp(0.0, 1.0),
                            _shimmer.value.clamp(0.0, 1.0),
                            (_shimmer.value + 0.3).clamp(0.0, 1.0),
                          ],
                        ).createShader(bounds),
                        child: const Text(
                          'NORA',
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 10,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    Text(
                      'Votre destination de mode',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.4),
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 52),

                    // Glass card
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller: _loginCtrl,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: "Utilisateur",
                              prefixIcon: Icon(Icons.person_outline,
                                  color:
                                      const Color(0xFFD4AF37).withOpacity(0.7),
                                  size: 20),
                            ),
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _passCtrl,
                            obscureText: true,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: "Mot de passe",
                              prefixIcon: Icon(Icons.lock_outline,
                                  color:
                                      const Color(0xFFD4AF37).withOpacity(0.7),
                                  size: 20),
                            ),
                            onSubmitted: (_) => _signIn(),
                          ),
                          const SizedBox(height: 28),

                          // Shimmer button
                          _ShimmerButton(
                            onTap: _loading ? null : _signIn,
                            loading: _loading,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Glow orb widget
class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;
  const _GlowOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(color: color, blurRadius: 60, spreadRadius: 20),
        ],
      ),
    );
  }
}

// Shimmer button widget
class _ShimmerButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool loading;
  const _ShimmerButton({required this.onTap, required this.loading});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFFB8960C),
              Color(0xFFD4AF37),
              Color(0xFFE8C84A),
              Color(0xFFD4AF37),
              Color(0xFFB8960C),
            ],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD4AF37).withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: loading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.black),
                )
              : const Text(
                  "SE CONNECTER",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    letterSpacing: 3,
                  ),
                ),
        ),
      ),
    );
  }
}
