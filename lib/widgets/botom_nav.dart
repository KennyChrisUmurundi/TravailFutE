import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              // Implement home navigation here
            },
          ),
          // IconButton(
          //   icon: Icon(Icons.explore),
          //   onPressed: () {
          //     // Implement explore navigation here
          //   },
          // ),
          const SizedBox(), // Empty space to center the FAB
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // Implement profile navigation here
            },
          ),
        ],
      ),
    );
  }
}
