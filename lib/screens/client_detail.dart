import 'package:flutter/material.dart';
import 'package:travail_fute/constants.dart';
import 'package:travail_fute/screens/create_project_screen.dart';
import 'package:travail_fute/services/clients_service.dart';
import 'package:travail_fute/widgets/main_card.dart';
import 'package:travail_fute/screens/edit_client.dart';
import 'package:url_launcher/url_launcher.dart';

class ClientDetail extends StatefulWidget {
  const ClientDetail({super.key, required this.client, this.phoneNumber});
  final String? phoneNumber;
  final Map<String, dynamic> client;

  @override
  State<ClientDetail> createState() => _ClientDetailState();
}

class _ClientDetailState extends State<ClientDetail> with SingleTickerProviderStateMixin {
  final ClientService clientService = ClientService();
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    if (widget.phoneNumber != null) {
      clientService.getClientByPhone(context, widget.phoneNumber!).then((client) {
        setState(() {
          widget.client.addAll(client);
        });
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              kTravailFuteMainColor.withOpacity(0.05),
              kWhiteColor,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(width),
                SizedBox(height: width * 0.04),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                  child: _buildClientInfo(width),
                ),
                SizedBox(height: width * 0.06),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                  child: _buildStatsSection(size, width),
                ),
                SizedBox(height: width * 0.1), // Extra space for FAB
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _buildEditFAB(width),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildHeader(double width) {
    return Container(
      padding: EdgeInsets.all(width * 0.04),
      decoration: BoxDecoration(
        color: kWhiteColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: kTravailFuteMainColor, size: width * 0.06),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Text(
                'Détails du Client',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: width * 0.05,
                  fontWeight: FontWeight.w700,
                  color: kTravailFuteMainColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientInfo(double width) {
    final phoneNumber = widget.client['phone_number']?.toString().replaceFirst('+32', '0') ?? 'N/A';
    final formattedPhone = phoneNumber.replaceAllMapped(
      RegExp(r'(\d{4})(\d{2})(\d{2})(\d{2})'),
      (Match m) => '${m[1]} ${m[2]} ${m[3]} ${m[4]}',
    );
    final fullName = '${widget.client['first_name'] ?? ''} ${widget.client['last_name'] ?? ''}'.trim();
    final address = '${widget.client['address_street'] ?? ''}, ${widget.client['address_town'] ?? ''} ${widget.client['postal_code'] ?? ''}'.trim();

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: kWhiteColor,
        child: Padding(
          padding: EdgeInsets.all(width * 0.05),
          child: Column(
            children: [
              CircleAvatar(
                radius: width * 0.12,
                backgroundColor: kTravailFuteMainColor.withOpacity(0.1),
                child: Icon(
                  Icons.person,
                  color: kTravailFuteMainColor,
                  size: width * 0.12,
                ),
              ),
              SizedBox(height: width * 0.04),
              Text(
                fullName.isNotEmpty ? fullName : 'Nom inconnu',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: width * 0.06,
                  fontWeight: FontWeight.w700,
                  color: kTravailFuteSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: width * 0.015),
              Text(
                formattedPhone.isNotEmpty ? formattedPhone : 'Numéro inconnu',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: width * 0.045,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: width * 0.015),
              Text(
                address.isNotEmpty ? address : 'Adresse inconnue',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: width * 0.035,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: width * 0.05),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    icon: Icons.phone,
                    color: Colors.green.shade400,
                    label: 'Appeler',
                    onTap: () => _launchURL(Uri(scheme: 'tel', path: widget.client['phone_number'])),
                  ),
                  _buildActionButton(
                    icon: Icons.sms,
                    color: Colors.blue.shade400,
                    label: 'Message',
                    onTap: () => _launchURL(Uri(scheme: 'sms', path: widget.client['phone_number'])),
                  ),
                  _buildActionButton(
                    icon: Icons.location_on,
                    color: Colors.indigo.shade400,
                    label: 'Carte',
                    onTap: () => _launchURL(Uri.parse(
                      "geo:0,0?q=${widget.client['address_street'] ?? ''}, ${widget.client['address_town'] ?? ''} ${widget.client['postal_code'] ?? ''}",
                    )),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(Size size, double width) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistiques',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: width * 0.045,
              fontWeight: FontWeight.w600,
              color: kTravailFuteMainColor,
            ),
          ),
          SizedBox(height: width * 0.03),
          Row(
            children: [
              Expanded(
                child: MainCard(
                  size,
                  onPress: () {},
                  label: 'Devis',
                  icon: Icons.euro,
                  value: 1,
                  completed: 5,
                  cardColor: kWhiteColor,
                ),
              ),
              SizedBox(width: width * 0.03),
              Expanded(
                child: MainCard(
                  size,
                  onPress: () {},
                  label: 'Factures',
                  icon: Icons.receipt,
                  value: 89,
                  completed: 89,
                  cardColor: kWhiteColor,
                ),
              ),
            ],
          ),
          SizedBox(height: width * 0.03),
          Row(
            children: [
              Expanded(
                child: MainCard(
                  size,
                  onPress: () {},
                  label: 'Chantiers',
                  icon: Icons.build,
                  value: 89,
                  completed: 89,
                  cardColor: kWhiteColor,
                ),
              ),
              SizedBox(width: width * 0.03),
              Expanded(
                child: MainCard(
                  size,
                  onPress: () {},
                  label: 'Gestion',
                  icon: Icons.folder,
                  value: 1,
                  completed: 5,
                  cardColor: kTravailFuteMainColor,
                  textColor: kWhiteColor,
                  addOption: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditFAB(double width) {
  return FloatingActionButton(
    onPressed: () => _showActionDialog(context, width),
    backgroundColor: Colors.transparent,
    elevation: 0,
    child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kTravailFuteMainColor, kTravailFuteSecondaryColor],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: kTravailFuteMainColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(width * 0.04),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Icon(Icons.add, color: kWhiteColor, size: width * 0.07), // Changed to "add" icon
      ),
    ),
  );
}

void _showActionDialog(BuildContext context, double width) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withOpacity(0.4),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return Center(
        child: Material(
          color: Colors.transparent,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
            ),
            child: Container(
              width: width * 0.8,
              padding: EdgeInsets.all(width * 0.05),
              decoration: BoxDecoration(
                color: kWhiteColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    'Nouvelle Action',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: width * 0.05,
                      fontWeight: FontWeight.w600,
                      color: kTravailFuteMainColor,
                    ),
                  ),
                  SizedBox(height: width * 0.04),
                  // Action Options
                  _buildActionOption(
                    context: context,
                    width: width,
                    icon: Icons.construction,
                    label: 'Nouveau Chantier',
                    color: kTravailFuteMainColor,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CreateProjectScreen(user: widget.client)),
                        );
                    },
                  ),
                  SizedBox(height: width * 0.03),
                  _buildActionOption(
                    context: context,
                    width: width,
                    icon: Icons.euro,
                    label: 'Nouveau Devis',
                    color: kTravailFuteSecondaryColor,
                    onTap: () {
                      Navigator.pop(context);
                      
                    },
                  ),
                  SizedBox(height: width * 0.03),
                  _buildActionOption(
                    context: context,
                    width: width,
                    icon: Icons.receipt,
                    label: 'Nouvelle Facture',
                    color: const Color.fromARGB(255, 97, 97, 97),
                    onTap: () {
                      Navigator.pop(context);
                      
                    },
                  ),
                  SizedBox(height: width * 0.03),
                  _buildActionOption(
                    context: context,
                    width: width,
                    icon: Icons.edit,
                    label: 'Modifier Client',
                    color: Colors.grey[700]!,
                    onTap: () {
                      Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EditClient(client: widget.client)),
                      );
                    },
                  ),
                  SizedBox(height: width * 0.04),
                  // Cancel Button
                  Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Annuler',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: width * 0.04,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

Widget _buildActionOption({
  required BuildContext context,
  required double width,
  required IconData icon,
  required String label,
  required Color color,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.symmetric(vertical: width * 0.03, horizontal: width * 0.04),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: width * 0.06),
          SizedBox(width: width * 0.03),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: width * 0.045,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ),
          Icon(Icons.chevron_right, color: color.withOpacity(0.5), size: width * 0.05),
        ],
      ),
    ),
  );
}

  void _launchURL(Uri? url) async {
    if (url != null && await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible de lancer l\'action')),
      );
    }
  }
}