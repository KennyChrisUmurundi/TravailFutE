import 'package:flutter/material.dart';

class MessageCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String trailing;
  final VoidCallback onTap;

  const MessageCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      margin: EdgeInsets.zero,
      color: Colors.white,
      child: ListTile(
        leading: CircleAvatar(
        backgroundColor: [Colors.green, const Color.fromARGB(255, 224, 96, 139), const Color.fromARGB(255, 224, 139, 13), const Color.fromARGB(255, 172, 81, 188)][title.hashCode % 4],
        child: Icon(Icons.person,color: Colors.white,), // Display the first letter of the sender's name
        ),
        title: Text(title, style: TextStyle(fontSize:14,fontWeight: FontWeight.bold,color: const Color.fromARGB(255, 32, 32, 32))),
        subtitle: Text(subtitle, style: TextStyle(color: const Color.fromARGB(255, 71, 70, 70), fontSize: 12.0)),
        trailing: Text(trailing),
        onTap: onTap,
      ),
    );
  }
}
