import 'package:flutter/material.dart';
import 'package:travail_fute/constants.dart';
import 'package:travail_fute/screens/register.dart';
import 'package:travail_fute/services/credential_service.dart';
import 'dart:convert';
import 'home_page.dart';
import 'package:travail_fute/utils/logger.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneNumberController = TextEditingController();
  final _pinController = TextEditingController();
  final CredentialService _credentialService = CredentialService();
  bool _isLoading = false;
  bool _isPhoneValid = false;
  bool _isPinValid = false;

  @override
  void initState() {
    super.initState();
    _phoneNumberController.addListener(_validatePhone);
    _pinController.addListener(_validatePin);
  }

  @override
  void dispose() {
    _phoneNumberController.removeListener(_validatePhone);
    _pinController.removeListener(_validatePin);
    _phoneNumberController.dispose();
    _pinController.dispose();
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
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    final phone = _phoneNumberController.text;
    final pin = _pinController.text;

    final response = await _credentialService.login(context, phone, pin);

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      try {
        final responseData = jsonDecode(response.body);
        final user = responseData['user'];
        final deviceToken = responseData['device_token'];
        
        logger.i('Login successful: $responseData');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage(user: user, deviceToken: deviceToken)),
        );
      } catch (e) {
        _showErrorDialog('Error parsing server response: ${e.toString()}');
      }
    } else {
      logger.i(response);
      try {
        final responseData = jsonDecode(response.body);
        final errorMessage = responseData['non_field_errors'] != null
            ? responseData['non_field_errors'].join(', ')
            : 'Pin ou Numero de telephone incorrect';
        _showErrorDialog(errorMessage);
      } catch (e) {
        _showErrorDialog('Erreur réseau ou serveur indisponible. Veuillez vérifier votre connexion et réessayer.');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Échec de la connexion'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
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
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(
                  width: 100,
                  height: 100,
                  child: Center(
                    child: Icon(
                      Icons.password,
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
                        controller: _phoneNumberController,
                        keyboardType: TextInputType.number,
                        maxLength: 10,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.phone),
                          labelText: 'Entrez votre numéro de téléphone',
                          labelStyle: const TextStyle(fontSize: 10, color: Color.fromARGB(255, 119, 111, 111)),
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
                          labelStyle: const TextStyle(fontSize: 10, color: Color.fromARGB(255, 119, 111, 111)),
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
                    : Column(
                        children: [
                          ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: kTravailFuteMainColor,
                              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                              textStyle: const TextStyle(
                                  fontSize: 18,
                                  fontFamily: "Poppins",
                                  fontWeight: FontWeight.bold),
                            ),
                            child: const Text('Connexion'),
                          ),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const RegistrationScreen()),
                              );
                            },
                            child: const Text(
                              "Pas de compte? S'inscrire",
                              style: TextStyle(color: kTravailFuteMainColor),
                            ),
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void main() => runApp(MaterialApp(
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegistrationScreen(),
      },
    ));