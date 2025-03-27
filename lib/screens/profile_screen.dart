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
          // Background Gradient
          Container(
            height: size.height * 0.4,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [kTravailFuteMainColor, Color.fromARGB(255, 216, 165, 54)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Profile Content
          Column(
            children: [
              // AppBar with Back Button
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      const SizedBox(width: 40), // Placeholder to balance the title
                    ],
                  ),
                ),
              ),

              // Profile Card
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
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
                        radius: 50,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: user['profileImage'] != null
                            ? NetworkImage(user['profileImage'])
                            : null, // Load image if available
                        child: user['profileImage'] == null
                            ? const Icon(Icons.person, size: 50, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Username
                      Text(
                        user['username'],
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),

                      // Email
                      Text(
                        user['email'] ?? 'No email provided',
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),

                      const SizedBox(height: 20),
                      const Divider(),

                      // Profile Info
                      _buildProfileInfo(Icons.person, "Nom d'utilisateur", user['username']),
                      _buildProfileInfo(Icons.email, "Adresse email", user['email']?? "Non spécifié"),
                      // _buildProfileInfo(Icons.phone, "Numéro de téléphone", user['phone_number'] ?? "Non disponible"),
                      // _buildProfileInfo(Icons.email, "Localisation", user['email'] ?? "Non spécifié"),

                      const Spacer(),

                      // Logout Button
                      SizedBox(
                        width: size.width * 0.8,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kTravailFuteMainColor,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: () async {
                            await credentialService.logout(context);
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.logout, color: Colors.white),
                              SizedBox(width: 10),
                              Text(
                                'Déconnexion',
                                style: TextStyle(fontSize: 16, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper Function for Profile Info
  Widget _buildProfileInfo(IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon, color: kTravailFuteMainColor),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(value, style: const TextStyle(color: Colors.grey)),
    );
  }
}
