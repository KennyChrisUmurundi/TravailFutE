import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:travail_fute/constants.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:travail_fute/screens/pdf_viewer_screen.dart';
import 'package:travail_fute/utils/provider.dart';
import 'package:travail_fute/utils/logger.dart';

class NewInvoiceScreen extends StatefulWidget {
  final Map<String, dynamic> client;

  const NewInvoiceScreen({required this.client, super.key});

  @override
  State<NewInvoiceScreen> createState() => _NewInvoiceScreenState();
}

class _NewInvoiceScreenState extends State<NewInvoiceScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final List<Map<String, dynamic>> _billItems = [];
  List<Map<String, dynamic>> _availableServices = [];
  final double _vatRate = 0.21; // Default 21% VAT
  final TextEditingController _hourlyRateController = TextEditingController();
  final TextEditingController _hoursWorkedController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoadingServices = true;

  double get _servicesSubTotal => _billItems.fold(0.0, (sum, item) {
        final service = _availableServices.firstWhere((s) => s['id'] == item['service']);
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
        return data['id']; // Return the new service ID
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

  Future<void> _submitInvoice() async {
    if (_billItems.isEmpty || _hourlyRateController.text.isEmpty || _hoursWorkedController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    final payload = {
      'client': widget.client['id'],
      'due_date': DateTime.now().add(Duration(days: 30)).toIso8601String().split('T')[0],
      'description': _descriptionController.text.isEmpty ? 'Services rendered' : _descriptionController.text,
      'vat_rate': _vatRate * 100,
      'hourly_rate': double.parse(_hourlyRateController.text),
      'hours_worked': double.parse(_hoursWorkedController.text),
      'bill_items': _billItems,
    };

    try {
      final token = Provider.of<TokenProvider>(context, listen: false).token;
      final response = await http.post(
        Uri.parse('$apiUrl/bill/manage/'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );
      logger.i("response is ${response.body}");
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invoice created successfully')),
        );
        final responseData = jsonDecode(response.body);
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PdfViewerScreen(billOrEstimateId: responseData["id"].toString(),isEstimate: false)),
        );
      } else {
        throw Exception('Failed to create invoice: ${response.reasonPhrase}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating invoice: $e')),
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
                  _billItems.add({
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
                'Nouvelle Facture pour Client #${widget.client['phone_number']}',
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
              labelText: 'Taux horaire (€)',
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
              labelText: 'Heures travaillées',
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
    return _billItems.isEmpty
        ? _buildEmptyState(size)
        : ListView.builder(
            padding: EdgeInsets.all(size.width * 0.04),
            itemCount: _billItems.length,
            itemBuilder: (context, index) {
              final item = _billItems[index];
              final service = _availableServices.firstWhere((s) => s['id'] == item['service']);
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
              onPressed: () => setState(() => _billItems.removeAt(index)),
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
      onPressed: _submitInvoice,
      style: ElevatedButton.styleFrom(
        backgroundColor: kTravailFuteMainColor,
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.1, vertical: size.height * 0.015),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      child: Text(
        'Créer la facture',
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

class _AddServiceDialogState extends State<_AddServiceDialog> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _basePriceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  List<Map<String, dynamic>> _filteredServices = [];
  Map<String, dynamic>? _selectedService;
  bool _isNameValid = false;
  bool _isDescriptionValid = false;
  bool _isBasePriceValid = false;
  bool _isQuantityValid = false;
  bool _createNewService = false;
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isSpeechInitialized = false;

  bool get _isFormValid => (_selectedService != null && _isQuantityValid && !_createNewService) ||
      (_isNameValid && _isDescriptionValid && _isBasePriceValid && _isQuantityValid);

  @override
  void initState() {
    super.initState();
    _filteredServices = widget.availableServices;
    _initSpeech();
    _searchController.addListener(_filterServices);
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

  Future<void> _initSpeech() async {
    if (await Permission.microphone.request().isGranted) {
      _isSpeechInitialized = await _speech.initialize();
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission denied')),
      );
    }
  }

  void _filterServices() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredServices = widget.availableServices.where((service) {
        return service['name'].toLowerCase().contains(query) ||
            service['description'].toLowerCase().contains(query);
      }).toList();
      _selectedService = null;
      _createNewService = query.isNotEmpty && _filteredServices.isEmpty;
      if (_createNewService) {
        _nameController.text = _searchController.text;
        _descriptionController.clear();
        _basePriceController.clear();
        _validateName(_searchController.text);
      }
    });
  }

  void _validateName(String? value) {
    setState(() => _isNameValid = value?.isNotEmpty ?? false);
  }

  void _validateDescription(String? value) {
    setState(() => _isDescriptionValid = value?.isNotEmpty ?? false);
  }

  void _validateBasePrice(String? value) {
    setState(() => _isBasePriceValid = value != null && double.tryParse(value) != null && double.parse(value) > 0);
  }

  void _validateQuantity(String? value) {
    setState(() => _isQuantityValid = value != null && int.tryParse(value) != null && int.parse(value) > 0);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: size.width * 0.8,
        padding: EdgeInsets.all(size.width * 0.05),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ajouter un service',
                style: TextStyle(fontSize: size.width * 0.05, fontWeight: FontWeight.bold, color: kTravailFuteMainColor),
              ),
              SizedBox(height: size.height * 0.03),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Rechercher un service',
                  prefixIcon: Icon(Icons.search, color: kTravailFuteMainColor),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kTravailFuteMainColor, width: 2)),
                ),
              ),
              SizedBox(height: size.height * 0.02),
              if (!_createNewService && _filteredServices.isNotEmpty)
                Container(
                  constraints: BoxConstraints(maxHeight: size.height * 0.2),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _filteredServices.length,
                    itemBuilder: (context, index) {
                      final service = _filteredServices[index];
                      return ListTile(
                        title: Text(service['name']),
                        subtitle: Text('€${service['base_price'].toStringAsFixed(2)}'),
                        onTap: () {
                          setState(() {
                            _selectedService = service;
                            _searchController.text = service['name'];
                            _nameController.text = service['name'];
                            _descriptionController.text = service['description'];
                            _basePriceController.text = service['base_price'].toString();
                            _isNameValid = true;
                            _isDescriptionValid = true;
                            _isBasePriceValid = true;
                          });
                        },
                        selected: _selectedService != null && _selectedService!['id'] == service['id'],
                        selectedTileColor: kTravailFuteMainColor.withOpacity(0.1),
                      );
                    },
                  ),
                ),
              if (_createNewService) ...[
                SizedBox(height: size.height * 0.02),
                TextField(
                  controller: _nameController,
                  onChanged: _validateName,
                  decoration: InputDecoration(
                    labelText: 'Nom',
                    prefixIcon: Icon(Icons.label, color: kTravailFuteMainColor),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kTravailFuteMainColor, width: 2)),
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                TextField(
                  controller: _descriptionController,
                  onChanged: _validateDescription,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    prefixIcon: Icon(Icons.description, color: kTravailFuteMainColor),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kTravailFuteMainColor, width: 2)),
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                TextField(
                  controller: _basePriceController,
                  onChanged: _validateBasePrice,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                  decoration: InputDecoration(
                    labelText: 'Prix de base (€)',
                    prefixIcon: Icon(Icons.euro, color: kTravailFuteMainColor),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kTravailFuteMainColor, width: 2)),
                  ),
                ),
              ],
              SizedBox(height: size.height * 0.02),
              TextField(
                controller: _quantityController,
                onChanged: _validateQuantity,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'Quantité',
                  prefixIcon: Icon(Icons.format_list_numbered, color: kTravailFuteMainColor),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kTravailFuteMainColor, width: 2)),
                ),
              ),
              SizedBox(height: size.height * 0.03),
              GestureDetector(
                onTap: _isFormValid
                    ? () async {
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
                        Navigator.pop(context);
                      }
                    : null,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: size.height * 0.015, horizontal: size.width * 0.05),
                  decoration: BoxDecoration(
                    color: _isFormValid ? kTravailFuteMainColor : Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, 4))],
                  ),
                  child: Text(
                    'Ajouter',
                    style: TextStyle(color: Colors.white, fontSize: size.width * 0.045, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}