import 'package:flutter/material.dart';
import 'dart:ui'; // Add this import
import 'package:travail_fute/constants.dart';
import 'package:travail_fute/services/credential_service.dart'; // Update with your actual project name
import 'dart:convert';
import 'home_page.dart';
import 'package:flutter/services.dart'; // Added import for FilteringTextInputFormatter
import 'package:travail_fute/widgets/loading.dart'; // Add this import
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController _pinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Login'),
      // ),
      body: Center(
        child: SizedBox(
          width: 400, // Set container width
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Center the column vertically
            children: <Widget>[
              // Add image placeholder
              const SizedBox(
                width: 100,
                height: 100,
                child: Center(
                  child: Icon(
                    Icons.password, // Icon
                    size: 50,
                    color: kTravailFuteMainColor, // Icon color
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _pinController,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  obscureText: true, // Hide the PIN input
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock),
                    labelText: 'Entrez un code PIN à 4 chiffres',
                    labelStyle: const TextStyle(fontSize:10,color: Color.fromARGB(255, 119, 111, 111)), // Set text color
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kTravailFuteMainColor, // Set button color
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10), // Set button padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Set rounded corner
                  ),
                ),
                onPressed: () async {
                  final pin = _pinController.text;
                  final credentialService = CredentialService();
                  try {
                    final response = await credentialService.login(context, pin);
                    if (response.statusCode == 200) {
                      // Handle successful login
                      print('Login successful');
                    } else {
                      // Handle login failure
                      print('Login failed');
                    }
                  } catch (e) {
                    print('Error: $e');
                  }
                },
                child: Text('Connexion', style: TextStyle(fontSize: 14,color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() => runApp(MaterialApp(
  home: LoginScreen(),
));