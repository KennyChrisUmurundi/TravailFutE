import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:travail_fute/constants.dart';
import 'package:travail_fute/services/clients_service.dart';
import 'package:travail_fute/widgets/loading.dart';

class ClientCreatePage extends StatefulWidget {
  final String deviceToken;
  const ClientCreatePage({super.key, required this.deviceToken});

  @override
  State<ClientCreatePage> createState() => _ClientCreatePageState();
}

class _ClientCreatePageState extends State<ClientCreatePage> with SingleTickerProviderStateMixin {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  final ClientService clientService = ClientService();
  bool isLoading = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  // Validation states
  final Map<String, bool> _validationStates = {
    'Telephone': false,
    'Rue': false,
    'Ville': false,
    'Code Postal': false,
    'Nom': false,
    'Prenom': false,
    'Email': false,
  };

  bool get _isFormValid => _validationStates.values.every((isValid) => isValid);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _validateField(String fieldName, String? value) {
    setState(() {
      switch (fieldName) {
        case 'Telephone':
          _validationStates[fieldName] = (value?.length == 10);
          break;
        case 'Rue':
        case 'Ville':
        case 'Nom':
        case 'Prenom':
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
        await clientService.createClient(context, _formKey.currentState!.value);
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating client: $e')),
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
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [kTravailFuteMainColor.withOpacity(0.1), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  _buildHeader(size),
                  Expanded(
                    child: _buildForm(size),
                  ),
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
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: kTravailFuteMainColor),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: FadeTransition(
              opacity: _animation,
              child: Text(
                'Create New Client',
                style: TextStyle(
                  fontSize: size.width * 0.05,
                  fontWeight: FontWeight.bold,
                  color: kTravailFuteMainColor,
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
      padding: EdgeInsets.all(size.width * 0.05),
      child: FadeTransition(
        opacity: _animation,
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: EdgeInsets.all(size.width * 0.05),
            child: FormBuilder(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ModernTextField(
                    name: 'Nom',
                    label: 'Last Name',
                    icon: Icons.person,
                    onChanged: (value) => _validateField('Nom', value),
                  ),
                  ModernTextField(
                    name: 'Prenom',
                    label: 'First Name',
                    icon: Icons.person,
                    onChanged: (value) => _validateField('Prenom', value),
                  ),
                  ModernTextField(
                    name: 'Telephone',
                    label: 'Phone',
                    icon: Icons.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    onChanged: (value) => _validateField('Telephone', value),
                  ),
                  ModernTextField(
                    name: 'Email',
                    label: 'Email',
                    icon: Icons.email,
                    onChanged: (value) => _validateField('Email', value),
                  ),
                  ModernTextField(
                    name: 'Rue',
                    label: 'Street',
                    icon: Icons.location_on,
                    onChanged: (value) => _validateField('Rue', value),
                  ),
                  ModernTextField(
                    name: 'Ville',
                    label: 'City',
                    icon: Icons.location_city,
                    onChanged: (value) => _validateField('Ville', value),
                  ),
                  ModernTextField(
                    name: 'Code Postal',
                    label: 'Postal Code',
                    icon: Icons.local_post_office,
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
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: const Center(child: Loading()),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: _isFormValid ? _submitForm : null,
      backgroundColor: _isFormValid ? kTravailFuteMainColor : Colors.grey,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ScaleTransition(
        scale: _animation,
        child: const Icon(Icons.check, color: Colors.white, size: 30),
      ),
    );
  }
}

class ModernTextField extends StatelessWidget {
  final String name;
  final String label;
  final IconData icon;
  final ValueChanged<String?>? onChanged;
  final List<TextInputFormatter>? inputFormatters;

  const ModernTextField({
    super.key,
    required this.name,
    required this.label,
    required this.icon,
    this.onChanged,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.only(bottom: size.height * 0.02),
      child: FormBuilderTextField(
        name: name,
        onChanged: onChanged,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[600]),
          prefixIcon: Icon(icon, color: kTravailFuteMainColor),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kTravailFuteMainColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        ),
        style: const TextStyle(fontSize: 16, color: Colors.black87),
      ),
    );
  }
}