import 'package:flutter/material.dart';
import 'package:travail_fute/constants.dart';
import 'package:travail_fute/services/credential_service.dart'; // Update with your actual project name
import 'dart:convert';
import 'home_page.dart';
// Added import for FilteringTextInputFormatter
// import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneNumberController = TextEditingController();
  final _pinController = TextEditingController();
  final CredentialService _credentialService = CredentialService();
  bool _isLoading = false; // Add loading state
  bool _isPhoneValid = false; // Add phone validation state
  bool _isPinValid = false; // Add PIN validation state

  @override
  void initState() {
    super.initState();
    _phoneNumberController.addListener(_validatePhone); // Add listener to validate phone number
    _pinController.addListener(_validatePin); // Add listener to validate PIN
  }

  @override
  void dispose() {
    _phoneNumberController.removeListener(_validatePhone); // Remove listener
    _pinController.removeListener(_validatePin); // Remove listener
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
      _isLoading = true; // Set loading state to true
    });

    final phone = _phoneNumberController.text;
    final pin = _pinController.text;

    final response = await _credentialService.login(context, phone, pin);

    setState(() {
      _isLoading = false; // Set loading state to false
    });

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final user = responseData['user']; // Store the user instance
      final deviceToken = responseData['device_token']; // Store the device token
      
      // Save user and device token in SharedPreferences
      // final prefs = await SharedPreferences.getInstance();
      // await prefs.setString('user', jsonEncode(user));
      // await prefs.setString('device_token', deviceToken);

      print('Login successful: $responseData');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage(user: user, deviceToken: deviceToken)), // Inject user and device token into HomePage
      );
    } else {
      print(response);
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
      // appBar: AppBar(
      //   title: Text('Login'),
      // ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: MediaQuery.of(context).viewInsets.bottom),
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
                  child: Column(
                    children: [
                      TextField(
                        controller: _phoneNumberController, // Use the phone number controller
                        keyboardType: TextInputType.number,
                        maxLength: 10,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.phone),
                          labelText: 'Entrez votre numéro de téléphone',
                          labelStyle: const TextStyle(fontSize: 10, color: Color.fromARGB(255, 119, 111, 111)), // Set text color
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      TextField(
                        controller: _pinController,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        obscureText: true, // Hide the PIN input
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock),
                          labelText: 'Entrez un code PIN à 4 chiffres',
                          labelStyle: const TextStyle(fontSize: 10, color: Color.fromARGB(255, 119, 111, 111)), // Set text color
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
    );
  }
}


void main() => runApp(MaterialApp(
  home: LoginScreen(),
));