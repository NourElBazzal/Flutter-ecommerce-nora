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
      debugPrint("Erreur: $e");
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
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
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
          readOnly: readOnly,
          obscureText: obscure,
          keyboardType: keyboardType,
          inputFormatters: formatters,
          style: TextStyle(
            color: readOnly ? const Color(0xFFAAAAAA) : const Color(0xFF1A1A1A),
            fontSize: 15,
          ),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor:
                readOnly ? const Color(0xFFF8F8F8) : const Color(0xFFF5F5F5),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // Avatar + name
          Center(
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      widget.user.utilisateur.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.user.utilisateur,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Divider
          const Divider(color: Color(0xFFF0F0F0)),
          const SizedBox(height: 24),

          // Fields
          _buildField(
              controller: _loginCtrl, label: "Identifiant", readOnly: true),
          const SizedBox(height: 16),
          _buildField(
              controller: _passCtrl, label: "Mot De Passe", obscure: true),
          const SizedBox(height: 16),
          _buildField(
              controller: _birthdayCtrl,
              label: "Anniversaire",
              hint: "YYYY-MM-DD"),
          const SizedBox(height: 16),
          _buildField(controller: _addressCtrl, label: "Adresse"),
          const SizedBox(height: 16),
          _buildField(
            controller: _postalCtrl,
            label: "Code Postal",
            keyboardType: TextInputType.number,
            formatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 16),
          _buildField(controller: _cityCtrl, label: "Ville"),
          const SizedBox(height: 32),

          // Add clothes button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.add, size: 18),
              label: const Text("Ajouter un vêtement"),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AjoutVetementPage()),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF1A1A1A),
                side: const BorderSide(color: Color(0xFF1A1A1A)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Save button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A1A1A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text(
                      "Valider",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),

          // Logout button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: _logout,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red.shade400,
                side: BorderSide(color: Colors.red.shade200),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Se déconnecter",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
