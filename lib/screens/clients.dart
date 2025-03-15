import 'dart:async';
import 'package:flutter/material.dart';
import 'package:travail_fute/utils/logger.dart';
import 'package:provider/provider.dart';
import 'package:travail_fute/constants.dart';
import 'package:travail_fute/screens/client_create.dart';
import 'package:travail_fute/utils/provider.dart';
import 'package:travail_fute/widgets/client_card.dart';
import 'package:travail_fute/services/clients_service.dart';

class ClientsList extends StatefulWidget {
  const ClientsList({super.key});

  @override
  State<ClientsList> createState() => _ClientsListState();
}

class _ClientsListState extends State<ClientsList> with SingleTickerProviderStateMixin {
  List<dynamic> clientList = [];
  List<dynamic> filteredClientList = [];
  final ScrollController _scrollController = ScrollController();
  bool isLoading = false;
  String? errorMessage;
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _controller;
  late Animation<double> _animation;
  Timer? _debounce;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    callClient();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void callClient() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    var client = ClientService();
    try {
      final token = Provider.of<TokenProvider>(context, listen: false).token;
      var responseData = await client.getClientList(context, token: token); // Pass token explicitly

      setState(() {
        // Extract the data array from the response map
        clientList = responseData; // Reset on initial load
        filteredClientList = List.from(clientList);
      });
      logger.d('Client List: $clientList');
    } catch (e) {
      logger.d('Error in callClient: $e');
      setState(() => errorMessage = 'Failed to load data: $e');
      _showErrorDialog();
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _filterClients();
    });
  }

  void _filterClients() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _isSearching = query.isNotEmpty;
      if (query.isEmpty) {
        filteredClientList = List.from(clientList);
      } else {
        filteredClientList = clientList.where((client) {
          final normalizedQuery = query.startsWith('0') ? query.substring(1) : query;
          final lastName = (client['last_name']?.toString() ?? '').toLowerCase();
          final address = (client['address_street']?.toString() ?? '').toLowerCase();
          final postalCode = (client['postal_code']?.toString() ?? '').toLowerCase();
          final rawPhoneNumber = (client['phone_number']?.toString() ?? '').toLowerCase();
          final phoneNumber = rawPhoneNumber.replaceAll(RegExp(r'^\+32|\D'), '');
          final firstName = (client['first_name']?.toString() ?? '').toLowerCase();
          return address.contains(query) || lastName.contains(query) || postalCode.contains(query) || phoneNumber.contains(normalizedQuery) || firstName.contains(query);
        }).toList();
      }
      logger.d('Filtered clients: ${filteredClientList.length} results');
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
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Rechercher...',
          hintStyle: TextStyle(color: Colors.grey[400]),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: width * 0.04, horizontal: width * 0.03),
          prefixIcon: Icon(Icons.search, color: kTravailFuteMainColor),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey[600]),
                  onPressed: () {
                    _searchController.clear();
                    _filterClients();
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildClientList(Size size, double width) {
    return filteredClientList.isEmpty && !isLoading
        ? _buildEmptyState(size, width)
        : ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.all(width * 0.03),
            itemCount: filteredClientList.length,
            itemBuilder: (context, index) {
              return FadeTransition(
                opacity: _animation,
                child: ClientCard(client: filteredClientList[index]),
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
              _isSearching ? 'Aucun résultat trouvé' : 'Aucun client trouvé',
              style: TextStyle(
                fontSize: width * 0.05,
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: size.height * 0.01),
            Text(
              _isSearching
                  ? 'Essayez une autre recherche'
                  : 'Ajoutez un nouveau client ou affinez votre recherche',
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
      onPressed: () {
        Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ClientCreatePage(),
        ),
      );},
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