import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smswatcher/smswatcher.dart';
import 'package:travail_fute/constants.dart';
import 'package:phone_state/phone_state.dart';
import 'package:travail_fute/screens/assistant.dart';
import 'package:travail_fute/screens/client_create.dart';
import 'package:travail_fute/screens/message_provider_screen.dart';
import 'package:travail_fute/screens/notification_screen.dart';
import 'package:travail_fute/screens/profile_screen.dart';
import 'package:travail_fute/screens/project_screen.dart';
import 'package:travail_fute/screens/receipt.dart';
import 'package:travail_fute/services/phone_state_service.dart';
// import 'package:flutter_sms_manager/flutter_sms_manager.dart';
import 'package:travail_fute/utils/logger.dart';
import 'clients.dart';

class HomePage extends StatefulWidget {
  final Map<String, dynamic> user;
  final String deviceToken;

  const HomePage({super.key, required this.user, required this.deviceToken});

  @override
  State<HomePage> createState() => _HomePageState();
}

void waitPermission() async {
  await Permission.sms.request();
  await Permission.phone.request();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  PhoneState status = PhoneState.nothing();
  late PhoneStateService phoneStateService;
  // final _smsListenerPlugin = Smswatcher();
  // List<Map<String, dynamic>> _smsList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..forward();
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    
    waitPermission();
    phoneStateService = PhoneStateService(context);
    phoneStateService.startListening();
    // _fetchSms();
  }

  // Future<void> _fetchSms() async {
  //   setState(() => _isLoading = true);
  //   try {
  //     final smsList = await SmsManager.fetchSms();
  //     setState(() => _smsList = smsList);
  //   } catch (e) {
  //     logger.i('Error fetching SMS: $e');
  //   } finally {
  //     setState(() => _isLoading = false);
  //   }
  // }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
          child: Column(
            children: [
              // _buildHeader(size),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(size.width * 0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWelcomeSection(size),
                      SizedBox(height: size.height * 0.03),
                      _buildActionButtons(size),
                      SizedBox(height: size.height * 0.03),
                      _buildMainCards(size),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // bottomNavigationBar: BottomNavBar(
      //   onMenuPressed: () {},
      //   backgroundColor: Colors.white.withOpacity(0.95),
      // ),
      // floatingActionButton: _buildFAB(),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildHeader(Size size) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kTravailFuteMainColor, const Color.fromARGB(255, 197, 175, 175)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeTransition(
            opacity: _animation,
            child: Image.asset(
              'assets/images/splash.png',
              height: size.height * 0.05,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(Size size) {
    return FadeTransition(
      opacity: _animation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bonjour, ${widget.user['username']}',
            style: TextStyle(
              fontSize: size.width * 0.07,
              fontWeight: FontWeight.bold,
              color: kTravailFuteMainColor,
              shadows: [
                Shadow(
                  color: Colors.black12,
                  offset: Offset(2, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          Text(
            'Prêt à gérer votre journée?',
            style: TextStyle(
              fontSize: size.width * 0.04,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Size size) {
    return Row(
      children: [
        _buildActionButton(
          size,
          'Mon Assistant',
          kTravailFuteMainColor,
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => Assistant())),
        ),
        SizedBox(width: size.width * 0.03),
        // _buildActionButton(
        //   size,
        //   'Chantiers',
        //   Colors.white,
        //   () {},
        //   textColor: kTravailFuteSecondaryColor,
        //   borderColor: kTravailFuteSecondaryColor,
        // ),
      ],
    );
  }

  Widget _buildActionButton(Size size, String title, Color color, VoidCallback onPress, 
      {Color? textColor, Color? borderColor}) {
    return Expanded(
      child: GestureDetector(
        onTap: onPress,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: size.height * 0.015),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(15),
            border: borderColor != null ? Border.all(color: borderColor) : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: textColor ?? Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: size.width * 0.04,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainCards(Size size) {
    return Column(
      children: [
        Row(
          children: [
            _buildCard(size, 'Clients', Icons.people, 89, 89, () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => ClientsList())),
              addOption: true,
              onAddPress: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => ClientCreatePage())),
            ),
            SizedBox(width: size.width * 0.03),
            _buildCard(size, 'Messages', Icons.message, 1, 5, () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const MessageProviderScreen()))),
          ],
        ),
        SizedBox(height: size.height * 0.02),
        Row(
          children: [
            _buildCard(size, 'Chantiers', Icons.build, 1, 5, () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const ProjectScreen()))),
            SizedBox(width: size.width * 0.03),
            _buildCard(size, 'Factures', Icons.receipt, 89, 89, () =>Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ReceiptScreen()),
            )),
          ],
        ),
        SizedBox(height: size.height * 0.02),
        Row(
          children: [
            _buildCard(size, 'Devis', Icons.euro, 1, 5, () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => Assistant()))),
            SizedBox(width: size.width * 0.03),
            // _buildCard(size, 'Factures', Icons.receipt, 89, 89, () =>Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (context) => const ReceiptScreen()),
            // )),
          ],
        ),
        SizedBox(height: size.height * 0.02),
        Row(
          children: [
            _buildCard(size, 'Profil', Icons.person_pin_circle_sharp, 1, 5, () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => ProfileScreen(user: widget.user)))),
            SizedBox(width: size.width * 0.03),
            _buildCard(size, 'Notifications', Icons.notifications, 89, 89, () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => NotificationScreen())),
              cardColor: kTravailFuteMainColor,
              textColor: Colors.white),
          ],
        ),
      ],
    );
  }

  Widget _buildCard(Size size, String label, IconData icon, int value, int completed, 
      VoidCallback onPress, {bool addOption = false, VoidCallback? onAddPress, Color? cardColor, Color? textColor}) {
    return Expanded(
      child: GestureDetector(
        onTap: onPress,
        child: ScaleTransition(
          scale: _animation,
          child: Container(
            padding: EdgeInsets.all(size.width * 0.07),
            decoration: BoxDecoration(
              color: cardColor ?? Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(icon, color: textColor ?? kTravailFuteMainColor, size: size.width * 0.07),
                    if (addOption)
                      GestureDetector(
                        onTap: onAddPress,
                        child: Icon(Icons.add_circle_outline, color: kTravailFuteSecondaryColor),
                      ),
                  ],
                ),
                SizedBox(height: size.height * 0.01),
                Text(
                  label,
                  style: TextStyle(
                    color: textColor ?? Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: size.width * 0.04,
                  ),
                ),
                // Text(
                //   '$value/$completed',
                //   style: TextStyle(
                //     color: textColor?.withOpacity(0.7) ?? Colors.grey[600],
                //     fontSize: size.width * 0.035,
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: () {},
      backgroundColor: kTravailFuteMainColor,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Icon(Icons.add, size: 30),
    );
  }
}