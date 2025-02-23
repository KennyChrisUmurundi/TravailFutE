import 'package:flutter/material.dart';
import 'package:travail_fute/constants.dart';
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
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

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
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [kTravailFuteMainColor.withOpacity(0.1), Colors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(size, width),
                Padding(
                  padding: EdgeInsets.all(width * 0.05),
                  child: Column(
                    children: [
                      _buildClientInfo(size, width),
                      SizedBox(height: width * 0.05),
                      _buildStatsSection(size, width),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _buildEditFAB(width),
    );
  }

  Widget _buildHeader(Size size, double width) {
    return Container(
      padding: EdgeInsets.all(width * 0.04),
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
                'Client Details',
                style: TextStyle(
                  fontSize: width * 0.05,
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

  Widget _buildClientInfo(Size size, double width) {
    return ScaleTransition(
      scale: _animation,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: EdgeInsets.all(width * 0.05),
          child: Column(
            children: [
              CircleAvatar(
                radius: width * 0.12,
                backgroundColor: kTravailFuteMainColor,
                child: Icon(Icons.person, color: kWhiteColor, size: width * 0.1),
              ),
              SizedBox(height: width * 0.04),
              Text(
                "${widget.client['first_name'] ?? ''} ${widget.client['last_name'] ?? ''}",
                style: TextStyle(
                  fontSize: width * 0.06,
                  fontWeight: FontWeight.bold,
                  color: kTravailFuteSecondaryColor,
                ),
              ),
              SizedBox(height: width * 0.02),
              Text(
                widget.client['phone_number']?.toString().replaceFirst('+32', '0').replaceAllMapped(
                      RegExp(r'(\d{4})(\d{2})(\d{2})(\d{2})'),
                      (Match m) => '${m[1]} ${m[2]} ${m[3]} ${m[4]}',
                    ) ??
                    '',
                style: TextStyle(
                  fontSize: width * 0.045,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: width * 0.02),
              Text(
                "${widget.client['address_street'] ?? 'No address recorded'}, ${widget.client['address_town'] ?? ''} ${widget.client['postal_code'] ?? ''}",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: width * 0.035,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: width * 0.04),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    icon: Icons.phone,
                    color: Colors.green,
                    onTap: () => _launchURL(Uri(scheme: 'tel', path: widget.client['phone_number']?.toString())),
                  ),
                  _buildActionButton(
                    icon: Icons.sms,
                    color: Colors.blue,
                    onTap: () => _launchURL(Uri(scheme: 'sms', path: widget.client['phone_number']?.toString())),
                  ),
                  _buildActionButton(
                    icon: Icons.location_on,
                    color: Colors.indigo,
                    onTap: () => _launchURL(Uri.parse(
                        "geo:0,0?q=${widget.client['address_street'] ?? ''}, ${widget.client['address_town'] ?? ''} ${widget.client['postal_code'] ?? ''}")),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: kWhiteColor, size: 24),
      ),
    );
  }

  Widget _buildStatsSection(Size size, double width) {
    return FadeTransition(
      opacity: _animation,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: MainCard(
                  onPress: () {},
                  label: 'Devis',
                  icon: Icons.euro,
                  value: 1,
                  completed: 5,
                  cardColor: kWhiteColor,
                  elevation: 8,
                ),
              ),
              SizedBox(width: width * 0.03),
              Expanded(
                child: MainCard(
                  onPress: () {},
                  label: 'Factures',
                  icon: Icons.receipt,
                  value: 89,
                  completed: 89,
                  cardColor: kWhiteColor,
                  elevation: 8,
                ),
              ),
            ],
          ),
          SizedBox(height: width * 0.03),
          Row(
            children: [
              Expanded(
                child: MainCard(
                  onPress: () {},
                  label: 'Interventions',
                  icon: Icons.task,
                  value: 89,
                  completed: 89,
                  cardColor: kWhiteColor,
                  elevation: 8,
                ),
              ),
              SizedBox(width: width * 0.03),
              Expanded(
                child: MainCard(
                  onPress: () {},
                  label: 'Gestion',
                  icon: Icons.folder,
                  value: 1,
                  completed: 5,
                  cardColor: kTravailFuteMainColor,
                  textColor: kWhiteColor,
                  addOption: false,
                  elevation: 8,
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
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EditClient(client: widget.client)),
        );
      },
      backgroundColor: kTravailFuteSecondaryColor,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ScaleTransition(
        scale: _animation,
        child: const Icon(Icons.edit, color: kWhiteColor, size: 30),
      ),
    );
  }

  void _launchURL(Uri? url) async {
    if (url != null && await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch action')),
      );
    }
  }
}