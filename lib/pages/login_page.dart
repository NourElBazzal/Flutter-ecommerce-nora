import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../modeles/user.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _loginCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _loginCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final login = _loginCtrl.text.trim();
    final password = _passCtrl.text;

    if (login.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Veuillez remplir login et mot de passe.")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      // Recherche par champ "utilisateur" (compatible si DocID auto)
      final q = await FirebaseFirestore.instance
          .collection('users')
          .where('utilisateur', isEqualTo: login)
          .limit(1)
          .get();

      if (q.docs.isEmpty) {
        debugPrint("Login failed: utilisateur introuvable");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Identifiants incorrects.")),
        );
        return;
      }

      final doc = q.docs.first;
      final data = doc.data();
      final dbPassword = (data['motDePasse'] ?? '') as String;

      if (dbPassword != password) {
        debugPrint("Login failed: mauvais mot de passe");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Identifiants incorrects.")),
        );
        return;
      }

      // On crée le UserModel complet
      final user = UserModel.fromFirestore(doc.id, data);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomePage(user: user)),
      );
    } catch (e) {
      debugPrint("Login error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur Firebase.")),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE8F3E9),
              Color(0xFFF8FAF8),
              Color(0xFFEEF2EE),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo / Brand
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7A9E7E), Color(0xFF9DB89F)],
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7A9E7E).withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.shopping_bag,
                        color: Colors.white, size: 45),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'NORA',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 8,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Votre destination de mode',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF9E9E9E),
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Login field
                  TextField(
                    controller: _loginCtrl,
                    decoration: const InputDecoration(
                      labelText: "Utilisateur",
                      prefixIcon:
                          Icon(Icons.person_outline, color: Color(0xFF7A9E7E)),
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),

                  // Mot de passe field
                  TextField(
                    controller: _passCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Mot de passe",
                      prefixIcon:
                          Icon(Icons.lock_outline, color: Color(0xFF7A9E7E)),
                    ),
                    onSubmitted: (_) => _signIn(),
                  ),
                  const SizedBox(height: 32),

                  // Login button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _signIn,
                      child: _loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Text("Se connecter"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
