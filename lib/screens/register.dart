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

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms and Conditions'),
        content: SingleChildScrollView(
          child: Column(
            children: const [
              Text('''Conditions Générales d’Utilisation de Travail Futé

Dernière mise à jour : 4 avril 2025

Bienvenue sur Travail Futé, une application mobile gratuite et non monétisée conçue pour aider les utilisateurs à gérer leurs tâches quotidiennes, leurs clients, leurs projets et leurs notifications. En téléchargeant, installant ou utilisant Travail Futé (l’"Application"), vous acceptez d’être lié par ces Conditions Générales d’Utilisation ("Conditions"). Si vous n’acceptez pas ces Conditions, veuillez ne pas utiliser l’Application.
1. Acceptation des Conditions

Ces Conditions constituent un accord juridique entre vous ("Utilisateur" ou "vous") et le développeur de Travail Futé ("Développeur", "nous" ou "notre"). Nous nous réservons le droit de mettre à jour ces Conditions à tout moment, les modifications prenant effet dès leur publication dans l’Application ou sur un site associé. Votre utilisation continue de l’Application après ces mises à jour signifie votre acceptation des Conditions révisées.
2. Objectif et Nature Non Monétisée

Travail Futé est fourni gratuitement pour un usage personnel et professionnel afin d’aider à la gestion des tâches, au suivi des clients, à l’organisation des projets et aux notifications. L’Application n’est pas monétisée, ce qui signifie que nous ne facturons pas de frais, n’affichons pas de publicités et ne générons pas de revenus par son utilisation. Elle est proposée comme un projet personnel pour votre commodité et utilité, sans garantie de performance de niveau commercial.
3. Éligibilité

Vous devez avoir au moins 13 ans pour utiliser l’Application. En utilisant Travail Futé, vous déclarez remplir cette condition d’âge et avoir la capacité juridique d’accepter ces Conditions.
4. Licence d’Utilisation

Nous vous accordons une licence non exclusive, non transférable et révocable pour utiliser l’Application à des fins personnelles et non commerciales, sous réserve de ces Conditions. Vous ne devez pas :

    Modifier, désassembler, décompiler ou effectuer une ingénierie inverse de l’Application.
    Distribuer, vendre, sous-licencier ou commercialiser l’Application de quelque manière que ce soit.
    Utiliser l’Application d’une manière qui enfreint les lois applicables ou ces Conditions.

5. Responsabilités de l’Utilisateur

Vous êtes responsable de :

    Maintenir la sécurité de votre appareil et des données saisies dans l’Application.
    Accorder les autorisations nécessaires (par exemple, SMS, état du téléphone) pour que l’Application fonctionne comme prévu. Le refus de ces autorisations peut limiter les fonctionnalités.
    Vous assurer que votre utilisation de l’Application respecte toutes les lois locales, nationales et internationales.

6. Autorisations et Données

Travail Futé peut demander des autorisations pour accéder aux SMS, à l’état du téléphone ou à d’autres fonctionnalités de votre appareil afin d’offrir des services comme la surveillance des appels ou les notifications. Nous ne collectons, ne stockons ni ne transmettons ces données à des serveurs externes, sauf si cela est explicitement requis pour les fonctionnalités de l’Application (par exemple, appels API vers vos services). Toutes les données traitées restent sur votre appareil, et nous ne sommes pas responsables de leur sécurité ou de leur sauvegarde.
7. Services Tiers

L’Application peut s’intégrer à des services tiers (par exemple, des API pour la gestion de projets ou de reçus). Vous êtes responsable de vos interactions avec ces services, y compris le respect de leurs conditions et de tout coût associé. Nous ne sommes pas responsables de la performance, de la disponibilité ou de la sécurité des services tiers.
8. Absence de Garantie

Travail Futé est fourni "tel quel" et "tel que disponible", sans aucune garantie, expresse ou implicite, y compris, mais sans s’y limiter, l’adéquation à un usage particulier, la qualité marchande ou l’absence de contrefaçon. Nous ne garantissons pas :

    Que l’Application sera exempte d’erreurs, ininterrompue ou sécurisée.
    L’exactitude, la fiabilité ou l’exhaustivité des informations fournies par l’Application.
    La compatibilité avec tous les appareils ou systèmes d’exploitation.

9. Limitation de Responsabilité

Dans la mesure maximale permise par la loi, le Développeur ne sera pas responsable des dommages directs, indirects, accessoires, spéciaux, consécutifs ou exemplaires découlant de votre utilisation de l’Application, y compris, mais sans s’y limiter, la perte de données, de profits ou d’opportunités commerciales. En tant qu’application non monétisée, vous utilisez l’Application à vos propres risques, et nous n’assumons aucune responsabilité pour tout préjudice ou perte résultant de son utilisation.
10. Indemnisation

Vous acceptez d’indemniser, de défendre et de dégager de toute responsabilité le Développeur contre toute réclamation, tout dommage, toute perte ou toute dépense (y compris les frais juridiques) découlant de votre utilisation de l’Application, de la violation de ces Conditions ou de l’atteinte aux droits d’un tiers.
11. Résiliation

Nous pouvons résilier ou suspendre votre accès à l’Application à tout moment, sans préavis ni responsabilité, pour quelque raison que ce soit, y compris en cas de violation de ces Conditions. En cas de résiliation, votre droit d’utiliser l’Application cesse immédiatement.
12. Propriété Intellectuelle

Tout le contenu, le design et le code de Travail Futé sont la propriété intellectuelle du Développeur ou nous sont licenciés. Vous ne pouvez pas reproduire, distribuer ou créer des œuvres dérivées de l’Application sans notre consentement écrit préalable.
13. Confidentialité

Travail Futé ne collecte pas de données personnelles à des fins de monétisation ou de partage. Toutes les données que vous saisissez (par exemple, détails des clients, informations sur les projets) sont stockées localement sur votre appareil. Nous ne sommes pas responsables de la perte de données, des violations de sécurité ou de l’accès non autorisé à votre appareil. Pour les fonctionnalités nécessitant une connexion internet (par exemple, appels API), consultez les politiques de confidentialité des services tiers concernés.
14. Loi Applicable

Ces Conditions sont régies par les lois de la France, sans égard aux principes de conflit de lois. Tout litige sera résolu devant les tribunaux compétents en France.
15. Contactez-Nous

Si vous avez des questions concernant ces Conditions, contactez-nous à l’adresse [Insérez votre email, par exemple, "support@travailfute.com"]. Étant un projet non monétisé, les délais de réponse peuvent varier.
16. Accord Intégral

Ces Conditions constituent l’accord complet entre vous et le Développeur concernant l’utilisation de Travail Futé, remplaçant tout accord ou entendement préalable.'''),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
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
                  label: 'Username',
                ),
                const SizedBox(height: 15),
                _buildInputField(
                  controller: _phoneNumberController,
                  icon: Icons.phone,
                  label: 'Phone Number',
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
                        onTap: _showTermsDialog,
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
                            'REGISTER',
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
                    'Already have an account? Login here',
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