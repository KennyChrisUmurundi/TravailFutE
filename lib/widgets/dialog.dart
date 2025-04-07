import 'package:flutter/material.dart';
import 'package:travail_fute/constants.dart';
import 'package:intl/intl.dart'; 
import 'package:travail_fute/screens/notification_screen.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart' as dt_picker;

void showReminderDialog({
  required BuildContext context,
  required TextEditingController textController,
  required DateTime selectedDateTime,
  required String sender,
  required dynamic notificationService, // Replace with your actual service type
  required dynamic notification, // Replace with your actual notification type
  // required dynamic dt_picker, // Replace with your date picker type
}) {
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
          child: _ReminderDialog(
            textController: textController,
            selectedDateTime: selectedDateTime,
            sender: sender,
            notificationService: notificationService,
            notification: notification,
            // dt_picker: dt_picker,
          ),
        ),
      );
    },
  );
}

class _ReminderDialog extends StatefulWidget {
  final TextEditingController textController;
  final DateTime selectedDateTime;
  final String sender;
  final dynamic notificationService; // Replace with your actual service type
  final dynamic notification; // Replace with your actual notification type
  // final dynamic dt_picker; // Replace with your date picker type

  const _ReminderDialog({
    required this.textController,
    required this.selectedDateTime,
    required this.sender,
    required this.notificationService,
    required this.notification,
    // required this.dt_picker,
  });

  @override
  State<_ReminderDialog> createState() => _ReminderDialogState();
}

class _ReminderDialogState extends State<_ReminderDialog> with SingleTickerProviderStateMixin {
  late DateTime _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _selectedDateTime = widget.selectedDateTime;
  }

  Future<void> _pickDateTime() async {
    dt_picker.DatePicker.showDateTimePicker(
      context,
      showTitleActions: true,
      minTime: DateTime(2025, 1, 1),
      maxTime: DateTime(2026, 12, 31),
      onConfirm: (date) async {
        setState(() => _selectedDateTime = date);
        await _scheduleNotification();
      },
      currentTime: _selectedDateTime,
      locale: dt_picker.LocaleType.fr,
    );
  }

  Future<void> _scheduleNotification() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await widget.notificationService.sendNotification(
        widget.sender,
        widget.textController.text,
        dueDate: DateFormat('yyyy-MM-dd').format(_selectedDateTime),
        dueTime: DateFormat('HH:mm').format(_selectedDateTime),
      );

      try {
        widget.notification.scheduleNotification(
          _selectedDateTime,
          widget.sender,
          widget.textController.text,
        );
        Navigator.pop(context); // Close loading dialog
        Navigator.pop(context); // Close reminder dialog
        _showSuccessDialog();
      } catch (e) {
        print('Error scheduling notification: $e');
        Navigator.pop(context); // Close loading dialog
        _showErrorDialog('Error scheduling notification: $e');
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      _showErrorDialog('Error sending notification: $e');
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text('Succès', style: TextStyle(color: kTravailFuteMainColor)),
        content: Text('Notification programmée avec succès'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationScreen()),
              );
            },
            child: Text('OK', style: TextStyle(color: kTravailFuteSecondaryColor)),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text('Erreur', style: TextStyle(color: Colors.red)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: kTravailFuteSecondaryColor)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: width * 0.85,
        padding: EdgeInsets.all(width * 0.05),
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Rappel',
                style: TextStyle(
                  fontSize: width * 0.05,
                  fontWeight: FontWeight.bold,
                  color: kTravailFuteMainColor,
                ),
              ),
              SizedBox(height: width * 0.05),
              TextField(
                controller: widget.textController,
                maxLines: 5,
                style: TextStyle(fontSize: width * 0.04),
                decoration: InputDecoration(
                  labelText: '💥💥',
                  labelStyle: TextStyle(color: Colors.grey[600]),
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
              SizedBox(height: width * 0.05),
              GestureDetector(
                onTap: _pickDateTime,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: width * 0.03,
                    horizontal: width * 0.05,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [kTravailFuteMainColor, kTravailFuteSecondaryColor],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: kTravailFuteMainColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_today, color: kWhiteColor, size: width * 0.05),
                      SizedBox(width: width * 0.02),
                      Text(
                        "Date et Heure",
                        style: TextStyle(
                          fontSize: width * 0.04,
                          color: kWhiteColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: width * 0.05),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: width * 0.025,
                        horizontal: width * 0.05,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        'Annuler',
                        style: TextStyle(
                          fontSize: width * 0.04,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}