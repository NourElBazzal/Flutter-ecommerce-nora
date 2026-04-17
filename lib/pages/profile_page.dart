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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profil sauvegardé ✓")),
      );
    } catch (e) {
      debugPrint("Erreur sauvegarde profil: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur lors de la sauvegarde.")),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Login (readonly)
          TextField(
            controller: _loginCtrl,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: "Login",
              filled: true,
              fillColor: Color(0xFFEEEEEE),
            ),
          ),
          const SizedBox(height: 12),

          // Password (offusqué)
          TextField(
            controller: _passCtrl,
            obscureText: true,
            decoration: const InputDecoration(labelText: "Password"),
          ),
          const SizedBox(height: 12),

          // Anniversaire
          TextField(
            controller: _birthdayCtrl,
            decoration: const InputDecoration(
              labelText: "Anniversaire",
              hintText: "YYYY-MM-DD",
            ),
          ),
          const SizedBox(height: 12),

          // Adresse
          TextField(
            controller: _addressCtrl,
            decoration: const InputDecoration(labelText: "Adresse"),
          ),
          const SizedBox(height: 12),

          // Code postal (numérique uniquement)
          TextField(
            controller: _postalCtrl,
            decoration: const InputDecoration(labelText: "Code Postal"),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 12),

          // Ville
          TextField(
            controller: _cityCtrl,
            decoration: const InputDecoration(labelText: "Ville"),
          ),
          const SizedBox(height: 24),

          // Bouton Clothes
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
                      child: CircularProgressIndicator(strokeWidth: 2),
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
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("Se déconnecter"),
            ),
          ),
        ],
      ),
    );
  }
}
