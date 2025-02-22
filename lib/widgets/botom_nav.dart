import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travail_fute/constants.dart';
import 'package:travail_fute/providers/user_provider.dart';
import 'package:travail_fute/screens/home_page.dart';
import 'package:travail_fute/screens/login.dart';
import 'package:travail_fute/utils/provider.dart';

class BottomNavBar extends StatelessWidget {
  final VoidCallback onMenuPressed;

  const BottomNavBar({required this.onMenuPressed, super.key, required Color backgroundColor});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var width = size.width;

    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.home, size: width * 0.07),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage(user: {}, deviceToken: '')),
              );
            },
          ),
          SizedBox(width: width * 0.1), // Empty space to center the FAB
          IconButton(
            icon: Icon(Icons.list, size: width * 0.07),
            onPressed: onMenuPressed,
          ),
        ],
      ),
    );
  }
}

class BottomNavBarStateful extends StatefulWidget {
  const BottomNavBarStateful({super.key});

  @override
  _BottomNavBarStatefulState createState() => _BottomNavBarStatefulState();
}

class _BottomNavBarStatefulState extends State<BottomNavBarStateful> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
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

    return Stack(
      children: [
        BottomNavBar(
          onMenuPressed: () {
            if (_controller.isDismissed) {
              _controller.forward();
            } else {
              _controller.reverse();
            }
          }, backgroundColor: kTravailFuteMainColor,
        ),
        Positioned(
          top: 0,
          bottom: 0,
          right: 0,
          child: SlideTransition(
            position: _offsetAnimation,
            child: Container(
              color: Colors.white,
              width: width * 0.6,
              height: size.height,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: Icon(Icons.person),
                    title: Text('Profile'),
                    onTap: () {
                      // Implement profile navigation here
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.logout),
                    title: Text('Logout'),
                    onTap: () {
                      logout(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
