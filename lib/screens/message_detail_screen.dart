import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:travail_fute/widgets/foab.dart';

class MessageDetailScreen extends StatelessWidget {
  final List<Map<String, String>> sentMessages;
  final List<Map<String, String>> receivedMessages;
  final String sender;

  MessageDetailScreen({required this.sentMessages, required this.receivedMessages, required this.sender});

  @override
  Widget build(BuildContext context) {
    final allMessages = [...sentMessages, ...receivedMessages];
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

    // Parse the formattedDate and store it in a new key 'dateTime'
    for (var message in allMessages) {
      message['dateTime'] = dateFormat.parse(message['formattedDate']!).toIso8601String();
    }

    // Sort messages based on the parsed dateTime
    allMessages.sort((a, b) {
      final dateA = DateTime.parse(a['dateTime']!);
      final dateB = DateTime.parse(b['dateTime']!);
      return dateA.compareTo(dateB);
    });

    final ScrollController _scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('$sender'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: false, // This will make the latest message appear at the bottom
              itemCount: allMessages.length,
              itemBuilder: (context, index) {
                final message = allMessages[index];
                final isSent = message['type'] == 'sent';

                return Align(
                  alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: EdgeInsets.all(10),
                    width: MediaQuery.of(context).size.width * 0.8,
                    decoration: BoxDecoration(
                      color: isSent ? const Color.fromARGB(255, 194, 212, 231) : const Color.fromARGB(255, 236, 230, 230),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      message['body'] ?? '',
                      style: TextStyle(fontSize:14, color: Color.fromARGB(255, 31, 30, 30)),
                    ),
                  ),
                );
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              width: 250,
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      style: TextStyle(fontSize: 12),
                      decoration: InputDecoration(
                        hintText: 'message',
                        // border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                        ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    // Handle send button press
                    print('Send button pressed');
                  },
                ),
              ],
            ),
                    ),
          ),
      ],
    ),
    floatingActionButton: MyCenteredFAB(),
    // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
  );
}
}
