import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:travail_fute/constants.dart';
import 'package:travail_fute/services/clients_service.dart'; // Import ClientService
import 'package:travail_fute/widgets/botom_nav.dart';

import 'package:travail_fute/widgets/loading.dart'; // Import Loading widget

class ClientCreatePage extends StatefulWidget {
  final String deviceToken;
  const ClientCreatePage({super.key, required this.deviceToken});

  @override
  State<ClientCreatePage> createState() => _ClientCreatePageState();
}

class _ClientCreatePageState extends State<ClientCreatePage> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  final ClientService clientService = ClientService(); // Create an instance of ClientService
  bool isLoading = false; // Add loading state
  bool _isNameValid = false;
  bool _isSurnameValid = false;
  bool _isAddressValid = false;
  bool _isPhoneValid = false;

  bool get _isFormValid => _isNameValid && _isSurnameValid && _isAddressValid && _isPhoneValid;

  @override
  void initState() {
    super.initState();
    _formKey.currentState?.fields['Nom']?.didChange(_validateName);
    _formKey.currentState?.fields['Prenom']?.didChange(_validateSurname);
    _formKey.currentState?.fields['Addresse']?.didChange(_validateAddress);
    _formKey.currentState?.fields['Telephone']?.didChange(_validatePhone);
  }

  @override
  void dispose() {
    // No need to remove onChanged listeners as they are not explicitly added
    super.dispose();
  }

  void _validateName() {
    setState(() {
      _isNameValid = _formKey.currentState?.fields['Nom']?.value.isNotEmpty ?? false;
    });
  }

  void _validateSurname() {
    setState(() {
      _isSurnameValid = _formKey.currentState?.fields['Prenom']?.value.isNotEmpty ?? false;
    });
  }

  void _validateAddress() {
    setState(() {
      _isAddressValid = _formKey.currentState?.fields['Addresse']?.value.isNotEmpty ?? false;
    });
  }

  void _validatePhone() {
    setState(() {
      _isPhoneValid = _formKey.currentState?.fields['Telephone']?.value.length == 10;
    });
  }

  @override
  Widget build(BuildContext context) {
    // LOCAL VARIABLES
    var size = MediaQuery.of(context).size;
    var width = size.width;
    var height = size.height;

    return Stack(
      children: [
        Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            // title: SearchEngine(),
            title: const Text('Enregistrer un client', style: TextStyle(color: kTravailFuteSecondaryColor, fontSize: 15, fontWeight: FontWeight.bold,fontFamily: 'Poppins'),),
          ),
          backgroundColor: kBackgroundColor,
          body: Padding(
            padding: EdgeInsets.all(width * 0.025),
            child: FormBuilder(
              key: _formKey,
              autovalidateMode: AutovalidateMode.disabled,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: width * 0.020,
                    ),
                    FormTextField(
                      textLabel: 'Nom',
                      icon: Icons.person,
                      isValid: _isNameValid,
                      onChanged: (value) => _validateName(),
                    ),
                    SizedBox(
                      height: width * 0.015,
                    ),
                    FormTextField(
                      textLabel: 'Prenom',
                      icon: Icons.person,
                      isValid: _isSurnameValid,
                      onChanged: (value) => _validateSurname(),
                    ),
                    SizedBox(
                      height: width * 0.015,
                    ),
                    FormTextField(
                      textLabel: 'Addresse',
                      icon: Icons.location_on,
                      isValid: _isAddressValid,
                      onChanged: (value) => _validateAddress(),
                    ),
                    SizedBox(
                      height: width * 0.015,
                    ),
                    FormTextField(
                      textLabel: 'Telephone',
                      icon: Icons.phone,
                      isValid: _isPhoneValid,
                      onChanged: (value) => _validatePhone(),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly, // Only accept digits
                        LengthLimitingTextInputFormatter(10), // Limit to 10 digits
                      ],
                    ),
                    SizedBox(
                      height: width * 0.05,
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.all<Color>(kTravailFuteMainColor),
                        minimumSize:
                            WidgetStateProperty.all<Size>(const Size(150, 50)),
                      ),
                      onPressed: _isFormValid ? () async {
                        if (_formKey.currentState!.saveAndValidate()) {
                          setState(() {
                            isLoading = true; // Set loading to true
                          });
                          await clientService.createClient(widget.deviceToken, _formKey.currentState!.value);
                          setState(() {
                            isLoading = false; // Set loading to false
                          });
                          Navigator.pop(context); // Navigate back to the previous screen
                        }
                      } : null, // Disable button if form is not valid
                      child: const Text(
                        'Enregistrer',
                        style: TextStyle(fontWeight: FontWeight.bold,fontFamily: 'Poppins',fontSize: 15,),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: const BottomNavBar(),
          // floatingActionButton: const MyCenteredFAB(),
          // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        ),
        if (isLoading) const Loading(), // Add loading widget
      ],
    );
  }
}

class FormTextField extends StatelessWidget {
  const FormTextField({
    super.key,
    required this.textLabel,
    required this.icon,
    required this.isValid,
    required this.onChanged,
    this.inputFormatters,
  });

  final String textLabel;
  final IconData icon;
  final bool isValid;
  final ValueChanged<String?>? onChanged;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
      // LOCAL VARIABLES
      var size = MediaQuery.of(context).size;
      var width = size.width;

    return Container(
      padding:  EdgeInsets.all(width * 0.020),
      child: FormBuilderTextField(
        name: textLabel,
        decoration: InputDecoration(
          labelText: textLabel,
          labelStyle: const TextStyle(color: Colors.grey),
          icon: Icon(icon),
          iconColor: kTravailFuteMainColor,
          focusColor: kTravailFuteMainColor,
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: kTravailFuteMainColor),
          ),
          border: const OutlineInputBorder(
            borderSide: BorderSide(color: kTravailFuteMainColor),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          errorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(vertical: width * 0.025, horizontal: width * 0.030),
          suffixIcon: isValid ? const Icon(Icons.check, color: Colors.green) : null, // Add tick icon if valid
        ),
        style: const TextStyle(color: Colors.black),
        onChanged: onChanged,
        inputFormatters: inputFormatters,
      ),
    );
  }
}
