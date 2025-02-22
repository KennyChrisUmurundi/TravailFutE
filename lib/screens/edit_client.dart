import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:travail_fute/constants.dart';
import 'package:travail_fute/screens/client_detail.dart';
import 'package:travail_fute/services/clients_service.dart';

class EditClient extends StatefulWidget {
  const EditClient({super.key, required this.client});
  final Map<String, dynamic> client;

  @override
  _EditClientState createState() => _EditClientState();
}

class _EditClientState extends State<EditClient> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _addressController;
  late TextEditingController _addressTownController;
  late TextEditingController _addressCodeController;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.client['first_name']);
    _lastNameController = TextEditingController(text: widget.client['last_name']);
    _emailController = TextEditingController(text: widget.client['email']);
    // _phoneNumberController = TextEditingController(text: widget.client['phone_number']);
    _addressController = TextEditingController(text: widget.client['address_street']);
    _addressTownController = TextEditingController(text: widget.client['address_town']);
    _addressCodeController = TextEditingController(text: widget.client['postal_code']);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    // _phoneNumberController.dispose();
    _addressController.dispose();
    _addressCodeController.dispose();
    _addressTownController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var width = size.width;

    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        backgroundColor: kWhiteColor,
        foregroundColor: kTravailFuteSecondaryColor,
        title: Text(
          "Modifier le Client",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(width * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Modifier les détails du client',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: kTravailFuteSecondaryColor,
                ),
              ),
              // SizedBox(height: width * 0.03),
              // _buildTextField(_phoneNumberController, 'Numéro de Téléphone'),
              SizedBox(height: width * 0.03),
                _buildTextField(_addressController, 'Rue', isRequired: true),
              SizedBox(height: width * 0.03),
              _buildTextField(_addressTownController, 'Ville', isRequired: true),
              SizedBox(height: width * 0.03),
                _buildTextField(
                _addressCodeController,
                'Code Postal',
                isRequired: true,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                ),
              SizedBox(height: width * 0.03),
              _buildTextField(_firstNameController, 'Prénom'),
              SizedBox(height: width * 0.03),
              _buildTextField(_lastNameController, 'Nom de Famille'),
              SizedBox(height: width * 0.03),
              _buildTextField(_emailController, 'Adresse Email'),
              SizedBox(height: width * 0.1),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    final updatedClient = {
                      'first_name': _firstNameController.text,
                      'last_name': _lastNameController.text,
                      'email': _emailController.text,
                      'phone_number': widget.client['phone_number'],
                      'address_street': _addressController.text,
                      'address_town': _addressTownController.text,
                      'postal_code': _addressCodeController.text,
                    };

                    try {
                      print(updatedClient);
                      
                      await ClientService().updateClient(context, widget.client['id'].toString(), updatedClient);
                        ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Client updated successfully')),
                        );
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ClientDetail(client:widget.client),
                          ),
                        );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to update client: $e')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kTravailFuteMainColor,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    textStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: Text('Save', style: TextStyle(color: kWhiteColor)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText, {bool isRequired = false, List<dynamic> inputFormatters = const []}) {
    return TextField(
      style: TextStyle(color: kTravailFuteSecondaryColor, fontSize: 13),
      controller: controller,
      decoration: InputDecoration(
        labelText: isRequired ? '$labelText *' : labelText,
        labelStyle: TextStyle(color: kTravailFuteMainColor, fontSize: 10),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: const Color.fromARGB(255, 74, 74, 75)),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: const Color.fromARGB(255, 63, 63, 68), width: 2),
        ),
      ),
    );
  }
}