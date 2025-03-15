import 'package:flutter/material.dart';
import 'package:travail_fute/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:travail_fute/services/credential_service.dart';
import 'package:travail_fute/services/notification_service.dart' as noti;
import 'package:travail_fute/utils/provider.dart'; // Assuming TokenProvider is here
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
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

  // API Endpoints
  final Map<String, String> _apiEndpoints = {
    'estimates': '$apiUrl/estimates/',
    'clients': '$apiUrl/clients/',
    'services': '$apiUrl/invoice/services/',
    'bills': '$apiUrl/bills/',
    'notifications': '$apiUrl/notifications/',
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
      'text': 'Bonjour ! Comment puis-je vous aider aujourd’hui ? Posez-moi une question ou demandez-moi de créer quelque chose !',
      'isUser': false,
      'timestamp': DateTime.now(),
    });
    _fetchInitialData();
  }

  @override
  void dispose() {
    _controller.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _fetchInitialData() async {
    await _fetchClients();
    await _fetchServices();
    await fetchNotifications();
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
        setState(() {
          _availableClients = data.map((client) => {
            'id': client['id'],
            'phone_number': client['phone_number'],
            'is_active': client['is_active'] ?? true, // Assuming an 'is_active' field
          }).toList();
        });
      }
    } catch (e) {
      _addMessage('Erreur lors de la récupération des clients : $e', false);
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
        setState(() {
          _availableServices = data.map((service) => {
            'id': service['id'],
            'name': service['name'],
            'description': service['description'],
            'base_price': double.parse(service['base_price'].toString()),
          }).toList();
        });
      }
    } catch (e) {
      _addMessage('Erreur lors de la récupération des services : $e', false);
    }
  }

  Future<void> _fetchData(String endpoint, Function(List<dynamic>) onSuccess) async {
    try {
      final token = Provider.of<TokenProvider>(context, listen: false).token;
      final response = await http.get(
        Uri.parse(_apiEndpoints[endpoint]!),
        headers: {'Authorization': 'Token $token'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        onSuccess(data is List ? data : data['results']);
      } else {
        _addMessage('Erreur lors de la récupération des données : ${response.reasonPhrase}', false);
      }
    } catch (e) {
      _addMessage('Erreur : $e', false);
    }
  }
Future<void> fetchNotifications() async {
  final token = Provider.of<TokenProvider>(context, listen: false).token;
  final response = await noti.NotificationService(deviceToken: token).fetchNotifications(context);
  _availableNotifications = (response['results'] as List)
      .map((item) => item as Map<String, dynamic>)
      .toList();
}
  

  void _addMessage(String text, bool isUser) {
    setState(() {
      _messages.add({
        'text': text,
        'isUser': isUser,
        'timestamp': DateTime.now(),
      });
    });
  }

  Future<String> _getResponseFromOpenAI(String input) async {
    String _openAiApiKey = await CredentialService().getOpenAiKey();
    const String systemPrompt = '''
    Vous êtes un assistant IA pour une application de gestion en français (devis, factures, clients, services, notifications, projets). Votre rôle est de :
    - Répondre aux questions de l'utilisateur en utilisant les données fournies (clients, services) ou en demandant des clarifications.
    - Si l'utilisateur veut créer une entité, poser la première question du processus de création de manière naturelle (ex. "Super ! Quel est le numéro de téléphone du client ?" pour un client).
    - Les entités valides pour la création sont : clients, services, factures (bills), devis (estimates), notifications, projets. Si une entité demandée n’est pas dans cette liste, informer l'utilisateur de manière conviviale (ex. "Je ne peux pas créer cela. Essayez client, service, facture, devis, notification ou projet.").
    - Fournir des réponses naturelles et contextuelles en français, en maintenant une conversation fluide.
    - Ne pas utiliser de marqueurs comme [[CREATE:entity]], mais guider l'utilisateur étape par étape si une création est détectée.

    Données actuelles :
    - Clients : {{clients}}
    - Services : {{services}}
    - Notifications: {{notifications}}

    Historique de la conversation :
    {{history}}
    ''';

  String clientsJson = jsonEncode(_availableClients);
  String servicesJson = jsonEncode(_availableServices);
  String notificationsJson = jsonEncode(_availableNotifications);
  String history = _messages.map((m) => '${m['isUser'] ? 'Utilisateur' : 'Assistant'} : ${m['text']}').join('\n');

  String prompt = '${systemPrompt
      .replaceAll('{{clients}}', clientsJson)
      .replaceAll('{{services}}', servicesJson)
      .replaceAll('{{notifications}}', notificationsJson)
      .replaceAll('{{history}}', history)}\nUtilisateur : $input\nAssistant : ';

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
          {'role': 'system', 'content': prompt},
          {'role': 'user', 'content': input},
        ],
        'max_tokens': 200,
        'temperature': 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'].trim();
    } else {
      return 'Erreur OpenAI : ${response.reasonPhrase}';
    }
  } catch (e) {
    return 'Erreur lors de l’appel à OpenAI : $e';
  }
}

  void _processInput(String input) async {
  setState(() => _isLoading = true);

  if (_creationStep != null) {
    _processCreationStep(input.toLowerCase());
    setState(() => _isLoading = false);
    return;
  }

  String response = await _getResponseFromOpenAI(input);
  _addMessage(response, false);

  setState(() => _isLoading = false);
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
  final lowerInput = input.toLowerCase();

  // If no creation step is set, infer it from OpenAI's response context
  if (_creationStep == null) {
    if (_messages.last['text'].contains('numéro de téléphone du client')) {
      _creationData = {'entity': 'clients'};
      _creationStep = 'client_phone';
    } else if (_messages.last['text'].contains('nom du service')) {
      _creationData = {'entity': 'services'};
      _creationStep = 'service_name';
    } else if (_messages.last['text'].contains('quel client') && _messages.last['text'].contains('facture')) {
      _creationData = {'entity': 'bills', 'client': null, 'items': [], 'description': 'Services rendus', 'vat_rate': 21.0, 'hourly_rate': null, 'hours_worked': null};
      _creationStep = 'client';
    } else if (_messages.last['text'].contains('quel client') && _messages.last['text'].contains('devis')) {
      _creationData = {'entity': 'estimates', 'client': null, 'items': [], 'description': 'Services rendus', 'vat_rate': 21.0, 'hourly_rate': null, 'hours_worked': null};
      _creationStep = 'client';
    } else if (_messages.last['text'].contains('message de la notification')) {
      _creationData = {'entity': 'notifications'};
      _creationStep = 'notification_message';
    } else if (_messages.last['text'].contains('nom du projet')) {
      _creationData = {'entity': 'projects'};
      _creationStep = 'project_name';
    }
  }

  // Proceed with the creation steps
  switch (_creationStep) {
    case 'client_phone':
      _creationData!['phone_number'] = input.trim();
      _creationStep = 'review';
      _addMessage('Client avec numéro ${input.trim()}. Voulez-vous soumettre ceci ? (Oui/Non)', false);
      break;

    case 'service_name':
      _creationData!['name'] = input;
      _creationStep = 'service_description';
      _addMessage('Nom du service : $input. Quelle est la description ?', false);
      break;
    case 'service_description':
      _creationData!['description'] = input;
      _creationStep = 'service_price';
      _addMessage('Description : $input. Quel est le prix de base ? (ex. 100)', false);
      break;
    case 'service_price':
      if (double.tryParse(input) != null && double.parse(input) >= 0) {
        _creationData!['base_price'] = double.parse(input);
        _creationStep = 'review';
        _addMessage('Service : ${_creationData!['name']}, Description : ${_creationData!['description']}, Prix : ${_creationData!['base_price']} €. Voulez-vous soumettre ceci ? (Oui/Non)', false);
      } else {
        _addMessage('Veuillez entrer un prix valide (ex. 100).', false);
      }
      break;

    case 'client':
      final client = _availableClients.firstWhere(
        (c) => c['phone_number'].toString().contains(input.trim()),
        orElse: () => {},
      );
      if (client.isNotEmpty) {
        _creationData!['client'] = client;
        _creationStep = 'services';
        _addMessage('Parfait, client ${client['phone_number']}. Quels services voulez-vous inclure ? (Dites "liste des services" pour voir les options)', false);
      } else {
        _addMessage('Client non trouvé. Veuillez fournir un numéro parmi : ${_availableClients.map((c) => c['phone_number']).join(', ')}', false);
      }
      break;
    // ... (rest of the cases remain unchanged)
  }
}

  void _showCreationReview() {
    final entity = _creationData!['entity'];
    if (entity == 'estimates' || entity == 'bills') {
      final isEstimate = entity == 'estimates';
      _creationData![isEstimate ? 'expiration_date' : 'due_date'] =
          DateTime.now().add(Duration(days: 30)).toIso8601String().split('T')[0];
      String summary = 'Voici ce que j\'ai :\n'
          '- Type : ${isEstimate ? 'Devis' : 'Facture'}\n'
          '- Client : ${_creationData!['client']['phone_number']}\n'
          '- Services : ${_creationData!['items'].map((item) => "${_availableServices.firstWhere((s) => s['id'] == item['service'])['name']} x ${item['quantity']}").join(', ')}\n'
          '- Taux horaire : ${_creationData!['hourly_rate']} €, Heures : ${_creationData!['hours_worked']}\n'
          '- TVA : ${_creationData!['vat_rate']}%, ${isEstimate ? 'Expire le' : 'Due le'} : ${_creationData![isEstimate ? 'expiration_date' : 'due_date']}\n'
          '- Description : ${_creationData!['description']}\n'
          'Voulez-vous soumettre ceci ? (Oui/Non)';
      _addMessage(summary, false);
    }
  }

  Future<void> _submitCreation() async {
    final entity = _creationData!['entity'];
    final token = Provider.of<TokenProvider>(context, listen: false).token;
    Map<String, dynamic> payload;

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
      case 'estimates':
      case 'bills':
        final isEstimate = entity == 'estimates';
        payload = {
          'client': _creationData!['client']['id'],
          isEstimate ? 'expiration_date' : 'due_date': _creationData![isEstimate ? 'expiration_date' : 'due_date'],
          'description': _creationData!['description'],
          'vat_rate': _creationData!['vat_rate'],
          'hourly_rate': _creationData!['hourly_rate'],
          'hours_worked': _creationData!['hours_worked'],
          isEstimate ? 'estimate_items' : 'bill_items': _creationData!['items'],
          if (isEstimate) 'status': 'draft',
        };
        break;
      case 'notifications':
        payload = {'message': _creationData!['message']};
        break;
      case 'projects':
        payload = {
          'name': _creationData!['name'],
          'description': _creationData!['description'],
        };
        break;
      default:
        _addMessage('Entité non reconnue pour la création.', false);
        return;
    }

    try {
      final response = await http.post(
        Uri.parse(_apiEndpoints[entity]!),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );
      if (response.statusCode == 201) {
        _addMessage('${_entityToFrench(entity).capitalize()} créé avec succès ! Comment puis-je vous aider maintenant ?', false);
        if (entity == 'clients') await _fetchClients();
        if (entity == 'services') await _fetchServices();
      } else {
        _addMessage('Échec de la création : ${response.reasonPhrase}', false);
      }
    } catch (e) {
      _addMessage('Erreur lors de la soumission : $e', false);
    }
  }

  String _entityToFrench(String entity) {
    switch (entity) {
      case 'estimates':
        return 'devis';
      case 'clients':
        return 'clients';
      case 'services':
        return 'services';
      case 'bills':
        return 'factures';
      case 'notifications':
        return 'notifications';
      case 'projects':
        return 'projets';
      default:
        return entity;
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    _addMessage(_messageController.text, true);
    _processInput(_messageController.text);
    _messageController.clear();
  }

  void _showSpeakDialog() {
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
            child: _SpeakDialog(
              onSpeak: (text) {
                _addMessage(text, true);
                _processInput(text);
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
              ),
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
            onTap: _showSpeakDialog,
            child: Container(
              padding: EdgeInsets.all(size.width * 0.025),
              decoration: BoxDecoration(
                color: kTravailFuteSecondaryColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: kTravailFuteSecondaryColor.withOpacity(0.3),
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
  final Function(String) onSpeak;

  const _SpeakDialog({required this.onSpeak});

  @override
  State<_SpeakDialog> createState() => _SpeakDialogState();
}

class _SpeakDialogState extends State<_SpeakDialog> with SingleTickerProviderStateMixin {
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
    _initializeSpeech();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _speech.stop();
    super.dispose();
  }

  Future<void> _initializeSpeech() async {
    if (await Permission.microphone.request().isGranted) {
      bool available = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            setState(() {
              _isRecording = false;
              _pulseController.stop();
            });
            if (_recognizedText.isNotEmpty) {
              widget.onSpeak(_recognizedText);
              Navigator.pop(context);
            }
          }
        },
        onError: (error) => logger.i('Speech error: $error'),
      );
      if (!available) {
        _showError('Impossible d\'initialiser la reconnaissance vocale.');
      }
    } else {
      _showError('Permission de microphone refusée.');
    }
  }

  void _toggleRecording() async {
    if (_isRecording) {
      await _speech.stop();
      setState(() {
        _isRecording = false;
        _pulseController.stop();
      });
      if (_recognizedText.isNotEmpty) {
        widget.onSpeak(_recognizedText);
        Navigator.pop(context);
      }
    } else {
      if (await _speech.initialize()) {
        setState(() {
          _isRecording = true;
          _recognizedText = '';
          _pulseController.repeat(reverse: true);
        });
        await _speech.listen(
          onResult: (result) {
            setState(() {
              _recognizedText = result.recognizedWords;
            });
          },
          localeId: 'fr_FR', // French language
        );
      } else {
        _showError('Erreur lors du démarrage de la reconnaissance vocale.');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
              _isRecording ? 'Écoute en cours...' : 'Parlez maintenant',
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
                'Appuyez pour arrêter',
                style: TextStyle(
                  fontSize: size.width * 0.04,
                  color: Colors.grey[600],
                ),
              ),
            if (_recognizedText.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: size.height * 0.02),
                child: Text(
                  'Reconnu : "$_recognizedText"',
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

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}