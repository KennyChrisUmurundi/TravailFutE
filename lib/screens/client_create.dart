import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:http/http.dart' as http;
import 'package:travail_fute/constants.dart';
import 'package:travail_fute/widgets/botom_nav.dart';
import 'package:travail_fute/widgets/foab.dart';

class ClientCreatePage extends StatefulWidget {
  const ClientCreatePage({super.key});

  @override
  State<ClientCreatePage> createState() => _ClientCreatePageState();
}

class _ClientCreatePageState extends State<ClientCreatePage> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  final String apiUrl = 'YOUR_API_ENDPOINT';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        // title: SearchEngine(),
      ),
      backgroundColor: kBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FormBuilder(
          key: _formKey,
          autovalidateMode: AutovalidateMode.disabled,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const FormTextField(
                  textLabel: 'Nom',
                  // textHint: 'Jean',
                  icon: Icons.person,
                ),
                const SizedBox(
                  height: 5,
                ),
                const FormTextField(
                  textLabel: 'Prenom',
                  // textHint: 'Jean',
                  icon: Icons.person,
                ),
                const SizedBox(
                  height: 5,
                ),
                const FormTextField(
                  textLabel: 'Addresse',
                  // textHint: 'Jean',
                  icon: Icons.location_on,
                ),
                const SizedBox(
                  height: 5,
                ),
                const FormTextField(
                  textLabel: 'Telephone',
                  // textHint: 'Jean',
                  icon: Icons.phone,
                ),

                // FormBuilderTextField(
                //   name: 'Prenom',
                //   decoration: InputDecoration(labelText: 'Dupont'),
                //   // Add validation and initial value as needed
                // ),
                // FormBuilderTextField(
                //   name: 'Addresse',
                //   decoration: InputDecoration(labelText: 'Rue xyz 49/12'),
                //   // Add validation and initial value as needed
                // ),
                // FormBuilderTextField(
                //   name: 'Telephone',
                //   decoration: InputDecoration(
                //     labelText: 'Telephone',
                //     labelStyle: kCardSmallTextStyle,
                //   ),
                //   // Add validation and initial value as needed
                // ),
                // Repeat for other form fields (first_name, last_name, etc.)
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(kTravailFuteMainColor),
                    minimumSize: MaterialStateProperty.all<Size>(Size(150, 50)),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.saveAndValidate()) {
                      // Send a POST request to your API to create the client
                      final response = await http.post(
                        Uri.parse(apiUrl),
                        body: _formKey.currentState!.value,
                      );

                      if (response.statusCode == 201) {
                        // Client created successfully, handle success
                      } else {
                        // Handle API error
                      }
                    }
                  },
                  child: const Text(
                    'Enregistrer',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(),
      floatingActionButton: const MyCenteredFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class FormTextField extends StatelessWidget {
  const FormTextField({
    super.key,
    required this.textLabel,
    // required this.textHint,
    required this.icon,
  });

  final String textLabel;
  // final String textHint;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
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
          // border: OutlineInputBorder(
          //   borderRadius: BorderRadius.circular(15),
          // ),
        ),
      ),
    );
  }
}
