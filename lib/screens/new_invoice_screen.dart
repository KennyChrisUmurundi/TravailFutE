import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:travail_fute/constants.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class NewInvoiceScreen extends StatefulWidget {
  const NewInvoiceScreen({super.key});

  @override
  State<NewInvoiceScreen> createState() => _NewInvoiceScreenState();
}

class _NewInvoiceScreenState extends State<NewInvoiceScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final List<Map<String, dynamic>> _services = [];
  List<String> _clients = [];
  String? _selectedClient;
  double _tvaRate = 0.20; // Default 20% TVA
  bool _isLoadingClients = true;

  double get _subTotal => _services.fold(0.0, (sum, service) => sum + (service['price'] as double));
  double get _tvaAmount => _subTotal * _tvaRate;
  double get _totalAmount => _subTotal + _tvaAmount;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _fetchClients();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchClients() async {
    setState(() => _isLoadingClients = true);
    try {
      await Future.delayed(const Duration(seconds: 1));
      final mockClients = ['John Doe', 'Jane Smith', 'Alice Johnson', 'Bob Brown'];
      setState(() {
        _clients = mockClients;
        _selectedClient = _clients.isNotEmpty ? _clients[0] : null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading clients: $e')),
      );
    } finally {
      setState(() => _isLoadingClients = false);
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
              onAdd: (description, price) {
                setState(() {
                  _services.add({
                    'description': description,
                    'price': price,
                  });
                });
              },
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
                    child: _buildClientDropdown(size),
                  ),
                  Expanded(child: _buildServiceList(size)),
                  _buildTotalArea(size),
                ],
              ),
              if (_isLoadingClients)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFAB(size),
    );
  }

  Widget _buildHeader(Size size) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
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
                'New Invoice',
                style: TextStyle(
                  fontSize: size.width * 0.05,
                  fontWeight: FontWeight.bold,
                  color: kTravailFuteMainColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientDropdown(Size size) {
    return DropdownButtonFormField<String>(
      value: _selectedClient,
      onChanged: (value) => setState(() => _selectedClient = value),
      items: _clients.map((client) {
        return DropdownMenuItem<String>(
          value: client,
          child: Text(client),
        );
      }).toList(),
      decoration: InputDecoration(
        labelText: 'Select Client',
        labelStyle: TextStyle(color: Colors.grey[600]),
        prefixIcon: Icon(Icons.person, color: kTravailFuteMainColor),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kTravailFuteMainColor, width: 2),
        ),
      ),
    );
  }

  Widget _buildServiceList(Size size) {
    return _services.isEmpty
        ? _buildEmptyState(size)
        : ListView.builder(
            padding: EdgeInsets.all(size.width * 0.04),
            itemCount: _services.length,
            itemBuilder: (context, index) {
              final service = _services[index];
              return FadeTransition(
                opacity: _animation,
                child: _buildServiceCard(size, service, index),
              );
            },
          );
  }

  Widget _buildEmptyState(Size size) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: size.width * 0.15,
            color: Colors.grey[400],
          ),
          SizedBox(height: size.height * 0.02),
          Text(
            'No Services Added',
            style: TextStyle(
              fontSize: size.width * 0.05,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: size.height * 0.01),
          Text(
            'Tap the + button to add a service',
            style: TextStyle(
              fontSize: size.width * 0.04,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(Size size, Map<String, dynamic> service, int index) {
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
                    service['description'],
                    style: TextStyle(
                      fontSize: size.width * 0.045,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: size.height * 0.005),
                  Text(
                    '\$${service['price'].toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: size.width * 0.04,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => setState(() => _services.removeAt(index)),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal:',
                style: TextStyle(
                  fontSize: size.width * 0.045,
                  color: Colors.black87,
                ),
              ),
              Text(
                '\$${_subTotal.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: size.width * 0.045,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.01),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TVA (${(_tvaRate * 100).toStringAsFixed(0)}%):',
                style: TextStyle(
                  fontSize: size.width * 0.045,
                  color: Colors.black87,
                ),
              ),
              Text(
                '\$${_tvaAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: size.width * 0.045,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.01),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total:',
                style: TextStyle(
                  fontSize: size.width * 0.05,
                  fontWeight: FontWeight.bold,
                  color: kTravailFuteMainColor,
                ),
              ),
              Text(
                '\$${_totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: size.width * 0.05,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
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
}

class _AddServiceDialog extends StatefulWidget {
  final Function(String, double) onAdd;

  const _AddServiceDialog({required this.onAdd});

  @override
  State<_AddServiceDialog> createState() => _AddServiceDialogState();
}

class _AddServiceDialogState extends State<_AddServiceDialog> with SingleTickerProviderStateMixin {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  bool _isDescriptionValid = false;
  bool _isPriceValid = false;
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isSpeechInitialized = false;

  bool get _isFormValid => _isDescriptionValid && _isPriceValid;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _priceController.dispose();
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

  void _validateDescription(String? value) {
    setState(() => _isDescriptionValid = value?.isNotEmpty ?? false);
  }

  void _validatePrice(String? value) {
    setState(() => _isPriceValid = value != null && double.tryParse(value) != null && double.parse(value) > 0);
  }

  void _recordVoice() {
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
            child: _VoiceRecordDialog(
              onRecordComplete: (text) {
                setState(() {
                  _descriptionController.text = text;
                  _validateDescription(text);
                });
              },
            ),
          ),
        );
      },
    );
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
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Add Service',
              style: TextStyle(
                fontSize: size.width * 0.05,
                fontWeight: FontWeight.bold,
                color: kTravailFuteMainColor,
              ),
            ),
            SizedBox(height: size.height * 0.03),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _descriptionController,
                    onChanged: _validateDescription,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      labelStyle: TextStyle(color: Colors.grey[600]),
                      prefixIcon: Icon(Icons.description, color: kTravailFuteMainColor),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: kTravailFuteMainColor, width: 2),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: size.width * 0.02),
                GestureDetector(
                  onTap: _isSpeechInitialized ? _recordVoice : null,
                  child: Container(
                    padding: EdgeInsets.all(size.width * 0.02),
                    decoration: BoxDecoration(
                      color: _isSpeechInitialized ? kTravailFuteSecondaryColor : Colors.grey,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(Icons.mic, color: Colors.white, size: size.width * 0.06),
                  ),
                ),
              ],
            ),
            SizedBox(height: size.height * 0.02),
            TextField(
              controller: _priceController,
              onChanged: _validatePrice,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              decoration: InputDecoration(
                labelText: 'Price',
                labelStyle: TextStyle(color: Colors.grey[600]),
                prefixIcon: Icon(Icons.attach_money, color: kTravailFuteMainColor),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: kTravailFuteMainColor, width: 2),
                ),
              ),
            ),
            SizedBox(height: size.height * 0.03),
            GestureDetector(
              onTap: _isFormValid
                  ? () {
                      widget.onAdd(
                        _descriptionController.text,
                        double.parse(_priceController.text),
                      );
                      Navigator.pop(context);
                    }
                  : null,
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: size.height * 0.015,
                  horizontal: size.width * 0.05,
                ),
                decoration: BoxDecoration(
                  color: _isFormValid ? kTravailFuteMainColor : Colors.grey,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  'Add',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size.width * 0.045,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VoiceRecordDialog extends StatefulWidget {
  final Function(String) onRecordComplete;

  const _VoiceRecordDialog({required this.onRecordComplete});

  @override
  State<_VoiceRecordDialog> createState() => _VoiceRecordDialogState();
}

class _VoiceRecordDialogState extends State<_VoiceRecordDialog> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isRecording = false;
  final stt.SpeechToText _speech = stt.SpeechToText();
  String _recognizedText = '';

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
    });

    if (_isRecording) {
      _speech.listen(
        onResult: (result) {
          setState(() => _recognizedText = result.recognizedWords);
        },
      );
    } else {
      _speech.stop();
      if (_recognizedText.isNotEmpty) {
        widget.onRecordComplete(_recognizedText);
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: size.width * 0.7,
        padding: EdgeInsets.all(size.width * 0.05),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _isRecording ? 'Listening...' : 'Speak Now',
              style: TextStyle(
                fontSize: size.width * 0.05,
                fontWeight: FontWeight.bold,
                color: kTravailFuteMainColor,
              ),
            ),
            SizedBox(height: size.height * 0.03),
            GestureDetector(
              onTap: _toggleRecording,
              child: ScaleTransition(
                scale: _isRecording ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
                child: Container(
                  padding: EdgeInsets.all(size.width * 0.05),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: kTravailFuteSecondaryColor,
                    boxShadow: [
                      BoxShadow(
                        color: kTravailFuteSecondaryColor.withOpacity(0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    _isRecording ? Icons.stop : Icons.mic,
                    color: Colors.white,
                    size: size.width * 0.1,
                  ),
                ),
              ),
            ),
            SizedBox(height: size.height * 0.03),
            if (_isRecording)
              Text(
                'Tap to stop',
                style: TextStyle(
                  fontSize: size.width * 0.04,
                  color: Colors.grey[600],
                ),
              ),
            if (_recognizedText.isNotEmpty && !_isRecording)
              Padding(
                padding: EdgeInsets.only(top: size.height * 0.02),
                child: Text(
                  'Recognized: $_recognizedText',
                  style: TextStyle(
                    fontSize: size.width * 0.04,
                    color: Colors.black87,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}