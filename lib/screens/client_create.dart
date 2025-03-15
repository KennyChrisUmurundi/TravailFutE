import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:travail_fute/constants.dart';
import 'package:travail_fute/screens/clients.dart';
import 'package:travail_fute/services/clients_service.dart';
import 'package:travail_fute/widgets/loading.dart';
import 'package:travail_fute/utils/logger.dart';

class ClientCreatePage extends StatefulWidget {
  const ClientCreatePage({super.key});

  @override
  State<ClientCreatePage> createState() => _ClientCreatePageState();
}

class _ClientCreatePageState extends State<ClientCreatePage> with SingleTickerProviderStateMixin {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  final ClientService clientService = ClientService();
  bool isLoading = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  final Map<String, bool> _validationStates = {
    'Téléphone': false,
    'Rue': false,
    'Ville': false,
    'Code Postal': false,
    'Nom': false,
    'Prénom': false,
    'Email': false,
  };

  final Map<String, String> _errorMessages = {
    'Téléphone': '10 chiffres requis',
    'Rue': 'Champ non rempli',
    'Ville': 'Champ non rempli',
    'Code Postal': '4 chiffres requis',
    'Nom': 'Champ non rempli',
    'Prénom': 'Champ non rempli',
    'Email': 'Email invalide',
  };

  // Only Téléphone is mandatory
  bool get _isFormValid => _validationStates['Téléphone']!;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _validateField(String fieldName, String? value) {
    setState(() {
      switch (fieldName) {
        case 'Téléphone':
          _validationStates[fieldName] = (value?.length == 10);
          break;
        case 'Rue':
        case 'Ville':
        case 'Nom':
        case 'Prénom':
          _validationStates[fieldName] = (value?.isNotEmpty ?? false);
          break;
        case 'Code Postal':
          _validationStates[fieldName] = (value?.length == 4);
          break;
        case 'Email':
          _validationStates[fieldName] = RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value ?? '');
          break;
      }
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.saveAndValidate()) {
      setState(() => isLoading = true);
      try {
        logger.i(_formKey.currentState!.value);
        await clientService.createClient(context, _formKey.currentState!.value);
        Navigator.pop(context);
        Navigator.push(
              context, MaterialPageRoute(builder: (_) => ClientsList()));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la création du client: $e')),
        );
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [kTravailFuteMainColor.withOpacity(0.2), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  _buildHeader(size),
                  Expanded(child: _buildForm(size)),
                ],
              ),
              if (isLoading) _buildLoadingOverlay(),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildHeader(Size size) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kTravailFuteMainColor, kTravailFuteSecondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: FadeTransition(
              opacity: _animation,
              child: Text(
                'Nouveau Client',
                style: TextStyle(
                  fontSize: size.width * 0.06,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      offset: Offset(1, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(Size size) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(size.width * 0.06),
      child: FadeTransition(
        opacity: _animation,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.grey[50]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
            border: Border.all(color: Colors.grey[200]!, width: 1),
          ),
          padding: EdgeInsets.all(size.width * 0.06),
          child: FormBuilder(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ModernTextField(
                  name: 'first_name',
                  label: 'Nom',
                  icon: Icons.person,
                  isValid: _validationStates['Nom']!,
                  errorMessage: _errorMessages['Nom']!,
                  animation: _animation,
                  onChanged: (value) => _validateField('Nom', value),
                ),
                ModernTextField(
                  name: 'last_name',
                  label: 'Prénom',
                  icon: Icons.person,
                  isValid: _validationStates['Prénom']!,
                  errorMessage: _errorMessages['Prénom']!,
                  animation: _animation,
                  onChanged: (value) => _validateField('Prénom', value),
                ),
                ModernTextField(
                  name: 'phone_number',
                  label: 'Téléphone *',
                  icon: Icons.phone,
                  isValid: _validationStates['Téléphone']!,
                  errorMessage: _errorMessages['Téléphone']!,
                  animation: _animation,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  onChanged: (value) => _validateField('Téléphone', value),
                ),
                ModernTextField(
                  name: 'email',
                  label: 'Email',
                  icon: Icons.email,
                  isValid: _validationStates['Email']!,
                  errorMessage: _errorMessages['Email']!,
                  animation: _animation,
                  onChanged: (value) => _validateField('Email', value),
                ),
                ModernTextField(
                  name: 'address_street',
                  label: 'Rue',
                  icon: Icons.location_on,
                  isValid: _validationStates['Rue']!,
                  errorMessage: _errorMessages['Rue']!,
                  animation: _animation,
                  onChanged: (value) => _validateField('Rue', value),
                ),
                ModernTextField(
                  name: 'address_town',
                  label: 'Ville',
                  icon: Icons.location_city,
                  isValid: _validationStates['Ville']!,
                  errorMessage: _errorMessages['Ville']!,
                  animation: _animation,
                  onChanged: (value) => _validateField('Ville', value),
                ),
                ModernTextField(
                  name: 'postal_code',
                  label: 'Code Postal',
                  icon: Icons.local_post_office,
                  isValid: _validationStates['Code Postal']!,
                  errorMessage: _errorMessages['Code Postal']!,
                  animation: _animation,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  onChanged: (value) => _validateField('Code Postal', value),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.4),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Loading(),
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return Tooltip(
      message: _isFormValid ? 'Créer le client' : 'Le numéro de téléphone est requis (10 chiffres)',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        child: FloatingActionButton(
          onPressed: _isFormValid ? _submitForm : null,
          backgroundColor: _isFormValid ? kTravailFuteMainColor : Colors.grey[400],
          elevation: _isFormValid ? 10 : 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: ScaleTransition(
            scale: _animation,
            child: Icon(
              Icons.check,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
      ),
    );
  }
}

class ModernTextField extends StatelessWidget {
  final String name;
  final String label;
  final IconData icon;
  final bool isValid;
  final String errorMessage;
  final Animation<double> animation;
  final ValueChanged<String?>? onChanged;
  final List<TextInputFormatter>? inputFormatters;

  const ModernTextField({
    super.key,
    required this.name,
    required this.label,
    required this.icon,
    required this.isValid,
    required this.errorMessage,
    required this.animation,
    this.onChanged,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.only(bottom: size.height * 0.025),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormBuilderTextField(
            name: name,
            onChanged: onChanged,
            inputFormatters: inputFormatters,
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              prefixIcon: Icon(icon, color: kTravailFuteMainColor, size: 22),
              suffixIcon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: isValid
                    ? Icon(Icons.check_circle, color: Colors.green, key: ValueKey('valid-$name'))
                    : Icon(Icons.error_outline, color: Colors.red, key: ValueKey('invalid-$name')),
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: isValid ? Colors.green : Colors.grey[300]!,
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: kTravailFuteMainColor, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              floatingLabelBehavior: FloatingLabelBehavior.auto,
            ),
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (!isValid)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 16),
              child: FadeTransition(
                opacity: animation,
                child: Text(
                  errorMessage,
                  style: TextStyle(
                    color: Colors.red[700],
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}