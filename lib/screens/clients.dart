import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:travail_fute/constants.dart';
import 'package:travail_fute/screens/client_create.dart';
import 'package:travail_fute/widgets/client_card.dart';
import 'package:travail_fute/services/clients_service.dart';
import 'package:travail_fute/widgets/loading.dart';

class ClientsList extends StatefulWidget {
  final String deviceToken;

  const ClientsList({super.key, required this.deviceToken});

  @override
  State<ClientsList> createState() => _ClientsListState();
}

class _ClientsListState extends State<ClientsList> with SingleTickerProviderStateMixin {
  final logger = Logger();
  List<dynamic> clientList = [];
  List<dynamic> filteredClientList = [];
  String? nextUrl;
  String? previousUrl;
  final ScrollController _scrollController = ScrollController();
  bool isLoading = false;
  String? errorMessage;
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _controller;
  late Animation<double> _animation;
  String _selectedFilter = 'last_name'; // Default filter

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    callClient();
    _scrollController.addListener(_scrollListener);
    _searchController.addListener(_filterClients);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && nextUrl != null) {
      callClient(url: nextUrl);
    } else if (_scrollController.position.pixels == _scrollController.position.minScrollExtent && previousUrl != null) {
      callClient(url: previousUrl);
    }
  }

  void callClient({String? url}) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    final client = ClientService();
    try {
      print("Making request to URL: ${url ?? 'default API URL'} with token: ${widget.deviceToken}");
      final responseData = await client.getClientList(context, url: url);
      print("Response Data: $responseData");
      setState(() {
        if (url == null) {
          clientList = responseData['results'];
        } else {
          clientList.addAll(responseData['results']);
        }
        filteredClientList = List.from(clientList);
        nextUrl = responseData['next'];
        previousUrl = responseData['previous'];
        print('Next URL: $nextUrl, Previous URL: $previousUrl');
      });
      logger.d('Client List: $clientList');
    } catch (e) {
      logger.d('Error: $e');
      setState(() => errorMessage = 'Failed to load data. Please try again.');
      _showErrorDialog();
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _filterClients() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredClientList = clientList.where((client) {
        final fieldValue = (client[_selectedFilter]?.toString() ?? '').toLowerCase();
        return fieldValue.contains(query);
      }).toList();
    });
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        backgroundColor: Colors.white,
        elevation: 8,
        title: Text('Erreur', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        content: Text(errorMessage ?? 'An unknown error occurred.', style: TextStyle(color: Colors.black87)),
        actions: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: kTravailFuteSecondaryColor,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: kTravailFuteSecondaryColor.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text('OK', style: TextStyle(color: kWhiteColor, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
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
            colors: [kTravailFuteMainColor.withOpacity(0.15), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  _buildHeader(size, width),
                  Expanded(child: _buildClientList(size, width)),
                ],
              ),
              if (isLoading) _buildLoadingOverlay(),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFAB(width),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(width * 0.02),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kTravailFuteMainColor.withOpacity(0.1),
              ),
              child: Icon(Icons.arrow_back, color: kTravailFuteMainColor, size: width * 0.06),
            ),
          ),
          SizedBox(width: width * 0.03),
          Expanded(
            child: FadeTransition(
              opacity: _animation,
              child: _buildSearchBar(size, width),
            ),
          ),
          SizedBox(width: width * 0.03),
          // GestureDetector(
          //   onTap: () => Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //       builder: (_) => ClientCreatePage(deviceToken: widget.deviceToken),
          //     ),
          //   ),
          //   child: Container(
          //     padding: EdgeInsets.all(width * 0.025),
          //     decoration: BoxDecoration(
          //       gradient: LinearGradient(
          //         colors: [kTravailFuteMainColor, kTravailFuteSecondaryColor],
          //       ),
          //       shape: BoxShape.circle,
          //       boxShadow: [
          //         BoxShadow(
          //           color: kTravailFuteMainColor.withOpacity(0.4),
          //           blurRadius: 8,
          //           offset: const Offset(0, 4),
          //         ),
          //       ],
          //     ),
          //     child: Icon(Icons.add, color: Colors.white, size: width * 0.07),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(Size size, double width) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: width * 0.02),
            decoration: BoxDecoration(
              color: kTravailFuteMainColor.withOpacity(0.1),
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(15)),
            ),
            child: DropdownButton<String>(
              value: _selectedFilter,
              icon: Icon(Icons.filter_list, color: kTravailFuteMainColor, size: width * 0.05),
              underline: const SizedBox(),
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value!;
                  _filterClients();
                });
              },
              items: [
                DropdownMenuItem(value: 'last_name', child: Text('Name', style: TextStyle(fontSize: width * 0.04, color: kTravailFuteMainColor))),
                DropdownMenuItem(value: 'postal_code', child: Text('Postal Code', style: TextStyle(fontSize: width * 0.04, color: kTravailFuteMainColor))),
                DropdownMenuItem(value: 'address_town', child: Text('Town', style: TextStyle(fontSize: width * 0.04, color: kTravailFuteMainColor))),
                DropdownMenuItem(value: 'phone_number', child: Text('Phone', style: TextStyle(fontSize: width * 0.04, color: kTravailFuteMainColor))),
                DropdownMenuItem(value: 'address_street', child: Text('Street', style: TextStyle(fontSize: width * 0.04, color: kTravailFuteMainColor))),
              ],
            ),
          ),
          Expanded(
            child: TextField(
              controller: _searchController,
              onSubmitted: (_) => _filterClients(),
              decoration: InputDecoration(
                hintText: 'Search by ${_selectedFilter.replaceAll('_', ' ')}...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: width * 0.04, horizontal: width * 0.03),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientList(Size size, double width) {
    return filteredClientList.isEmpty && !isLoading
        ? _buildEmptyState(size, width)
        : ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.all(width * 0.04),
            itemCount: filteredClientList.length + (nextUrl != null ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == filteredClientList.length && nextUrl != null) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: width * 0.02),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(kTravailFuteMainColor),
                    ),
                  ),
                );
              }
              return FadeTransition(
                opacity: _animation,
                child: Padding(
                  padding: EdgeInsets.only(bottom: size.height * 0.015),
                  child: ClientCard(client: filteredClientList[index]),
                ),
              );
            },
          );
  }

  Widget _buildEmptyState(Size size, double width) {
    return Center(
      child: ScaleTransition(
        scale: _animation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: width * 0.15,
              color: Colors.grey[400],
            ),
            SizedBox(height: size.height * 0.02),
            Text(
              'No Clients Found',
              style: TextStyle(
                fontSize: width * 0.05,
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: size.height * 0.01),
            Text(
              'Add a new client or refine your search',
              style: TextStyle(
                fontSize: width * 0.04,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(kTravailFuteMainColor),
          ),
        ),
      ),
    );
  }

  Widget _buildFAB(double width) {
    return FloatingActionButton(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ClientCreatePage(deviceToken: widget.deviceToken),
        ),
      ),
      backgroundColor: kTravailFuteMainColor,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ScaleTransition(
        scale: _animation,
        child: const Icon(Icons.add, size: 30, color: Colors.white),
      ),
    );
  }
}