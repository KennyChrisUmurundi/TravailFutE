import 'package:flutter/material.dart';
import 'package:travail_fute/constants.dart';
import 'package:travail_fute/screens/condition_screen.dart';
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
  bool _acceptedTerms = false;

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
    if (!_isPhoneValid || !_isPinValid || !_isPinMatch || !_acceptedTerms) {
      _showErrorDialog('Please fill all fields correctly and accept terms');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _credentialService.register(
        context,
        _usernameController.text,
        _phoneNumberController.text,
        _pinController.text,
      );

      setState(() => _isLoading = false);
      
      if (response.statusCode == 201) {
        _showSuccessDialog();
      } else {
        final responseData = jsonDecode(response.body);
        String errorMessage = 'Registration failed';
        
        if (responseData['non_field_errors'] != null) {
          errorMessage = responseData['non_field_errors'].join(', ');
        } else if (responseData['phone_number'] != null) {
          errorMessage = responseData['phone_number'].join(', ');
        }
        
        _showErrorDialog(errorMessage);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog('Network error: ${e.toString()}');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registration Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registration Successful'),
        content: const Text('Account created successfully! Please login.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person_add, size: 80, color: kTravailFuteMainColor),
                const SizedBox(height: 30),
                _buildInputField(
                  controller: _usernameController,
                  icon: Icons.person,
                  label: 'Nom d`utilisateur',
                ),
                const SizedBox(height: 15),
                _buildInputField(
                  controller: _phoneNumberController,
                  icon: Icons.phone,
                  label: 'Numero de telephone',
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                ),
                const SizedBox(height: 15),
                _buildInputField(
                  controller: _pinController,
                  icon: Icons.lock,
                  label: '4-digit PIN',
                  obscureText: true,
                  maxLength: 4,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 15),
                _buildInputField(
                  controller: _pin2Controller,
                  icon: Icons.lock_outline,
                  label: 'Confirm PIN',
                  obscureText: true,
                  maxLength: 4,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Checkbox(
                      value: _acceptedTerms,
                      onChanged: (value) => setState(() => _acceptedTerms = value ?? false),
                      activeColor: kTravailFuteMainColor,
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder:(context) => ConditionsScreen()));
                        },
                        child: const Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'I agree to the ',
                                style: TextStyle(color: Colors.black87),
                              ),
                              TextSpan(
                                text: 'Terms and Conditions',
                                style: TextStyle(
                                  color: kTravailFuteMainColor,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                _isLoading
                    ? const CircularProgressIndicator(color: kTravailFuteMainColor)
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: (_isPhoneValid && _isPinValid && _isPinMatch && _acceptedTerms)
                              ? _register
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kTravailFuteMainColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text(
                            'Enregistrer',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                          ),
                        ),
                      ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  ),
                  child: const Text(
                    'Vous avez un compte? Connectez vous ici',
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

  Widget _buildInputField({
    required TextEditingController controller,
    required IconData icon,
    required String label,
    bool obscureText = false,
    int? maxLength,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      maxLength: maxLength,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: kTravailFuteMainColor),
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kTravailFuteMainColor, width: 2),
        ),
      ),
    );
  }
}