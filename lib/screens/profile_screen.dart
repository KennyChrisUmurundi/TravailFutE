import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:travail_fute/constants.dart';
import 'package:travail_fute/services/credential_service.dart';

class ProfileScreen extends StatelessWidget {
  final Map<String, dynamic> user;

  const ProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final credentialService = CredentialService();
    var size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient (responsive height)
          Container(
            height: size.height * 0.3, // Reduced for better space management
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [kTravailFuteMainColor, Color.fromARGB(255, 216, 165, 54)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Main Content
          SingleChildScrollView(
            child: Column(
              children: [
                // AppBar with Back Button
                SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.05, // Responsive padding
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Text(
                          'Mon Profil',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 40), // Balance the title
                      ],
                    ),
                  ),
                ),

                // Profile Card
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(
                    top: size.height * 0.02,
                    left: size.width * 0.05,
                    right: size.width * 0.05,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.05,
                    vertical: size.height * 0.03,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Profile Picture
                      CircleAvatar(
                        radius: size.width * 0.12, // Responsive radius
                        backgroundColor: Colors.grey[300],
                        backgroundImage: user['profileImage'] != null
                            ? NetworkImage(user['profileImage'])
                            : null,
                        child: user['profileImage'] == null
                            ? Icon(Icons.person, 
                                size: size.width * 0.12, 
                                color: Colors.white)
                            : null,
                      ),
                      SizedBox(height: size.height * 0.02),

                      // Username
                      Text(
                        user['username'],
                        style: TextStyle(
                          fontSize: size.width * 0.06, // Responsive font
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      // Email
                      Text(
                        user['email'] ?? 'No email provided',
                        style: TextStyle(
                          fontSize: size.width * 0.035,
                          color: Colors.grey,
                        ),
                      ),

                      SizedBox(height: size.height * 0.02),
                      const Divider(),

                      // Profile Info
                      _buildProfileInfo(
                        context,
                        Icons.person,
                        "Nom d'utilisateur",
                        user['username'],
                      ),
                      _buildProfileInfo(
                        context,
                        Icons.email,
                        "Adresse email",
                        user['email'] ?? "Non spécifié",
                      ),

                      // Change PIN Button
                      ListTile(
                        leading: Icon(Icons.lock, color: kTravailFuteMainColor),
                        title: Text(
                          "Changer le code PIN",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () => _showChangePinDialog(context),
                      ),

                      const Divider(),
                      SizedBox(height: size.height * 0.02),

                      // Logout Button
                      SizedBox(
                        width: size.width * 0.8,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kTravailFuteMainColor,
                            padding: EdgeInsets.symmetric(
                              vertical: size.height * 0.02,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: () async {
                            await credentialService.logout(context);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.logout, color: Colors.white),
                              SizedBox(width: size.width * 0.03),
                              Text(
                                'Déconnexion',
                                style: TextStyle(
                                  fontSize: size.width * 0.04,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Responsive Profile Info Item
  Widget _buildProfileInfo(
      BuildContext context, IconData icon, String title, String value) {
    final size = MediaQuery.of(context).size;
    return ListTile(
      leading: Icon(icon, color: kTravailFuteMainColor),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: size.width * 0.04,
        ),
      ),
      subtitle: Text(
        value,
        style: TextStyle(
          color: Colors.grey,
          fontSize: size.width * 0.035,
        ),
      ),
    );
  }
  Widget _buildPinField({
    required TextEditingController controller,
    required String label,
    // required IconData icon,
    TextInputType? keyboardType,
    // List<TextInputFormatter>? inputFormatters,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      // inputFormatters: inputFormatters,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(Icons.lock, color: kTravailFuteMainColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
    );
  }
  // Change PIN Dialog
  void _showChangePinDialog(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final currentPinController = TextEditingController();
    final newPinController = TextEditingController();
    final confirmPinController = TextEditingController();

    showDialog(
  context: context,
  builder: (dialogContext) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: const Color.fromARGB(255, 214, 211, 211),
      title: Text(
        "Changer le code PIN",
        style: TextStyle(
          fontSize: size.width * 0.05,
          color: Colors.white,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
      content: SingleChildScrollView(
        child: Container(
          width: size.width * 0.8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPinField(
                controller: currentPinController,
                label: "Code PIN actuel",
              ),
              SizedBox(height: size.height * 0.02),
              _buildPinField(
                controller: newPinController,
                label: "Nouveau code PIN",
              ),
              SizedBox(height: size.height * 0.02),
              _buildPinField(
                controller: confirmPinController,
                label: "Confirmer le nouveau code PIN",
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text(
            "Annuler",
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [kTravailFuteMainColor, kTravailFuteMainColor.withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              // Show loading dialog with circular animation
              showDialog(
              context: dialogContext,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return Dialog(
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: Center(
                  child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(kTravailFuteMainColor),
                    ),
                    SizedBox(height: 15),
                    Text("Changement en cours...",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  ),
                ),
                );
              },
              );

              if (newPinController.text != confirmPinController.text) {
              Navigator.pop(dialogContext); // Close loading dialog
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                content: Text("Les codes PIN ne correspondent pas"),
                backgroundColor: Colors.red[800],
                ),
              );
              Navigator.pop(dialogContext);
              return;
              }

              if (newPinController.text.length != 4) {
              Navigator.pop(dialogContext); // Close loading dialog
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                content: Text("Le code PIN doit avoir 4 chiffres"),
                backgroundColor: Colors.red[800],
                ),
              );
              Navigator.pop(dialogContext);
              return;
              }

              try {
              final success = await CredentialService().changePin(
                context,
                currentPinController.text,
                newPinController.text,
              );
              
              Navigator.pop(dialogContext); // Close loading dialog
              Map<String,dynamic> successData = jsonDecode(success.body);
              print("cjecl $successData");
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                content: Text("Code PIN changé avec succès"),
                backgroundColor: Colors.green[800],
                ),
              );
              }
              catch (e) {
              Navigator.pop(dialogContext); // Close loading dialog
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                content: Text("Erreur: $e"),
                backgroundColor: Colors.red[800],
                ),
              );
              }
            },
            child: Text(
              "Confirmer",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  },
);
  }
}