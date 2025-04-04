import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travail_fute/constants.dart';
import 'package:travail_fute/utils/logger.dart';
import 'package:travail_fute/utils/provider.dart';
import 'package:http/http.dart' as http;

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  List<Map<String, dynamic>> services = [];
  List<Map<String, dynamic>> _filteredServices = [];
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;
  final int _itemsPerPage = 10;
  bool _hasMoreItems = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterServices);
    fetchServices();
  }

  Future<void> fetchServices() async {
    if (isLoading) return;

    setState(() => isLoading = true);
    try {
      final token = Provider.of<TokenProvider>(context, listen: false).token;
      List<Map<String, dynamic>> allServices = [];
      String? nextUrl = '$apiUrl/invoice/services/';

      // Fetch all pages of services
      while (nextUrl != null) {
        final response = await http.get(
          Uri.parse(nextUrl),
          headers: {'Authorization': 'Token $token'},
        );
        final data = json.decode(response.body);

        allServices.addAll(List<Map<String, dynamic>>.from(data['results'] ?? []));
        nextUrl = data['next']; // Get the next page URL
      }

      setState(() {
        services = allServices;
        _filterServices(); // Apply filtering if needed
      });
    } catch (e) {
      logger.e(e);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _filterServices() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredServices = services.where((service) {
        return service['name'].toLowerCase().contains(query) ||
            service['description'].toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> addService(Map<String, dynamic> service) async {
    if(mounted){
      setState(() => isLoading = true);
    }
    try {
      final token = Provider.of<TokenProvider>(context, listen: false).token;
      await http.post(
        Uri.parse('$apiUrl/invoice/services/'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(service),
      );
      _currentPage = 1;
      await fetchServices();
      if(mounted){
      setState(() => isLoading = false);
    }
    } catch (e) {
      logger.e(e);
    }
  }

  Future<void> deleteService(int id) async {
    setState(() => isLoading = true);
    try {
      final token = Provider.of<TokenProvider>(context, listen: false).token;
      await http.delete(
        Uri.parse('$apiUrl/invoice/services/$id/'),
        headers: {'Authorization': 'Token $token'},
      );
      _currentPage = 1;
      await fetchServices();
    } catch (e) {
      logger.e(e);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

@override
Widget build(BuildContext context) {
  final size = MediaQuery.of(context).size;

  return Scaffold(
    body: SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: size.height * 0.25, // Responsive height
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Mes Services',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      kTravailFuteMainColor,
                      kTravailFuteMainColor.withOpacity(0.7),
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.build_rounded,
                    size: 80,
                    color: Colors.white24,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(size.width * 0.05),
              child: _buildSearchBar(), // Add the search bar here
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.all(size.width * 0.05),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: isLoading && _currentPage == 1
                  ? SizedBox(
                      height: size.height * 0.5,
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(kTravailFuteMainColor),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(), // Placeholder for the SliverList
            ),
          ),
          _buildServicesList(), // Add the SliverList here
        ],
      ),
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () => _showAddServiceDialog(context),
      backgroundColor: kTravailFuteMainColor,
      child: const Icon(Icons.add, color: Colors.white),
    ),
  );
}

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Rechercher des services',
          prefixIcon: Icon(Icons.search_rounded, color: kTravailFuteMainColor),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: kTravailFuteMainColor, width: 2),
          ),
        ),
      ),
    );
  }

Widget _buildServicesList() {
  if (_filteredServices.isEmpty && _searchController.text.isNotEmpty) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 200,
        child: const Center(
          child: Text(
            'Aucun service trouvé',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      ),
    );
  }
  if (_filteredServices.isEmpty && _searchController.text.isEmpty) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 200,
        child: const Center(
          child: Text(
            'Aucun service disponible',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  return SliverList(
    delegate: SliverChildBuilderDelegate(
      (context, index) {
        final service = _filteredServices[index];
        return GestureDetector(
          onTap: () => () {}, // Add the service details screen here
          child: Card(
            elevation: 4,
            shadowColor: Colors.grey.withOpacity(0.2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Text(
                service['name'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    service['description'],
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Prix: ${service['base_price']} €',
                    style: TextStyle(
                      color: kTravailFuteMainColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_rounded, color: Colors.redAccent),
                onPressed: () => deleteService(service['id']),
              ),
            ),
          ),
        );
      },
      childCount: _filteredServices.length,
    ),
  );
}


  void _showAddServiceDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Ajouter un service',
          style: TextStyle(fontWeight: FontWeight.bold, color: kTravailFuteMainColor),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSettingField(
                label: 'Nom',
                icon: Icons.label_rounded,
                controller: nameController,
                hintText: 'Nom du service',
              ),
              SizedBox(height: 16),
              _buildSettingField(
                label: 'Description',
                icon: Icons.description_rounded,
                controller: descController,
                hintText: 'Description du service',
                maxLines: 2,
              ),
              SizedBox(height: 16),
              _buildSettingField(
                label: 'Prix de base',
                icon: Icons.attach_money_rounded,
                controller: priceController,
                hintText: 'Prix de base',
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  descController.text.isNotEmpty &&
                  priceController.text.isNotEmpty) {
                addService({
                  'name': nameController.text,
                  'description': descController.text,
                  'base_price': double.tryParse(priceController.text) ?? 0.0,
                });
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tous les champs sont requis')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kTravailFuteMainColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Ajouter', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: kTravailFuteMainColor, size: 22),
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: kTravailFuteMainColor, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}