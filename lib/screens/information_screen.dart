import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:travail_fute/constants.dart';
import 'package:travail_fute/services/credential_service.dart';
import 'package:travail_fute/utils/logger.dart';

class InformationScreen extends StatefulWidget {
  const InformationScreen({super.key});

  @override
  State<InformationScreen> createState() => _InformationScreenState();
}

class _InformationScreenState extends State<InformationScreen> {
  late TextEditingController _nameController;
  late TextEditingController _vtaController;
  late TextEditingController _bankAccountController;
  late TextEditingController _addressController;
  late TextEditingController _emailController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _vtaController = TextEditingController();
    _bankAccountController = TextEditingController();
    _addressController = TextEditingController();
    _emailController = TextEditingController();
    fetchUser();
  }

  void fetchUser() async {
    setState(() => isLoading = true);
    try {
      final user = await CredentialService().getUserInfo(context);
      final userData = json.decode(user.body);
      _nameController.text = userData['legal_name'] ?? '';
      _vtaController.text = userData['vta_number'] ?? '';
      _bankAccountController.text = userData['bank_account'] ?? '';
      _addressController.text = userData['address'] ?? '';
      _emailController.text = userData['email'] ?? '';
    } catch (e) {
      logger.e(e);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _saveSettings() async {
    setState(() => isLoading = true);
    final settingsData = {
      'legal_name': _nameController.text,
      'vta_number': _vtaController.text,
      'bank_account': _bankAccountController.text,
      'address': _addressController.text,
      'email': _emailController.text,
    };

    final success = await CredentialService().updateUserInfo(context, settingsData);
    setState(() => isLoading = false);

    if (success.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paramètres mis à jour')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de la mise à jour')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _vtaController.dispose();
    _bankAccountController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Mes Informations',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      kTravailFuteMainColor,
                      kTravailFuteMainColor.withOpacity(0.7),
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.person_rounded,
                    size: 80,
                    color: Colors.white24,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.all(size.width * 0.05),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(kTravailFuteMainColor),
                      ),
                    )
                  : Column(
                      children: [
                        SizedBox(height: size.height * 0.03),
                        _buildSettingField(
                          label: 'Nom légal',
                          icon: Icons.business_rounded,
                          controller: _nameController,
                          hintText: 'Nom de l\'entreprise',
                        ),
                        SizedBox(height: size.height * 0.025),
                        _buildSettingField(
                          label: 'Numéro de TVA',
                          icon: Icons.receipt_long_rounded,
                          controller: _vtaController,
                          hintText: 'Numéro de TVA',
                        ),
                        SizedBox(height: size.height * 0.025),
                        _buildSettingField(
                          label: 'Compte bancaire',
                          icon: Icons.account_balance_rounded,
                          controller: _bankAccountController,
                          hintText: 'Détails du compte',
                        ),
                        SizedBox(height: size.height * 0.025),
                        _buildSettingField(
                          label: 'Adresse',
                          icon: Icons.location_on_rounded,
                          controller: _addressController,
                          hintText: 'Adresse complète',
                          maxLines: 2,
                        ),
                        SizedBox(height: size.height * 0.025),
                        _buildSettingField(
                          label: 'Email',
                          icon: Icons.email_rounded,
                          controller: _emailController,
                          hintText: 'Email professionnel',
                          keyboardType: TextInputType.emailAddress,
                        ),
                        SizedBox(height: size.height * 0.04),
                        _buildSaveButton(size),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              maxLines: maxLines,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                prefixIcon: Icon(icon, color: kTravailFuteMainColor, size: 22),
                hintText: hintText,
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(
                    color: kTravailFuteMainColor,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(Size size) {
    return Container(
      width: double.infinity,
      height: size.height * 0.07,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            kTravailFuteMainColor,
            kTravailFuteMainColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: kTravailFuteMainColor.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _saveSettings,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: const Text(
          'Enregistrer',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}