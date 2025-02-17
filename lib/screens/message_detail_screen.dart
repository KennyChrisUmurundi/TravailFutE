import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:travail_fute/constants.dart';
import 'package:travail_fute/screens/notification_screen.dart';
import 'package:travail_fute/services/notification_service.dart';
import 'package:travail_fute/utils/provider.dart';
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
    final token = Provider.of<TokenProvider>(context).token;
    final NotificationService notificationService = NotificationService(deviceToken: token);

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
        title: Text(
          sender.startsWith('+32')
              ? sender.replaceFirst('+32', '0').replaceAllMapped(RegExp(r'(\d{4})(\d{2})(\d{2})(\d{2})'), (Match m) => '${m[1]} ${m[2]} ${m[3]} ${m[4]}')
              : sender,
          style: TextStyle(fontSize: 16),
        ),
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
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        padding: EdgeInsets.all(10),
                        width: MediaQuery.of(context).size.width * 0.8,
                        decoration: BoxDecoration(
                          color: isSent ? const Color.fromARGB(255, 194, 212, 231) : const Color.fromARGB(255, 236, 230, 230),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          message['body'] ?? '',
                          style: TextStyle(fontSize: 14, color: Color.fromARGB(255, 31, 30, 30)),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: RecordFAB(onPressed: (String result) {
        final TextEditingController _textController = TextEditingController(text: result);
        DateTime selectedDate = DateTime.now();
        TimeOfDay selectedTime = TimeOfDay.now();

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Rappel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        style: TextStyle(fontSize: 14),
                        controller: _textController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Votre rappel',
                        ),
                      ),
                      SizedBox(height: 20),
                      ListTile(
                        title: Text("Date: ${DateFormat('MM-dd').format(selectedDate)}"),
                        trailing: Icon(Icons.calendar_today),
                        onTap: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2025),
                            lastDate: DateTime(2026),
                          );
                          if (picked != null && picked != selectedDate) {
                            selectedDate = picked;
                          }
                        },
                      ),
                      SizedBox(height: 20),
                      ListTile(
                        title: Text("Heure: ${selectedTime.format(context)}"),
                        trailing: Icon(Icons.access_time),
                        onTap: () async {
                          TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: selectedTime,
                          );
                          if (picked != null && picked != selectedTime) {
                            selectedTime = picked;
                          }
                        },
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            child: Text('Annuler', style: TextStyle(color: Colors.black)),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(kTravailFuteMainColor),
                            ),
                            child: Text('Ok'),
                            onPressed: () {
                              try {
                                notificationService.sendNotification(
                                  'client $sender',
                                  _textController.text,
                                  dueDate: DateFormat('MM-dd').format(selectedDate),
                                  dueTime: selectedTime.format(context),
                                );
                                Navigator.of(context).pop();
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => NotificationScreen()),
                                );
                              } catch (e) {
                                print('Error sending notification: $e');
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
