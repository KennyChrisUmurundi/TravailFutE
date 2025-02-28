import 'package:flutter/material.dart';
import 'package:travail_fute/constants.dart';
import 'package:travail_fute/screens/client_detail.dart';

class ClientCard extends StatefulWidget {
  const ClientCard({
    super.key,
    required this.client,
  });

  final Map<String, dynamic> client;

  @override
  State<ClientCard> createState() => _ClientCardState();
}

class _ClientCardState extends State<ClientCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ClientDetail(client: widget.client)),
    );
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final phoneNumber = widget.client['phone_number']?.replaceFirst('+32', '0') ?? 'N/A';
    final formattedPhone = phoneNumber.replaceAllMapped(
      RegExp(r'(\d{4})(\d{2})(\d{2})(\d{2})'),
      (Match m) => '${m[1]} ${m[2]} ${m[3]} ${m[4]}',
    );
    final clientName = '${widget.client['first_name'] ?? ''} ${widget.client['last_name'] ?? ''}'.trim();
    final address = '${widget.client['address_street'] ?? ''} ${widget.client['address_town'] ?? 'Adresse inconnue'}'.trim();

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(12.0),
          margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
          width: double.infinity,
          decoration: BoxDecoration(
            color: kWhiteColor,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8.0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar
              CircleAvatar(
                radius: 24.0,
                backgroundColor: kTravailFuteMainColor.withOpacity(0.1),
                child: Icon(
                  Icons.person,
                  color: kTravailFuteMainColor,
                  size: 28.0,
                ),
              ),
              const SizedBox(width: 12.0),
              // Client Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.phone,
                          size: 14.0,
                          color: kTravailFuteMainColor.withOpacity(0.7),
                        ),
                        const SizedBox(width: 6.0),
                        Text(
                          formattedPhone.isNotEmpty ? formattedPhone : 'Numéro inconnu',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                            color: const Color.fromARGB(255, 19, 18, 18),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.location_city,
                          size: 14.0,
                          color: kTravailFuteMainColor.withOpacity(0.7),
                        ),
                        const SizedBox(width: 6.0),
                        Expanded(
                          child: Text(
                            address.isNotEmpty ? address : 'Adresse inconnue',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                              fontSize: 12.0,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4.0),
                    // Client Name
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          size: 14.0,
                          color: kTravailFuteMainColor.withOpacity(0.7),
                        ),
                        const SizedBox(width: 6.0),
                        Expanded(
                          child: Text(
                            clientName.isNotEmpty ? clientName : 'Nom non fourni',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 14.0,
                        color: Color.fromARGB(255, 79, 79, 80),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Trailing Arrow
              Icon(
                Icons.chevron_right,
                color: kTravailFuteMainColor.withOpacity(0.5),
                size: 20.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}