import 'package:flutter/material.dart';
import 'package:travail_fute/constants.dart';

class ConditionsScreen extends StatelessWidget {
  const ConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: kTravailFuteMainColor.withOpacity(0.3),
        dividerTheme: const DividerThemeData(space: 20),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Conditions Générales d’Utilisation'),
          backgroundColor: kTravailFuteMainColor,
          elevation: 4,
          shadowColor: Colors.black26,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Dernière mise à jour : 4 avril 2025'),
              const SizedBox(height: 30),
              _buildSection(
                icon: Icons.gavel_rounded,
                title: 'Acceptation des Conditions',
                content: '''Ces Conditions constituent un accord juridique entre vous ("Utilisateur") et le développeur de TravailFuté. Nous nous réservons le droit de mettre à jour ces Conditions à tout moment.''',
              ),
              _buildSection(
                icon: Icons.money_off_rounded,
                title: 'Nature Non Monétisée',
                content: '''TravailFuté est fourni gratuitement pour un usage personnel et professionnel. L’Application n’est pas monétisée - pas de frais, pas de publicités.''',
              ),
              _buildSection(
                icon: Icons.person_outline_rounded,
                title: 'Éligibilité',
                content: '''Vous devez avoir au moins 18 ans pour utiliser l’Application.''',
              ),
              _buildSection(
                icon: Icons.security_rounded,
                title: 'Responsabilités',
                content: '''Vous êtes responsable de la sécurité de votre appareil et des données saisies.''',
              ),
              _buildSection(
                icon: Icons.data_object_rounded,
                title: 'Gestion des Données',
                content: '''Les données sont stockées localement sur votre appareil. Nous ne collectons pas de données personnelles.''',
              ),
              _buildSection(
                icon: Icons.warning_amber_rounded,
                title: 'Absence de Garantie',
                content: '''TravailFuté est fourni "tel quel" sans aucune garantie de performance.''',
              ),
              _buildSection(
                icon: Icons.balance_rounded,
                title: 'Loi Applicable',
                content: '''Ces Conditions sont régies par les lois de la Belgique.''',
              ),
              const SizedBox(height: 40),
              _buildContactCard(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String text) {
    return Center(
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade600,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 28,
              color: kTravailFuteMainColor,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: kTravailFuteMainColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    content,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildContactCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: kTravailFuteMainColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contactez-Nous',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: kTravailFuteMainColor,
              ),
            ),
            const SizedBox(height: 15),
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade800,
                  height: 1.5,
                ),
                children: const [
                  TextSpan(
                    text: 'Email: ',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  TextSpan(
                    text: 'kenny.chris.mail@gmail.com\n',
                    style: TextStyle(decoration: TextDecoration.underline),
                  ),
                  TextSpan(
                    text: 'Réponse sous: ',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  TextSpan(text: '2-5 jours ouvrés'),
                ],
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              'Projet non monétisé - Merci pour votre compréhension !',
              style: TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}