import 'package:flutter/material.dart';
import 'package:travail_fute/constants.dart';
import 'package:travail_fute/screens/client_detail.dart';
import 'package:travail_fute/services/clients_service.dart';

class MessageCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String trailing;
  final VoidCallback onTap;
  final bool addClient;

  const MessageCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.onTap,
    this.addClient = false,

  });

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  bool isLoading = false;
  Map<String, dynamic> client = {};
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
      backgroundColor: [Colors.green, const Color.fromARGB(255, 224, 96, 139), const Color.fromARGB(255, 224, 139, 13), const Color.fromARGB(255, 172, 81, 188)][widget.title.hashCode % 4],
      child: Icon(Icons.person, color: Colors.white),
    ),
    title: Text(
      widget.title, 
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: const Color.fromARGB(255, 32, 32, 32)
      )
    ),
    subtitle: Text(
      widget.subtitle, 
      style: TextStyle(
        color: const Color.fromARGB(255, 71, 70, 70), 
        fontSize: 12.0
      )
    ),
    onTap: widget.onTap,
    trailing: widget.addClient ? Row(
      mainAxisSize: MainAxisSize.min,
      children: [
      Text(widget.trailing),
      SizedBox(width: 8), // Add some spacing
      ElevatedButton(
        onPressed: () async{
        setState(() => isLoading = true);
        try {
          final result = await ClientService().getClientByPhone(context, widget.title);
          setState(() {
            client = result;
            isLoading = false;
          });
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ClientDetail(client: client, phoneNumber: widget.title),
            ),
          );
        } catch (e) {
          setState(() => isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load client: $e')),
          );
        }
        },
        style: ElevatedButton.styleFrom(
        backgroundColor: kTravailFuteMainColor, // Button color
        foregroundColor: Colors.white, // Text color
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        ),
        child: isLoading? Center(
          child: CircularProgressIndicator(
          color: kTravailFuteMainColor,
          ),
        ) :Text(
        'Ajouter Client',
        style: TextStyle(fontSize: 12),
        ),
      ),
      ],
    ) : Text(widget.trailing),
    ), 
  );
  }
}
