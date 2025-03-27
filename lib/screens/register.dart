import 'package:flutter/material.dart';
import 'package:travail_fute/constants.dart';
import 'package:travail_fute/screens/login.dart';
import 'package:travail_fute/services/credential_service.dart';
import 'dart:convert';
import 'package:travail_fute/utils/logger.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _usernameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _pinController = TextEditingController();
  final _pin2Controller = TextEditingController();
  final CredentialService _credentialService = CredentialService();
  bool _isLoading = false;
  bool _isPhoneValid = false;
  bool _isPinValid = false;
  bool _isPinMatch = false;

  @override
  void initState() {
    super.initState();
    _phoneNumberController.addListener(_validatePhone);
    _pinController.addListener(_validatePin);
    _pin2Controller.addListener(_validatePinMatch);
  }

  @override
  void dispose() {
    _phoneNumberController.removeListener(_validatePhone);
    _pinController.removeListener(_validatePin);
    _pin2Controller.removeListener(_validatePinMatch);
    _usernameController.dispose();
    _phoneNumberController.dispose();
    _pinController.dispose();
    _pin2Controller.dispose();
    super.dispose();
  }

  void _validatePhone() {
    setState(() {
      _isPhoneValid = _phoneNumberController.text.length == 10;
    });
  }

  void _validatePin() {
    setState(() {
      _isPinValid = _pinController.text.length == 4;
    });
    _validatePinMatch();
  }

  void _validatePinMatch() {
    setState(() {
      _isPinMatch = _pinController.text == _pin2Controller.text &&
          _pin2Controller.text.isNotEmpty;
    });
  }

  Future<void> _register() async {
    if (!_isPhoneValid || !_isPinValid || !_isPinMatch) {
      _showErrorDialog('Veuillez remplir correctement tous les champs');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final username = _usernameController.text;
    final phone = _phoneNumberController.text;
    final pin = _pinController.text;
  

    try {
      final response = await _credentialService.register(
        context,
        username,
        phone,
        pin,
      );

      setState(() {
        _isLoading = false;
      });
      logger.i('Registration response: ${response.body}');
      if (response.statusCode == 201) {
        logger.i('Registration successful');
        _showSuccessDialog();
      } else {
        final responseData = jsonDecode(response.body);
        String errorMessage = 'Registration failed';
        
        if (responseData['non_field_errors'] != null) {
          errorMessage = responseData['non_field_errors'].join(', ');
        } else if (responseData['phone_number'] != null) {
          errorMessage = responseData['phone_number'].join(', ');
        } else if (responseData.containsKey('detail')) {
          errorMessage = responseData['detail'];
        }
        
        _showErrorDialog(errorMessage);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Network error: ${e.toString()}');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: const Text('Échec de l\'inscription'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: const Text('Inscription réussie'),
            content: const Text('Compte créé avec succès ! Veuillez vous connecter.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: 16.0, vertical: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(
                  width: 100,
                  height: 100,
                  child: Center(
                    child: Icon(
                      Icons.person_add,
                      size: 50,
                      color: kTravailFuteMainColor,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.person),
                            labelText: 'Entrez un nom d\'utilisateur',
                          labelStyle: const TextStyle(
                              fontSize: 10, color: Color.fromARGB(255, 119, 111, 111)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _phoneNumberController,
                        keyboardType: TextInputType.number,
                        maxLength: 10,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.phone),
                            labelText: 'Entrez votre numéro de téléphone',
                          labelStyle: const TextStyle(
                              fontSize: 10, color: Color.fromARGB(255, 119, 111, 111)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      TextField(
                        controller: _pinController,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        obscureText: true,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock),
                            labelText: 'Entrez un code PIN à 4 chiffres',
                          labelStyle: const TextStyle(
                              fontSize: 10, color: Color.fromARGB(255, 119, 111, 111)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      TextField(
                        controller: _pin2Controller,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        obscureText: true,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock),
                            labelText: 'Confirmez le code PIN à 4 chiffres',
                          labelStyle: const TextStyle(
                              fontSize: 10, color: Color.fromARGB(255, 119, 111, 111)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? const CircularProgressIndicator(
                        backgroundColor: kTravailFuteMainColor,
                        color: kProgressBarInactiveColor,
                      )
                    : ElevatedButton(
                        onPressed: _register,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: kTravailFuteMainColor,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 15),
                          textStyle: const TextStyle(
                              fontSize: 18,
                              fontFamily: "Poppins",
                              fontWeight: FontWeight.bold),
                        ),
                        child: const Text('S\'inscrire'),
                      ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                  child: const Text(
                    'Vous avez déjà un compte? Connectez-vous',
                    style: TextStyle(color: kTravailFuteMainColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Update your main function to include both screens
void main() => runApp(MaterialApp(
      initialRoute: '/register',
      routes: {
        '/register': (context) => const RegistrationScreen(),
        '/login': (context) => const LoginScreen(),
      },
    ));