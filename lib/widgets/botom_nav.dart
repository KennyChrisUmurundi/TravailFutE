import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travail_fute/constants.dart';
import 'package:travail_fute/providers/user_provider.dart';
import 'package:travail_fute/screens/home_page.dart';
import 'package:travail_fute/screens/login.dart';
import 'package:travail_fute/utils/provider.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var width = size.width;
    var height = size.height;
    final token = Provider.of<TokenProvider>(context, listen: false);
    final user = Provider.of<UserProvider>(context, listen: false);

    // Responsive height: 70 for larger screens, scaled down for smaller ones
    double navHeight = height > 600 ? 70 : height * 0.1;

    return Container(
      height: navHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            kTravailFuteMainColor.withOpacity(0.95),
            kTravailFuteMainColor,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: width * 0.05, // Scales with screen width
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Center(
        child: GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(
                  user: user.user!,
                  deviceToken: 'Token $token',
                ),
              ),
            );
          },
          child: Container(
            padding: EdgeInsets.all(width * 0.03), // Responsive padding
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: kTravailFuteMainColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(2, 2),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(-2, -2),
                ),
              ],
            ),
            child: Icon(
              Icons.home,
              size: width > 600 ? 32 : width * 0.08, // Caps at 32 for large screens
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ),
      ),
    );
  }
}

class BottomNavBarStateful extends StatefulWidget {
  const BottomNavBarStateful({super.key});

  @override
  _BottomNavBarStatefulState createState() => _BottomNavBarStatefulState();
}

class _BottomNavBarStatefulState extends State<BottomNavBarStateful>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void logout(BuildContext context) {
    final tokenProvider = Provider.of<TokenProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    tokenProvider.clearToken();
    userProvider.clearUser();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var width = size.width;
    var height = size.height;

    // Responsive menu width: 65% on small screens, capped at 400px on large screens
    double menuWidth = width > 600 ? 400 : width * 0.65;

    return Stack(
      children: [
        BottomNavBar(),
        Positioned(
          top: 0,
          bottom: 0,
          right: 0,
          child: SlideTransition(
            position: _offsetAnimation,
            child: Container(
              width: menuWidth,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: width * 0.05, // Scales with screen width
                    offset: const Offset(-5, 0),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        width * 0.05, // Responsive padding
                        height * 0.02,
                        width * 0.05,
                        height * 0.01,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(width * 0.02),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: kTravailFuteMainColor.withOpacity(0.1),
                            ),
                            child: Icon(
                              Icons.menu,
                              color: kTravailFuteMainColor,
                              size: width > 600 ? 24 : width * 0.06,
                            ),
                          ),
                          SizedBox(width: width * 0.03),
                          Text(
                            'Options',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: width > 600 ? 20 : width * 0.05,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1, color: Colors.grey[300]),
                    Expanded(
                      child: ListView(
                        children: [
                          _buildMenuItem(
                            icon: Icons.logout_rounded,
                            title: 'Logout',
                            onTap: () => logout(context),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: height > 600 ? 80 : height * 0.12, // Responsive FAB position
          right: width > 600 ? 20 : width * 0.04,
          child: FloatingActionButton(
            onPressed: () {
              if (_controller.isDismissed) {
                _controller.forward();
              } else {
                _controller.reverse();
              }
            },
            backgroundColor: Colors.white,
            elevation: 4,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                _controller.isDismissed ? Icons.menu_rounded : Icons.close_rounded,
                key: ValueKey(_controller.isDismissed),
                color: kTravailFuteMainColor,
                size: width > 600 ? 28 : width * 0.07,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    var width = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: width * 0.01),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(width * 0.02),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: kTravailFuteMainColor.withOpacity(0.1),
          ),
          child: Icon(
            icon,
            color: kTravailFuteMainColor,
            size: width > 600 ? 22 : width * 0.055,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: width > 600 ? 16 : width * 0.04,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
        onTap: onTap,
        hoverColor: Colors.grey[100],
        contentPadding: EdgeInsets.symmetric(horizontal: width * 0.05),
      ),
    );
  }
}