import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:travail_fute/constants.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:travail_fute/screens/pdf_viewer_screen.dart';
import 'package:travail_fute/utils/logger.dart';
import 'package:travail_fute/utils/provider.dart';

class NewEstimateScreen extends StatefulWidget {
  final Map<String, dynamic> client;

  const NewEstimateScreen({required this.client, super.key});

  @override
  State<NewEstimateScreen> createState() => _NewEstimateScreenState();
}

class _NewEstimateScreenState extends State<NewEstimateScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final List<Map<String, dynamic>> _estimateItems = [];
  List<Map<String, dynamic>> _availableServices = [];
  final double _vatRate = 0.21; // Default 21% VAT
  final TextEditingController _hourlyRateController = TextEditingController();
  final TextEditingController _hoursWorkedController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoadingServices = true;

  double get _servicesSubTotal => _estimateItems.fold(0.0, (sum, item) {
        final service = _availableServices.firstWhere(
          (s) => s['id'] == item['service'],
          orElse: () => {'base_price': 0.0},
        );
        return sum + (service['base_price'] as double) * (item['quantity'] as int);
      });
  double get _hourlySubTotal => (_hourlyRateController.text.isNotEmpty && _hoursWorkedController.text.isNotEmpty)
      ? double.parse(_hourlyRateController.text) * double.parse(_hoursWorkedController.text)
      : 0.0;
  double get _subTotal => _servicesSubTotal + _hourlySubTotal;
  double get _vatAmount => _subTotal * _vatRate;
  double get _totalAmount => _subTotal + _vatAmount;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _fetchServices();
  }

  @override
  void dispose() {
    _controller.dispose();
    _hourlyRateController.dispose();
    _hoursWorkedController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _fetchServices() async {
    setState(() => _isLoadingServices = true);
    try {
      final token = Provider.of<TokenProvider>(context, listen: false).token;
      final response = await http.get(
        Uri.parse('$apiUrl/invoice/services/'),
        headers: {'Authorization': 'Token $token'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body)['results'];
        setState(() {
          _availableServices = data.map((service) => {
            'id': service['id'],
            'name': service['name'],
            'description': service['description'],
            'base_price': double.parse(service['base_price'].toString()),
          }).toList();
        });
      } else {
        throw Exception('Failed to load services: ${response.reasonPhrase}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading services: $e')),
      );
    } finally {
      setState(() => _isLoadingServices = false);
    }
  }

  Future<int?> _createService(String name, String description, double basePrice) async {
    try {
      final token = Provider.of<TokenProvider>(context, listen: false).token;
      final response = await http.post(
        Uri.parse('$apiUrl/invoice/services/'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'description': description,
          'base_price': basePrice,
        }),
      );
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Service created successfully')),
        );
        return data['id'];
      } else {
        throw Exception('Failed to create service: ${response.reasonPhrase}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating service: $e')),
      );
      return null;
    }
  }

  Future<void> _submitEstimate() async {
    if (_estimateItems.isEmpty || _hourlyRateController.text.isEmpty || _hoursWorkedController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez remplir tous les champs obligatoires')),
      );
      return;
    }

    final payload = {
      'client': widget.client['id'],
      'expiration_date': DateTime.now().add(Duration(days: 30)).toIso8601String().split('T')[0], // Added expiration
      'description': _descriptionController.text.isEmpty ? 'Devis pour services' : _descriptionController.text,
      'vat_rate': _vatRate * 100,
      'hourly_rate': double.parse(_hourlyRateController.text),
      'hours_worked': double.parse(_hoursWorkedController.text),
      'items': _estimateItems, // Changed key to reflect estimate
      'status': 'sent', // Optional: Add status for estimate workflow
    };
    logger.i('Estimate payload: ${jsonEncode(payload)}');

    try {
      final token = Provider.of<TokenProvider>(context, listen: false).token;
      final response = await http.post(
        Uri.parse('$apiUrl/invoice/estimates/'), // New endpoint for estimates
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );
      logger.i("the response is ${response.body}");
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Estimate created successfully')),
        );
        final responseData = jsonDecode(response.body);
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PdfViewerScreen(billOrEstimateId: responseData["id"].toString(),isEstimate: true)),
        );
        
      } else {
        throw Exception('Failed to create estimate: ${response.reasonPhrase}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating estimate: $e')),
      );
    }
  }

  void _addService() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) => const SizedBox(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.5, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          ),
          child: FadeTransition(
            opacity: animation,
            child: _AddServiceDialog(
              availableServices: _availableServices,
              onAdd: (serviceId, quantity) {
                setState(() {
                  _estimateItems.add({
                    'service': serviceId,
                    'quantity': quantity,
                  });
                });
              },
              onCreateService: _createService,
              onFetchServices: _fetchServices,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [kTravailFuteMainColor.withOpacity(0.1), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  _buildHeader(size),
                  Padding(
                    padding: EdgeInsets.all(size.width * 0.04),
                    child: Column(
                      children: [
                        _buildHourlyFields(size),
                        SizedBox(height: size.height * 0.02),
                        _buildDescriptionField(size),
                      ],
                    ),
                  ),
                  Expanded(child: _buildServiceList(size)),
                  _buildTotalArea(size),
                ],
              ),
              if (_isLoadingServices)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildFAB(size),
          SizedBox(height: size.height * 0.02),
          _buildSubmitButton(size),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildHeader(Size size) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: kTravailFuteMainColor),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: FadeTransition(
              opacity: _animation,
              child: Text(
                'Nouveau Devis pour Client #${widget.client['phone_number']}',
                style: TextStyle(fontSize: size.width * 0.05, fontWeight: FontWeight.bold, color: kTravailFuteMainColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyFields(Size size) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _hourlyRateController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
            decoration: InputDecoration(
                labelText: 'Taux Horaire',
                labelStyle: TextStyle(fontSize: 13),
                contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
              prefixIcon: Icon(Icons.euro, color: kTravailFuteMainColor),
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        SizedBox(width: size.width * 0.02),
        Expanded(
          child: TextField(
            controller: _hoursWorkedController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
            decoration: InputDecoration(
              labelText: 'Heures estimées',
              labelStyle: TextStyle(fontSize: 10),
              prefixIcon: Icon(Icons.timer, color: kTravailFuteMainColor),
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField(Size size) {
    return TextField(
      controller: _descriptionController,
      decoration: InputDecoration(
        labelText: 'Description (optionnel)',
        prefixIcon: Icon(Icons.description, color: kTravailFuteMainColor),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildServiceList(Size size) {
    return _estimateItems.isEmpty
        ? _buildEmptyState(size)
        : ListView.builder(
            itemCount: _estimateItems.length,
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
            itemBuilder: (context, index) {
              final item = _estimateItems[index];
              final service = _availableServices.firstWhere(
                (s) => s['id'] == item['service'],
                orElse: () => {'id': -1, 'name': 'Unknown Service', 'description': '', 'base_price': 0.0},
              );
              return FadeTransition(
                opacity: _animation,
                child: _buildServiceCard(size, service, item['quantity'], index),
              );
            },
          );
  }

  Widget _buildEmptyState(Size size) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: size.width * 0.15, color: Colors.grey[400]),
          SizedBox(height: size.height * 0.02),
          Text(
            'Aucun service ajouté',
            style: TextStyle(fontSize: size.width * 0.05, color: Colors.grey[600], fontWeight: FontWeight.bold),
          ),
          SizedBox(height: size.height * 0.01),
          Text(
            'Appuyez sur le bouton + pour ajouter un service',
            style: TextStyle(fontSize: size.width * 0.04, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(Size size, Map<String, dynamic> service, int quantity, int index) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: EdgeInsets.symmetric(vertical: size.height * 0.01),
      child: Padding(
        padding: EdgeInsets.all(size.width * 0.03),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service['name'],
                    style: TextStyle(fontSize: size.width * 0.045, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  SizedBox(height: size.height * 0.005),
                  Text(
                    'Qté: $quantity x €${service['base_price'].toStringAsFixed(2)}',
                    style: TextStyle(fontSize: size.width * 0.04, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => setState(() => _estimateItems.removeAt(index)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalArea(Size size) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Sous-total services:', style: TextStyle(fontSize: size.width * 0.045, color: Colors.black87)),
              Text('€${_servicesSubTotal.toStringAsFixed(2)}', style: TextStyle(fontSize: size.width * 0.045, color: Colors.black87)),
            ],
          ),
          SizedBox(height: size.height * 0.01),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Sous-total horaire:', style: TextStyle(fontSize: size.width * 0.045, color: Colors.black87)),
              Text('€${_hourlySubTotal.toStringAsFixed(2)}', style: TextStyle(fontSize: size.width * 0.045, color: Colors.black87)),
            ],
          ),
          SizedBox(height: size.height * 0.01),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Sous-total:', style: TextStyle(fontSize: size.width * 0.045, color: Colors.black87)),
              Text('€${_subTotal.toStringAsFixed(2)}', style: TextStyle(fontSize: size.width * 0.045, color: Colors.black87)),
            ],
          ),
          SizedBox(height: size.height * 0.01),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('TVA (${(_vatRate * 100).toStringAsFixed(0)}%):', style: TextStyle(fontSize: size.width * 0.045, color: Colors.black87)),
              Text('€${_vatAmount.toStringAsFixed(2)}', style: TextStyle(fontSize: size.width * 0.045, color: Colors.black87)),
            ],
          ),
          SizedBox(height: size.height * 0.01),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total:', style: TextStyle(fontSize: size.width * 0.05, fontWeight: FontWeight.bold, color: kTravailFuteMainColor)),
              Text('€${_totalAmount.toStringAsFixed(2)}', style: TextStyle(fontSize: size.width * 0.05, fontWeight: FontWeight.bold, color: Colors.black87)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFAB(Size size) {
    return FloatingActionButton(
      onPressed: _addService,
      backgroundColor: kTravailFuteMainColor,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ScaleTransition(
        scale: _animation,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _buildSubmitButton(Size size) {
    return ElevatedButton(
      onPressed: _submitEstimate,
      style: ElevatedButton.styleFrom(
        backgroundColor: kTravailFuteMainColor,
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.1, vertical: size.height * 0.015),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      child: Text(
        'Créer le devis',
        style: TextStyle(color: Colors.white, fontSize: size.width * 0.045, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _AddServiceDialog extends StatefulWidget {
  final List<Map<String, dynamic>> availableServices;
  final Function(int, int) onAdd;
  final Future<int?> Function(String, String, double) onCreateService;
  final Future<void> Function() onFetchServices;

  const _AddServiceDialog({
    required this.availableServices,
    required this.onAdd,
    required this.onCreateService,
    required this.onFetchServices,
  });

  @override
  State<_AddServiceDialog> createState() => _AddServiceDialogState();
}

class _AddServiceDialogState extends State<_AddServiceDialog> {
  final _searchController = TextEditingController();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _basePriceController = TextEditingController();
  final _quantityController = TextEditingController();
  List<Map<String, dynamic>> _filteredServices = [];
  Map<String, dynamic>? _selectedService;
  bool _createNewService = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _filteredServices = widget.availableServices;
    _searchController.addListener(_filterServices);
    _quantityController.text = '1'; // Default quantity
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterServices);
    _searchController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _basePriceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _filterServices() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredServices = widget.availableServices.where((service) {
        return service['name'].toLowerCase().contains(query) ||
            service['description'].toLowerCase().contains(query);
      }).toList();
      _createNewService = query.isNotEmpty && _filteredServices.isEmpty;
      if (_createNewService) {
        _nameController.text = query;
        _selectedService = null;
      }
    });
  }

  bool _isFormValid() {
    if (_createNewService) {
      return _nameController.text.isNotEmpty &&
          _descriptionController.text.isNotEmpty &&
          double.tryParse(_basePriceController.text)?.isFinite == true &&
          int.tryParse(_quantityController.text) != null &&
          int.parse(_quantityController.text) > 0;
    }
    return _selectedService != null &&
        int.tryParse(_quantityController.text) != null &&
        int.parse(_quantityController.text) > 0;
  }

  Future<void> _handleAddService() async {
    setState(() => _isLoading = true);
    
    try {
      if (_createNewService) {
        final newServiceId = await widget.onCreateService(
          _nameController.text,
          _descriptionController.text,
          double.parse(_basePriceController.text),
        );
        if (newServiceId != null) {
          widget.onAdd(newServiceId, int.parse(_quantityController.text));
          await widget.onFetchServices();
        }
      } else if (_selectedService != null) {
        widget.onAdd(_selectedService!['id'], int.parse(_quantityController.text));
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: size.width * 0.85,
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Ajouter un Service',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: kTravailFuteMainColor,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Search Field
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Rechercher ou créer un service...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _createNewService = false);
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
              const SizedBox(height: 16),
              // Service List or New Service Form
              if (!_createNewService && _filteredServices.isNotEmpty)
                Container(
                  constraints: BoxConstraints(maxHeight: size.height * 0.25),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _filteredServices.length,
                    itemBuilder: (context, index) {
                      final service = _filteredServices[index];
                      return Card(
                        elevation: 0,
                        color: _selectedService?['id'] == service['id']
                            ? kTravailFuteMainColor.withOpacity(0.1)
                            : null,
                        child: ListTile(
                          title: Text(service['name']),
                          subtitle: Text('€${service['base_price'].toStringAsFixed(2)}'),
                          trailing: const Icon(Icons.add_circle_outline),
                          onTap: () => setState(() => _selectedService = service),
                        ),
                      );
                    },
                  ),
                )
              else if (_createNewService) ...[
                _buildTextField(
                  controller: _nameController,
                  label: 'Nom du service',
                  icon: Icons.label,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _descriptionController,
                  label: 'Description',
                  icon: Icons.description,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _basePriceController,
                  label: 'Prix (€)',
                  icon: Icons.euro,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                ),
              ],
              const SizedBox(height: 16),
              // Quantity Field
              _buildTextField(
                controller: _quantityController,
                label: 'Quantité',
                icon: Icons.format_list_numbered,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 20),
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
                  ),
                  ElevatedButton(
                    onPressed: _isFormValid() && !_isLoading ? _handleAddService : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kTravailFuteMainColor,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Ajouter', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: kTravailFuteMainColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
    );
  }
}