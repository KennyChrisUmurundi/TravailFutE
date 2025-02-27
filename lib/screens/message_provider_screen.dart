import 'package:flutter/material.dart';
import 'package:travail_fute/constants.dart';
import 'package:travail_fute/screens/messages_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class MessageProviderScreen extends StatefulWidget {
  const MessageProviderScreen({super.key});

  @override
  State<MessageProviderScreen> createState() => _MessageProviderScreenState();
}

class _MessageProviderScreenState extends State<MessageProviderScreen> with SingleTickerProviderStateMixin {
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
          child: Column(
            children: [
              _buildHeader(size, width),
              _buildInfoSection(size, width),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(width * 0.04),
                  child: _buildProviderList(size, width),
                ),
              ),
            ],
          ),
        ),
      ),
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
                'Messages',
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

  Widget _buildInfoSection(Size size, double width) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: width * 0.05, vertical: width * 0.02),
        padding: EdgeInsets.all(width * 0.04),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [kTravailFuteMainColor.withOpacity(0.8), kTravailFuteSecondaryColor.withOpacity(0.8)],
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: kTravailFuteMainColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: kWhiteColor,
              size: width * 0.06,
            ),
            SizedBox(width: width * 0.03),
            Expanded(
              child: Text(
                'Récupérez des messages clients directement dans TravailFuté ou créez et générez des notifications!',
                style: TextStyle(
                  fontSize: width * 0.04,
                  fontWeight: FontWeight.bold,
                  color: kWhiteColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
                 
            
          ],
              
        ),
      ),
    );
  }

  Widget _buildProviderList(Size size, double width) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildProviderCard(
          size,
          width,
          'Gmail',
          Icons.email,
          Colors.red,
          () => _launchGmail(),
        ),
        SizedBox(height: width * 0.04),
        _buildProviderCard(
          size,
          width,
          'WhatsApp Business',
          Icons.chat,
          Colors.green,
          () => _launchWhatsApp(),
        ),
        SizedBox(height: width * 0.04),
        _buildProviderCard(
          size,
          width,
          'SMS',
          Icons.sms,
          Colors.blue,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MessagesScreen()),
          ),
        ),
        SizedBox(height: width * 0.04),
        _buildProviderCard(
          size,
          width,
          'Facebook',
          Icons.facebook,
          Colors.blue,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MessagesScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildProviderCard(Size size, double width, String title, IconData icon, Color color, VoidCallback onTap) {
    return FadeTransition(
      opacity: _animation,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(width * 0.04),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color,
                radius: width * 0.06,
                child: Icon(icon, color: kWhiteColor, size: width * 0.07),
              ),
              SizedBox(width: width * 0.04),
              Text(
                title,
                style: TextStyle(
                  fontSize: width * 0.045,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _launchGmail() async {
    final gmailUri = Uri.parse('mailto:');
    if (await canLaunchUrl(gmailUri)) {
      await launchUrl(gmailUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch Gmail')),
      );
    }
  }

  void _launchWhatsApp() async {
    final whatsappUri = Uri.parse('whatsapp://send');
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch WhatsApp')),
      );
    }
  }
}