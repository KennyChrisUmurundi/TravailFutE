import 'package:flutter/material.dart';
import 'dart:ui'; // Add this import
import 'package:travail_fute/constants.dart';
import 'package:travail_fute/services/credential_service.dart'; // Update with your actual project name
import 'dart:convert';
import 'home_page.dart';
import 'package:flutter/services.dart'; // Added import for FilteringTextInputFormatter
import 'package:travail_fute/widgets/loading.dart'; // Add this import

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _pinController = TextEditingController();
  final CredentialService _credentialService = CredentialService();
  bool _isLoading = false; // Add loading state

  @override
  void dispose() {
    _phoneController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true; // Set loading state to true
    });

    final phone = _phoneController.text;
    final pin = _pinController.text;

    final response = await _credentialService.login(phone, pin);

    setState(() {
      _isLoading = false; // Set loading state to false
    });

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final user = responseData['user']; // Store the user instance
      final deviceToken = responseData['device_token']; // Store the device token
      print('Login successful: $responseData');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage(user: user, deviceToken: deviceToken)), // Inject user and device token into HomePage
      );
    } else {
      final responseData = jsonDecode(response.body);
      final errorMessage = responseData['non_field_errors'] != null
          ? responseData['non_field_errors'].join(', ')
          : 'Pin ou Numero de telephone incorrect';
      _showErrorDialog(errorMessage); // Show error dialog
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Échec de la connexion'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: kBackgroundColor,
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center( // Added Center widget
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // Center the column vertically
                children: <Widget>[
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      labelStyle: TextStyle(color: kTravailFuteMainColor), // Set text color
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: kTravailFuteMainColor), // Added border color
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: kTravailFuteMainColor), // Added focused border color
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _pinController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'PIN',
                      labelStyle: TextStyle(color: kTravailFuteMainColor), // Set text color
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: kTravailFuteMainColor), // Added border color
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: kTravailFuteMainColor), // Added focused border color
                      ),
                    ),
                    maxLength: 4, // Limit to 4 digits
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Only accept digits
                  ),
                  const SizedBox(height: 20),
                  _isLoading
                    ? const CircularProgressIndicator(backgroundColor: kTravailFuteMainColor,color: kProgressBarInactiveColor,) // Show loading indicator
                    : ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white, 
                          backgroundColor: kTravailFuteMainColor, // Set text color
                          padding:const EdgeInsets.symmetric(horizontal: 50, vertical: 15), // Increase button size
                          textStyle: const TextStyle(fontSize: 18,fontFamily: "Poppins",fontWeight: FontWeight.bold), // Increase font size
                        ),
                        child: const Text('Connexion'),
                      ),
                ],
              ),
            ),
          ),
        ),
        if (_isLoading) const Loading(), // Add loading widget
      ],
    );
  }
}

void main() => runApp(MaterialApp(
  home: LoginScreen(),
));