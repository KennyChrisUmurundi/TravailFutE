import 'package:flutter/material.dart';
import 'dart:ui'; // Add this import
import 'package:travail_fute/constants.dart';
import 'package:travail_fute/services/credential_service.dart'; // Update with your actual project name
import 'dart:convert';
import 'home_page.dart';
import 'package:flutter/services.dart'; // Added import for FilteringTextInputFormatter
import 'package:travail_fute/widgets/loading.dart'; // Add this import

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _pinController = TextEditingController();
  final CredentialService _credentialService = CredentialService();
  bool _isLoading = false; // Add loading state
  bool _isPhoneValid = false; // Add phone validation state
  bool _isPinValid = false; // Add PIN validation state

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_validatePhone); // Add listener to validate phone number
    _pinController.addListener(_validatePin); // Add listener to validate PIN
  }

  @override
  void dispose() {
    _phoneController.removeListener(_validatePhone); // Remove listener
    _pinController.removeListener(_validatePin); // Remove listener
    _phoneController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _validatePhone() {
    setState(() {
      _isPhoneValid = _phoneController.text.length == 10;
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

    final phone = _phoneController.text;
    final pin = _pinController.text;

    final response = await _credentialService.login(context,phone, pin);

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
    return Stack(
      children: [
        Scaffold(
          backgroundColor: kBackgroundColor,
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Center( // Added Center widget
                child: SizedBox(
                  width: 400, // Set container width
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center, // Center the column vertically
                    children: <Widget>[
                      // Add image placeholder
                      const SizedBox(
                        width: 100,
                        height: 100,
                        // color: Colors.grey, // Placeholder color
                        child: Center(
                          child: Icon(
                            Icons.login, // Icon
                            size: 50,
                            color: kTravailFuteMainColor, // Icon color
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.phone),
                          labelText: 'Numero de telephone',
                          labelStyle: const TextStyle(color: kTravailFuteMainColor), // Set text color
                          border: const OutlineInputBorder(
                            borderSide: BorderSide(color: kTravailFuteMainColor), // Added border color
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: kTravailFuteMainColor), // Added focused border color
                          ),
                          suffixIcon: _isPhoneValid
                              ? const Icon(Icons.check, color: Colors.green)
                              : null, // Add tick icon if phone number is valid
                        ),
                        maxLength: 10, // Limit to 10 digits
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly, // Only accept digits
                          LengthLimitingTextInputFormatter(10), // Ensure exactly 10 digits
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _pinController,
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock),
                          labelText: 'PIN de 4 chiffres',
                          labelStyle: const TextStyle(color: kTravailFuteMainColor), // Set text color
                          border: const OutlineInputBorder(
                            borderSide: BorderSide(color: kTravailFuteMainColor), // Added border color
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: kTravailFuteMainColor), // Added focused border color
                          ),
                          suffixIcon: _isPinValid
                              ? const Icon(Icons.check, color: Colors.green)
                              : null, // Add tick icon if PIN is valid
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