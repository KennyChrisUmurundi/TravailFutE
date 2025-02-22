import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:travail_fute/constants.dart';
import 'package:travail_fute/screens/notification_screen.dart';
import 'package:travail_fute/services/notification_service.dart';
import 'package:travail_fute/utils/noti.dart';
import 'package:travail_fute/utils/provider.dart';
import 'package:travail_fute/widgets/foab.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart' as dt_picker;

class MessageDetailScreen extends StatelessWidget {
  final List<Map<String, String>> sentMessages;
  final List<Map<String, String>> receivedMessages;
  final notification = Noti();
  final String sender;

  MessageDetailScreen({super.key, required this.sentMessages, required this.receivedMessages, required this.sender});

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

    final ScrollController scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
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
              controller: scrollController,
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
        final TextEditingController textController = TextEditingController(text: result);
        DateTime selectedDateTime = DateTime.now().add(Duration(seconds: 10));

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
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        style: TextStyle(fontSize: 14),
                        controller: textController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Votre rappel',
                        ),
                      ),
                      SizedBox(height: 20),
                      ListTile(
                        title: ElevatedButton.icon(
                          onPressed: () async {
                          dt_picker.DatePicker.showDateTimePicker(
                            context,
                            showTitleActions: true,
                            minTime: DateTime(2025, 1, 1),
                            maxTime: DateTime(2026, 12, 31),
                            onConfirm: (date) async {
                              print('confirm $date');
                              selectedDateTime = date;
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return Center(child: CircularProgressIndicator());
                                },
                              );

                              try {
                                await notificationService.sendNotification(
                                  sender,
                                  textController.text,
                                  dueDate: DateFormat('yyyy-MM-dd').format(selectedDateTime),
                                  dueTime: DateFormat('HH:mm').format(selectedDateTime),
                                );

                                // Schedule the notification
                                try {
                                  notification.scheduleNotification(
                                  selectedDateTime,
                                  sender,
                                  textController.text,
                                  );
                                  Navigator.of(context).pop(); // 
                                  Navigator.of(context).pop();
                                  showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                    title: Text('Succès'),
                                    content: Text('Notification programmée avec succès'),
                                    actions: [
                                      TextButton(
                                      child: Text('OK'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => NotificationScreen(),
                                          ),
                                        );
                                      },
                                      ),
                                    ],
                                    );
                                    
                                  },
                                );
                                } catch (e) {
                                  print('Error scheduling notification: $e');
                                }
                                // Close the reminder dialog
                                 // Close the loading dialog
                                // Navigate to NotificationScreen
                              } catch (e) {
                                // Close the loading dialog
                                Navigator.of(context).pop();
                              }
                            },
                            currentTime: selectedDateTime,
                            locale: dt_picker.LocaleType.fr,
                          );
                          },
                          icon: Icon(Icons.calendar_today),
                          label: Text(
                          " Date et Heure",
                          style: TextStyle(fontSize: 12, color: kTravailFuteMainColor),
                          ),
                          
                        ),
                        // trailing: Icon(Icons.calendar_today),
                        onTap: () async {
                          dt_picker.DatePicker.showDateTimePicker(
                            context,
                            showTitleActions: true,
                            minTime: DateTime(2025, 1, 1),
                            maxTime: DateTime(2026, 12, 31),
                            onConfirm: (date) async{
                              print("tje date is $date"); 
                              selectedDateTime = date;
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return Center(child: CircularProgressIndicator());
                                },
                              );

                              try {
                                await notificationService.sendNotification(
                                  sender,
                                  textController.text,
                                  dueDate: DateFormat('yyyy-MM-dd').format(selectedDateTime),
                                  dueTime: DateFormat('HH:mm').format(selectedDateTime),
                                );

                                // Schedule the notification
                                try {
                                  notification.scheduleNotification(
                                  selectedDateTime, 
                                  sender, 
                                  textController.text,
                                  );
                                  Navigator.of(context).pop(); // Close the loading dialog
                                  // Navigator.of(context).pushNamed('/NotificationScreen'); // Navigate to NotificationScreen
                                } catch (e) {
                                  print('Error scheduling notification: $e');
                                }
                                // Close the reminder dialog
                                
                              } catch (e) {
                                // Close the loading dialog
                                Navigator.of(context).pop();
                                
                              }
                            },
                            currentTime: selectedDateTime,
                            locale: dt_picker.LocaleType.fr,
                          );
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

