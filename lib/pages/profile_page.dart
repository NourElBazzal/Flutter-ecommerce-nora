import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../modeles/user.dart';
import 'login_page.dart';
import 'ajout_vetement_page.dart';

class ProfilePage extends StatefulWidget {
  final UserModel user;
  const ProfilePage({super.key, required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _loginCtrl;
  late TextEditingController _passCtrl;
  late TextEditingController _birthdayCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _postalCtrl;
  late TextEditingController _cityCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loginCtrl = TextEditingController(text: widget.user.utilisateur);
    _passCtrl = TextEditingController(text: widget.user.motDePasse);
    _birthdayCtrl = TextEditingController(text: widget.user.dateDeNaissance);
    _addressCtrl = TextEditingController(text: widget.user.adresse);
    _postalCtrl = TextEditingController(text: widget.user.codePostal);
    _cityCtrl = TextEditingController(text: widget.user.ville);
  }

  @override
  void dispose() {
    _loginCtrl.dispose();
    _passCtrl.dispose();
    _birthdayCtrl.dispose();
    _addressCtrl.dispose();
    _postalCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.docId)
          .update({
        'motDePasse': _passCtrl.text,
        'dateDeNaissance': _birthdayCtrl.text,
        'adresse': _addressCtrl.text,
        'codePostal': _postalCtrl.text,
        'ville': _cityCtrl.text,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profil sauvegardé ✓")),
        );
      }
    } catch (e) {
      debugPrint("Erreur sauvegarde profil: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur lors de la sauvegarde.")),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => const LoginPage(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
      (route) => false,
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    bool readOnly = false,
    bool obscure = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? formatters,
    String? hint,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      obscureText: obscure,
      keyboardType: keyboardType,
      inputFormatters: formatters,
      style: TextStyle(
        color: readOnly ? Colors.white.withValues(alpha: 0.4) : Colors.white,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: readOnly
            ? Colors.white.withValues(alpha: 0.02)
            : Colors.white.withValues(alpha: 0.05),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: readOnly
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 1.5),
        ),
        labelStyle: TextStyle(
          color: readOnly
              ? Colors.white.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Login readonly
          _buildField(
            controller: _loginCtrl,
            label: "Login",
            readOnly: true,
          ),
          const SizedBox(height: 12),

          // Password
          _buildField(
            controller: _passCtrl,
            label: "Password",
            obscure: true,
          ),
          const SizedBox(height: 12),

          // Anniversaire
          _buildField(
            controller: _birthdayCtrl,
            label: "Anniversaire",
            hint: "YYYY-MM-DD",
          ),
          const SizedBox(height: 12),

          // Adresse
          _buildField(
            controller: _addressCtrl,
            label: "Adresse",
          ),
          const SizedBox(height: 12),

          // Code postal
          _buildField(
            controller: _postalCtrl,
            label: "Code Postal",
            keyboardType: TextInputType.number,
            formatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 12),

          // Ville
          _buildField(
            controller: _cityCtrl,
            label: "Ville",
          ),
          const SizedBox(height: 24),

          // Bouton Ajouter vêtement
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text("Ajouter un vêtement"),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AjoutVetementPage()),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Bouton Valider
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.black),
                    )
                  : const Text("Valider"),
            ),
          ),
          const SizedBox(height: 12),

          // Bouton Se déconnecter
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _logout,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,
                side: const BorderSide(color: Colors.redAccent),
              ),
              child: const Text("Se déconnecter"),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
