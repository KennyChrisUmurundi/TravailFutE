import 'package:flutter/material.dart';
import 'package:travail_fute/screens/home_page.dart'; // Import HomePage

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    var size = MediaQuery.of(context).size;
    var width = size.width;
    var height = size.height;

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
                MaterialPageRoute(builder: (context) =>  HomePage(user: {}, deviceToken: '')), // Navigate to HomePage
              );
            },
          ),
          // IconButton(
          //   icon: Icon(Icons.explore, size: width * 0.07),
          //   onPressed: () {
          //     // Implement explore navigation here
          //   },
          // ),
          SizedBox(width: width * 0.1), // Empty space to center the FAB
          IconButton(
            icon: Icon(Icons.list, size: width * 0.07),
            onPressed: () {
              // Implement profile navigation here
            },
          ),
        ],
      ),
    );
  }
}
