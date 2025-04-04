import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:travail_fute/constants.dart';
import 'package:travail_fute/screens/speech_service.dart';
import 'package:travail_fute/services/credential_service.dart';
import 'package:travail_fute/services/notification_service.dart' as noti;
// import 'package:travail_fute/services/speech_service.dart';
import 'package:travail_fute/utils/provider.dart';
import 'package:travail_fute/utils/logger.dart';

class Assistant extends StatefulWidget {
  const Assistant({super.key});

  @override
  State<Assistant> createState() => _AssistantState();
}

class _AssistantState extends State<Assistant> with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isLoading = false;
  final SpeechService _speechService = SpeechService();
  bool _isSpeechAvailable = false;

  // API Endpoints
  final Map<String, String> _apiEndpoints = {
    'estimates': '$apiUrl/invoice/estimates/',
    'clients': '$apiUrl/clients/',
    'services': '$apiUrl/invoice/services/',
    'bills': '$apiUrl/bills/',
    'notifications': '$apiUrl/notification/notifications/',
    'projects': '$apiUrl/project/projects/',
  };

  // Cached Data
  List<Map<String, dynamic>> _availableClients = [];
  List<Map<String, dynamic>> _availableServices = [];
  List<Map<String, dynamic>> _availableNotifications = [];

  // State for creation flow
  Map<String, dynamic>? _creationData;
  String? _creationStep;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _messages.add({
      'text': "Bonjour ! Comment puis-je vous aider aujourd'hui ? Posez-moi une question ou demandez-moi de créer quelque chose !",
      'isUser': false,
      'timestamp': DateTime.now(),
    });
    _initializeSpeech();
    _fetchInitialData();
  }

  Future<void> _initializeSpeech() async {
    _isSpeechAvailable = await _speechService.initialize();
    if (!_isSpeechAvailable && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Voice commands not available')),
      );
    }
  }

  Future<void> _fetchInitialData() async {
    await _fetchClients();
    await _fetchServices();
    await fetchNotifications();
  }

  @override
  void dispose() {
    _controller.dispose();
    _messageController.dispose();
    _speechService.stop();
    super.dispose();
  }

  Future<void> _fetchClients() async {
    try {
      final token = Provider.of<TokenProvider>(context, listen: false).token;
      final response = await http.get(
        Uri.parse(_apiEndpoints['clients']!),
        headers: {'Authorization': 'Token $token'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body)['results'];
        if (mounted) {
          setState(() {
            _availableClients = data.map((client) => {
              'id': client['id'],
              'phone_number': client['phone_number'],
              'is_active': client['is_active'] ?? true,
            }).toList();
          });
        }
      }
    } catch (e) {
      if (mounted) {
        _addMessage('Erreur lors de la récupération des clients : $e', false);
      }
    }
  }

  Future<void> _fetchServices() async {
    try {
      final token = Provider.of<TokenProvider>(context, listen: false).token;
      final response = await http.get(
        Uri.parse(_apiEndpoints['services']!),
        headers: {'Authorization': 'Token $token'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body)['results'];
        if (mounted) {
          setState(() {
            _availableServices = data.map((service) => {
              'id': service['id'],
              'name': service['name'],
              'description': service['description'],
              'base_price': double.parse(service['base_price'].toString()),
            }).toList();
          });
        }
      }
    } catch (e) {
      if (mounted) {
        _addMessage('Erreur lors de la récupération des services : $e', false);
      }
    }
  }

  Future<void> fetchNotifications() async {
    try {
      final token = Provider.of<TokenProvider>(context, listen: false).token;
      final response = await noti.NotificationService(deviceToken: token).fetchNotifications(context);
      if (mounted) {
        setState(() {
          _availableNotifications = (response['results'] as List)
              .map((item) => item as Map<String, dynamic>)
              .toList();
        });
      }
    } catch (e) {
      if (mounted) {
        _addMessage('Erreur lors de la récupération des notifications : $e', false);
      }
    }
  }

  void _addMessage(String text, bool isUser) {
    if (mounted) {
      setState(() {
        _messages.add({
          'text': text,
          'isUser': isUser,
          'timestamp': DateTime.now(),
        });
      });
    }
  }

  Future<String> _getResponseFromOpenAI(String input) async {
    String _openAiApiKey = await CredentialService().getOpenAiKey();
    final String systemPrompt = '''
    Vous êtes un assistant IA pour TravailFuté une application de gestion en français.
    Vous aidez les utilisateurs avec:
    - La création de devis, factures, clients, services
    - La consultation des données existantes
    - La réponse aux questions sur l'application
    
    Données disponibles:
    Clients: $_availableClients 
    Services: ${_availableServices.length} 
    Notifications: ${_availableNotifications.length} 
    
    Historique récent:
    ${_messages.length > 3 ? _messages.sublist(_messages.length - 3) : _messages.map((m) => '${m['isUser'] ? 'Utilisateur' : 'Assistant'}: ${m['text']}').join('\n')}}
    
    Répondez en français, soyez concis et utile.
    Pour les créations, guidez pas à pas.
    ''';

    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_openAiApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': input},
          ],
          'temperature': 0.7,
          'max_tokens': 500,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'].trim();
      } else {
        logger.e('OpenAI API error: ${response.statusCode} - ${response.body}');
        return 'Désolé, une erreur est survenue avec le service AI. Veuillez réessayer.';
      }
    } catch (e) {
      logger.e('OpenAI request failed: $e');
      return 'Erreur de connexion au service AI. Veuillez vérifier votre internet.';
    }
  }

  void _processInput(String input) async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    if (_creationStep != null) {
      _processCreationStep(input.toLowerCase());
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    // Check for creation commands
    if (input.toLowerCase().contains('créer') || input.toLowerCase().contains('ajouter')) {
      if (input.toLowerCase().contains('client')) {
        _startCreation('clients');
      } else if (input.toLowerCase().contains('service')) {
        _startCreation('services');
      } else if (input.toLowerCase().contains('facture')) {
        _startCreation('bills');
      } else if (input.toLowerCase().contains('devis')) {
        _startCreation('estimates');
      } else if (input.toLowerCase().contains('notification')) {
        _startCreation('notifications');
      } else if (input.toLowerCase().contains('projet')) {
        _startCreation('projects');
      }
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    String response = await _getResponseFromOpenAI(input);
    if (mounted) {
      _addMessage(response, false);
      setState(() => _isLoading = false);
    }
  }

  void _startCreation(String entity) {
    _creationData = {
      'entity': entity,
    };
    switch (entity) {
      case 'clients':
        _creationStep = 'client_phone';
        _addMessage('Super ! Quel est le numéro de téléphone du client ?', false);
        break;
      case 'services':
        _creationStep = 'service_name';
        _addMessage('Super ! Quel est le nom du service ?', false);
        break;
      case 'bills':
      case 'estimates':
        _creationData?.addAll({
          'client': null,
          'expiration_date': null,
          'due_date': null,
          'description': 'Services rendus',
          'vat_rate': 21.0,
          'hourly_rate': null,
          'hours_worked': null,
          'items': [],
        });
        _creationStep = 'client';
        _addMessage('Super ! Pour quel client est cette ${entity == 'estimates' ? 'devis' : 'facture'} ? (ex. numéro de téléphone)', false);
        break;
      case 'notifications':
        _creationStep = 'notification_message';
        _addMessage('Super ! Quel est le message de la notification ?', false);
        break;
      case 'projects':
        _creationStep = 'project_name';
        _addMessage('Super ! Quel est le nom du projet ?', false);
        break;
    }
  }

  void _processCreationStep(String input) {
    try {
      final lowerInput = input.toLowerCase();

      if (_creationStep == null) {
        if (_messages.last['text'].contains('numéro de téléphone du client')) {
          _creationData = {'entity': 'clients'};
          _creationStep = 'client_phone';
        } 
        // ... other step detections ...
      }

      switch (_creationStep) {
        case 'client_phone':
          if (input.trim().isEmpty) {
            _addMessage('Veuillez entrer un numéro valide', false);
            return;
          }
          _creationData!['phone_number'] = input.trim();
          _creationStep = 'review';
          _addMessage('Client avec numéro ${input.trim()}. Voulez-vous créer ce client ? (Oui/Non)', false);
          break;

        case 'service_name':
          if (input.trim().isEmpty) {
            _addMessage('Veuillez entrer un nom valide', false);
            return;
          }
          _creationData!['name'] = input;
          _creationStep = 'service_description';
          _addMessage('Nom du service : $input. Quelle est la description ?', false);
          break;
          
        // ... other cases ...

        case 'review':
          if (lowerInput == 'oui' || lowerInput == 'yes') {
            _submitCreation();
          } else {
            _addMessage('Création annulée. Comment puis-je vous aider ?', false);
            _resetCreationFlow();
          }
          break;
      }
    } catch (e) {
      logger.e('Error in creation flow: $e');
      _addMessage('Une erreur est survenue. Veuillez réessayer.', false);
      _resetCreationFlow();
    }
  }

  void _resetCreationFlow() {
    _creationData = null;
    _creationStep = null;
  }

  Future<void> _submitCreation() async {
    if (_creationData == null || _creationData!['entity'] == null) return;

    final entity = _creationData!['entity'];
    final token = Provider.of<TokenProvider>(context, listen: false).token;
    Map<String, dynamic> payload;

    try {
      switch (entity) {
        case 'clients':
          payload = {'phone_number': _creationData!['phone_number']};
          break;
        case 'services':
          payload = {
            'name': _creationData!['name'],
            'description': _creationData!['description'],
            'base_price': _creationData!['base_price'],
          };
          break;
        // ... other entity cases ...
        default:
          _addMessage('Type de création non supporté', false);
          return;
      }

      final response = await http.post(
        Uri.parse(_apiEndpoints[entity]!),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 201) {
        _addMessage('${_entityToFrench(entity).capitalize()} créé avec succès !', false);
        // Refresh relevant data
        if (entity == 'clients') await _fetchClients();
        if (entity == 'services') await _fetchServices();
      } else {
        _addMessage('Échec de la création : ${response.reasonPhrase}', false);
      }
    } catch (e) {
      logger.e('Creation error: $e');
      _addMessage('Erreur lors de la création : $e', false);
    } finally {
      _resetCreationFlow();
    }
  }

  String _entityToFrench(String entity) {
    switch (entity) {
      case 'estimates': return 'devis';
      case 'clients': return 'client';
      case 'services': return 'service';
      case 'bills': return 'facture';
      case 'notifications': return 'notification';
      case 'projects': return 'projet';
      default: return entity;
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    _addMessage(_messageController.text, true);
    _processInput(_messageController.text);
    _messageController.clear();
  }

  void _showSpeakDialog() {
    showDialog(
      context: context,
      builder: (context) => _SpeakDialog(
        speechService: _speechService,
        onSpeak: (text) {
          if (text.isNotEmpty) {
            _addMessage(text, true);
            _processInput(text);
          }
          Navigator.pop(context);
        },
      ),
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
          child: Column(
            children: [
              _buildHeader(size),
              Expanded(child: _buildChatArea(size)),
              _buildInputArea(size),
            ],
          ),
        ),
      ),
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
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: kTravailFuteMainColor,
                    child: const Icon(Icons.assistant, color: Colors.white),
                  ),
                  SizedBox(width: size.width * 0.03),
                  Text(
                    'Assistant IA',
                    style: TextStyle(
                      fontSize: size.width * 0.05,
                      fontWeight: FontWeight.bold,
                      color: kTravailFuteMainColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatArea(Size size) {
    return ListView.builder(
      padding: EdgeInsets.all(size.width * 0.04),
      itemCount: _messages.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length && _isLoading) {
          return _buildLoadingBubble(size);
        }
        final message = _messages[index];
        return FadeTransition(
          opacity: _animation,
          child: _buildMessageBubble(size, message),
        );
      },
    );
  }

  Widget _buildMessageBubble(Size size, Map<String, dynamic> message) {
    final isUser = message['isUser'] as bool;
    final text = message['text'] as String;
    final timestamp = message['timestamp'] as DateTime;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: size.height * 0.01),
        padding: EdgeInsets.all(size.width * 0.03),
        constraints: BoxConstraints(maxWidth: size.width * 0.7),
        decoration: BoxDecoration(
          color: isUser ? kTravailFuteMainColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(
              color: isUser ? Colors.white : Colors.black87,
              fontSize: size.width * 0.04,
              fontFamily: 'NotoSans', // Standard font with good Unicode support
              ),
              textDirection: TextDirection.ltr,
              locale: const Locale('fr', 'FR'),
            ),
            SizedBox(height: size.height * 0.005),
            Text(
              '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                color: isUser ? Colors.white70 : Colors.grey[600],
                fontSize: size.width * 0.03,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingBubble(Size size) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: size.height * 0.01),
        padding: EdgeInsets.all(size.width * 0.03),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: size.width * 0.05,
              height: size.width * 0.05,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(kTravailFuteMainColor),
              ),
            ),
            SizedBox(width: size.width * 0.02),
            Text(
              'En train d\'écrire...',
              style: TextStyle(color: Colors.grey[600], fontSize: size.width * 0.04),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(Size size) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.03),
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
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Tapez votre message...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: size.height * 0.015,
                  horizontal: size.width * 0.04,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          SizedBox(width: size.width * 0.02),
          GestureDetector(
            onTap: _isSpeechAvailable ? _showSpeakDialog : null,
            child: Container(
              padding: EdgeInsets.all(size.width * 0.025),
              decoration: BoxDecoration(
                color: _isSpeechAvailable 
                    ? kTravailFuteSecondaryColor 
                    : Colors.grey[400],
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (_isSpeechAvailable 
                            ? kTravailFuteSecondaryColor 
                            : Colors.grey[400] ?? Colors.grey),
                        
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.mic, color: Colors.white, size: 24),
            ),
          ),
          SizedBox(width: size.width * 0.02),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              padding: EdgeInsets.all(size.width * 0.025),
              decoration: BoxDecoration(
                color: kTravailFuteMainColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: kTravailFuteMainColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.send, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpeakDialog extends StatefulWidget {
  final SpeechService speechService;
  final Function(String) onSpeak;

  const _SpeakDialog({
    required this.speechService,
    required this.onSpeak,
  });

  @override
  State<_SpeakDialog> createState() => _SpeakDialogState();
}

class _SpeakDialogState extends State<_SpeakDialog> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  String _recognizedText = '';
  String _status = 'Appuyez pour parler';
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _stopListening();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (widget.speechService.isListening) {
      await _stopListening();
    } else {
      await _startListening();
    }
  }

  Future<void> _startListening() async {
    setState(() {
      _isProcessing = true;
      _status = 'Écoute en cours...';
      _recognizedText = '';
    });
    _pulseController.repeat(reverse: true);

    try {
      final text = await widget.speechService.listen();
      if (text != null && text.isNotEmpty) {
        setState(() {
          _recognizedText = text;
          _status = 'Appuyez pour parler à nouveau';
        });
        widget.onSpeak(text);
      }
    } catch (e) {
      logger.e('Listening error: $e');
      if (mounted) {
        setState(() {
          _status = 'Erreur, réessayez';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          if (_recognizedText.isEmpty) {
            _status = 'Appuyez pour réessayer';
          }
        });
        _pulseController.stop();
      }
    }
  }

  Future<void> _stopListening() async {
    await widget.speechService.stop();
    if (mounted) {
      setState(() {
        _isProcessing = false;
        _status = _recognizedText.isEmpty ? 'Appuyez pour réessayer' : 'Appuyez pour parler à nouveau';
      });
      _pulseController.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
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
              _status,
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
                scale: widget.speechService.isListening 
                    ? _pulseAnimation 
                    : const AlwaysStoppedAnimation(1.0),
                child: Container(
                  padding: EdgeInsets.all(size.width * 0.05),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.speechService.isListening 
                        ? Colors.red 
                        : kTravailFuteSecondaryColor,
                    boxShadow: [
                      BoxShadow(
                        color: (widget.speechService.isListening 
                                ? Colors.red 
                                : kTravailFuteSecondaryColor)
                            .withOpacity(0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.speechService.isListening ? Icons.stop : Icons.mic,
                    color: Colors.white,
                    size: size.width * 0.1,
                  ),
                ),
              ),
            ),
            if (_recognizedText.isNotEmpty) ...[
              SizedBox(height: size.height * 0.03),
              Text(
                'Vous avez dit:',
                style: TextStyle(
                  fontSize: size.width * 0.04,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: size.height * 0.01),
              Text(
                _recognizedText,
                style: TextStyle(
                  fontSize: size.width * 0.04,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (_isProcessing) ...[
              SizedBox(height: size.height * 0.03),
              const CircularProgressIndicator(),
            ],
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}