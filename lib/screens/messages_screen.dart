import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:travail_fute/providers/message_provider.dart';
import 'package:travail_fute/widgets/message_card.dart'; // Add this line to import MessageCard widget
import 'package:travail_fute/screens/message_detail_screen.dart'; // Import MessageDetailScreen
import 'package:travail_fute/utils/logger.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  static const platform = MethodChannel('sms_channel');

  Future<void> fetchSms() async {
    final messageProvider = Provider.of<MessageProvider>(context, listen: false);

    try {
      final List<dynamic> result = await platform.invokeMethod('getSms');

      // Convert to List<Map<String, dynamic>> safely
      final List<Map<String, dynamic>> messages = result.map((item) {
        return Map<String, dynamic>.from(item);
      }).toList();

      // Convert all values to strings
      final List<Map<String, String>> stringMessages = messages.map((message) {
        return message.map((key, value) => MapEntry(key, value.toString()));
      }).toList();

      messageProvider.setMessages(stringMessages);
    } on PlatformException catch (e) {
      messageProvider.setMessages([]);
      logger.e("Failed to get SMS: '${e.message}'.");
    }
  }
  @override
  void initState() {
    fetchSms();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Messages'),
      ),
      body: Consumer<MessageProvider>(
        builder: (context, messageProvider, child) {
          final messages = messageProvider.messages;
          logger.i("First 5 messages: ${messages.take(5).toList()}");
          final Map<String, List<Map<String, dynamic>>> groupedMessages = {};
          final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

          for (var message in messages) {
            final sender = message['address'] ?? 'Unknown';
            if (!groupedMessages.containsKey(sender)) {
              groupedMessages[sender] = [];
            }
            groupedMessages[sender]!.add(message);
          }

          // Sort messages for each sender based on formattedDate in descending order
          groupedMessages.forEach((sender, messages) {
            messages.sort((a, b) {
              final dateA = dateFormat.parse(a['formattedDate']!);
              final dateB = dateFormat.parse(b['formattedDate']!);
              return dateB.compareTo(dateA); // Sort in descending order
            });
          });

          // Sort senders based on the latest message date in descending order
          final sortedSenders = groupedMessages.keys.toList();
          sortedSenders.sort((a, b) {
            final latestMessageA = groupedMessages[a]!.first;
            final latestMessageB = groupedMessages[b]!.first;
            final dateA = dateFormat.parse(latestMessageA['formattedDate']!);
            final dateB = dateFormat.parse(latestMessageB['formattedDate']!);
            return dateB.compareTo(dateA); // Sort in descending order
          });

          return ListView.builder(
            itemCount: sortedSenders.length,
            itemBuilder: (context, index) {
              final sender = sortedSenders[index];
              final messagesFromSender = groupedMessages[sender]!;

              // Get the latest message
              final latestMessage = messagesFromSender.first;

              return MessageCard(
                title: latestMessage['address'] != null && latestMessage['address']!.contains('+32')
                  ? latestMessage['address']!.replaceFirst('+32', '0').replaceAllMapped(RegExp(r'(\d{4})(\d{2})(\d{2})(\d{2})'), (Match m) => '${m[1]} ${m[2]} ${m[3]} ${m[4]}')
                  : latestMessage['address'] ?? '',
                subtitle: latestMessage['body'] != null 
                    ? latestMessage['body']!.substring(0, latestMessage['body']!.length > 16 ? 16 : latestMessage['body']!.length)
                    : '',
                trailing: DateFormat('d MMM').format(dateFormat.parse(latestMessage['formattedDate']!)),
                onTap: () {
                  // Navigate to message detail screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MessageDetailScreen(
                        sentMessages: messagesFromSender.where((msg) => msg['type'] == 'sent').toList().cast<Map<String, String>>(),
                        receivedMessages: messagesFromSender.where((msg) => msg['type'] == 'received').toList().cast<Map<String, String>>(),
                        sender: sender,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
