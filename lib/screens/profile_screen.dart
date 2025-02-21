import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travail_fute/constants.dart';
import 'package:travail_fute/services/credential_service.dart';
import 'package:travail_fute/utils/provider.dart';

class ProfileScreen extends StatelessWidget {
  final Map<String, dynamic> user;

  ProfileScreen({required this.user});

  @override
  Widget build(BuildContext context) {
    final credentialService = CredentialService();
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: kWhiteColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
                CircleAvatar(
                radius: 50,
                backgroundColor: kTravailFuteMainColor,
                child: Icon(Icons.person, color: Colors.white), // Replace with user's profile image
              ),
              SizedBox(height: 16),
              Text(
                user['username'],
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 2),
              Text(
                user['email'],
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              SizedBox(height: 24),
              Divider(),
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Nom d\'utilisateur'),
                subtitle: Text(user['username'],style: TextStyle(fontSize: 14, color: Colors.grey),),
              ),
              ListTile(
                leading: Icon(Icons.email),
                title: Text('Adresse email'),
                subtitle: Text(user['email']),
              ),
              // Add more user details here
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () async {
                  await credentialService.logout(context);
                  
                },
                icon: Icon(Icons.logout),
                label: Text('Logout',style: TextStyle(fontSize: 18,color: Colors.white),),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kTravailFuteMainColor,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  textStyle: TextStyle(fontSize: 18,color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}