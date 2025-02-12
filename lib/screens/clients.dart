import 'package:flutter/material.dart';
// Add this import
// import 'package:http/http.dart';
import 'package:logger/logger.dart';
import 'package:travail_fute/constants.dart';
import 'package:travail_fute/screens/client_create.dart';
import 'package:travail_fute/widgets/botom_nav.dart';
import 'package:travail_fute/widgets/client_card.dart';
import 'package:travail_fute/services/clients_service.dart';
import 'package:travail_fute/widgets/foab.dart';
import 'package:travail_fute/widgets/loading.dart';
import 'package:travail_fute/widgets/search_bar.dart';

class ClientsList extends StatefulWidget {
  final String deviceToken; // Add device token parameter

  const ClientsList({super.key, required this.deviceToken}); // Update constructor

  @override
  State<ClientsList> createState() => _ClientsListState();
}

class _ClientsListState extends State<ClientsList> {
  final logger = Logger();
  List<dynamic> clientList = [];
  List<dynamic> filteredClientList = [];
  String? nextUrl;
  String? previousUrl;
  final ScrollController _scrollController = ScrollController();
  bool isLoading = false; // Add loading state
  String? errorMessage; // Add error message state
  final TextEditingController _searchController = TextEditingController(); // Add search controller

  @override
  void initState() {
    //getting the client list
    callClient();
    _scrollController.addListener(_scrollListener);
    _searchController.addListener(_filterClients); // Add listener to search controller
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose(); // Dispose search controller
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (nextUrl != null) {
        callClient(url: nextUrl);
      }
    } else if (_scrollController.position.pixels == _scrollController.position.minScrollExtent) {
      if (previousUrl != null) {
        callClient(url: previousUrl);
      }
    }
  }

  void callClient({String? url}) async {
    setState(() {
      isLoading = true; // Set loading to true
      errorMessage = null; // Reset error message
    });
    final client = ClientService();
    try {
      print("Making request to URL: ${url ?? 'default API URL'} with token: ${widget.deviceToken}");
      final responseData = await client.getClientList( context,url: url);
      print("Response Data: $responseData"); // Debug print
      setState(() {
        if (url == null) {
          clientList = responseData['results'];
        } else {
          clientList.addAll(responseData['results']);
        }
        filteredClientList = clientList; // Initialize filtered list
        nextUrl = responseData['next'];
        previousUrl = responseData['previous'];
        print('Next URL: $nextUrl, Previous URL: $previousUrl');
      });

      logger.d('Client List: $clientList');
    } catch (e) {
      logger.d('Error: $e');
      setState(() {
        errorMessage = 'Failed to load data. Please try again.'; // Set error message
      });
      _showErrorDialog(); // Show error dialog
    } finally {
      setState(() {
        isLoading = false; // Set loading to false
      });
    }
  }

  void _filterClients() {
    final query = _searchController.text;
    setState(() {
      filteredClientList = clientList.where((client) {
        final name = client['last_name'];
        return name.contains(query);
      }).toList();
    });
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Erreur'),
          content: Text(errorMessage ?? 'An unknown error occurred.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // LOCAL VARIABLES 
    var size = MediaQuery.of(context).size;
    var width = size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: SearchEngine(
          controller: _searchController,
          onSubmitted: (value) {
            _filterClients();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ClientCreatePage(deviceToken: widget.deviceToken),
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: kBackgroundColor,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.all(width * 0.025),
                    itemCount: filteredClientList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ClientCard(client: filteredClientList[index]);
                    }),
              ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     if (previousUrl != null)
              //       TextButton(
              //         onPressed: () => callClient(url: previousUrl),
              //         child: Text('Previous'),
              //       ),
              //     if (nextUrl != null)
              //       TextButton(
              //         onPressed: () => callClient(url: nextUrl),
              //         child: Text('Next'),
              //       ),
              //   ],
              // ),
            ],
          ),
          if (isLoading) const Loading(), // Add loading widget
        ],
      ),
      bottomNavigationBar: const BottomNavBar(),
      floatingActionButton: const RecordFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

// Add Loading widget

