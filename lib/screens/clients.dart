import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:logger/logger.dart';
import 'package:travail_fute/constants.dart';
import 'package:travail_fute/widgets/botom_nav.dart';
import 'package:travail_fute/widgets/client_card.dart';
import 'package:travail_fute/services/clients_service.dart';
import 'package:travail_fute/widgets/foab.dart';
import 'package:travail_fute/widgets/search_bar.dart';

class ClientsList extends StatefulWidget {
  const ClientsList({super.key});

  @override
  State<ClientsList> createState() => _ClientsListState();
}

class _ClientsListState extends State<ClientsList> {
  final logger = Logger();
  var clientList = [];
  @override
  void initState() {
    //getting the client list
    callClient();
    super.initState();
  }

  void callClient() async {
    final client =
        ClientService("https://44bd-85-27-15-158.ngrok-free.app/api/clients/");
    try {
      clientList = await client.getClientList();
      setState(() {
        clientList = clientList;
      });

      logger.d('Client List: $clientList');
    } catch (e) {
      logger.d('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: SearchEngine(),
      ),
      backgroundColor: kBackgroundColor,
      body: Column(
        children: [
          // const SearchBar(),
          Expanded(
            child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: clientList.length,
                itemBuilder: (BuildContext context, int index) {
                  return ClientCard(client: clientList[index]);
                }),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(),
      floatingActionButton: const MyCenteredFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
