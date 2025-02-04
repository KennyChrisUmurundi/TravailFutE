import 'package:flutter/material.dart';
import 'message_detail_screen.dart';
import '../widgets/message_card.dart'; // Import the MessageCard widget

class MessagesScreen extends StatelessWidget {
  final Future<List<Map<String, String>>?> sms;

  MessagesScreen({required this.sms});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Messages', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Add search functionality
            },
          ),
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {
              // Add more options
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, String>>?>(
        future: sms,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No messages found.'));
          } else {
            var groupedMessages = snapshot.data!
                .fold<Map<String, List<Map<String, String>>>>({}, (acc, message) {
                  acc.putIfAbsent(message['sender']!, () => []).add(message);
                  return acc;
                });

            return ListView(
              children: groupedMessages.entries.map((entry) {
                var lastMessage = entry.value.last['body'] ?? 'No message body';
                var subtitle = lastMessage.length > 20
                    ? lastMessage.substring(lastMessage.length - 20)
                    : lastMessage;
                return MessageCard(
                  title: entry.key,
                  subtitle: subtitle,
                  trailing: entry.value.last['date'] ?? '',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MessageDetailScreen(messages: entry.value),
                      ),
                    );
                  },
                );
              }).toList(),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new message functionality
        },
        child: Icon(Icons.message),
        backgroundColor: Colors.blue,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          // Handle bottom navigation tap
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.archive),
            label: 'Archived',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report),
            label: 'Spam',
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String message;
  final String timestamp;

  ChatBubble({required this.message, required this.timestamp});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 4.0),
      padding: EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(height: 5.0),
          Text(
            timestamp,
            style: TextStyle(color: Colors.white70, fontSize: 10.0),
          ),
        ],
      ),
    );
  }
}

class MessageDetailScreen extends StatelessWidget {
  final List<Map<String, String>> messages;

  MessageDetailScreen({required this.messages});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Messages from ${messages.first['sender']}'),
        backgroundColor: Colors.blueAccent,
      ),
      body: ListView.builder(
        itemCount: messages.length,
        itemBuilder: (context, index) {
          var message = messages[index];
          return ChatBubble(
            message: message['body'] ?? 'No message body',
            timestamp: message['date'] ?? '',
          );
        },
      ),
    );
  }
}
