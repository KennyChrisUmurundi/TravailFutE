import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:travail_fute/constants.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart' as dt_picker;
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:travail_fute/services/project_service.dart';

class CreateProjectScreen extends StatefulWidget {
  const CreateProjectScreen({super.key});

  @override
  State<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _clientController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  bool isLoading = false;
  final projectService = ProjectService();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _clientController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    dt_picker.DatePicker.showDatePicker(
      context,
      showTitleActions: true,
      minTime: DateTime.now(),
      maxTime: DateTime.now().add(const Duration(days: 365 * 5)),
      onConfirm: (date) {
        setState(() {
          if (isStart) {
            _startDate = date;
          } else {
            _endDate = date;
          }
        });
      },
      currentTime: isStart ? _startDate ?? DateTime.now() : _endDate ?? DateTime.now(),
      locale: dt_picker.LocaleType.fr,
    );
  }

  Future<void> _submitProject() async {
    if (_nameController.text.isEmpty || _clientController.text.isEmpty || _startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    setState(() => isLoading = true);
    final projectData = {
      'name': _nameController.text,
      'client': _clientController.text,
      'description': _descriptionController.text,
      'start_date': _startDate?.toIso8601String(),
      'end_date': _endDate?.toIso8601String(),
    };

    try {
      await projectService.createProject(context, projectData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Project created successfully')),
      );
      Navigator.pop(context, true); // Return true to trigger refresh in ProjectScreen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating project: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          height: 30,
          child: Image.asset('assets/images/splash.png'),
        ),
        shadowColor: Colors.white,
        elevation: 0.3,
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildForm(size, width),
            ),
            if (isLoading) _buildLoadingOverlay(width),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(width),
    );
  }

  Widget _buildHeader(Size size, double width) {
    return Container(
      padding: EdgeInsets.all(width * 0.05),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kTravailFuteMainColor, kTravailFuteSecondaryColor],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(width * 0.025),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kWhiteColor.withOpacity(0.2),
                boxShadow: [
                  BoxShadow(
                    color: kWhiteColor.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(Icons.arrow_back, color: kWhiteColor, size: width * 0.06),
            ),
          ),
          SizedBox(width: width * 0.04),
          Expanded(
            child: FadeTransition(
              opacity: _animation,
              child: Text(
                'Create New Project',
                style: TextStyle(
                  fontSize: width * 0.05,
                  fontWeight: FontWeight.bold,
                  color: kWhiteColor,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(Size size, double width) {
    return Padding(
      padding: EdgeInsets.all(width * 0.05),
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(width * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(width, 'Project Details'),
              SizedBox(height: width * 0.03),
              _buildTextField(width, _nameController, 'Project Name', Icons.work),
              SizedBox(height: width * 0.04),
              _buildTextField(width, _clientController, 'Client', Icons.person),
              SizedBox(height: width * 0.04),
              _buildTextField(width, _descriptionController, 'Description', Icons.description, maxLines: 3),
              SizedBox(height: width * 0.04),
              _buildSectionTitle(width, 'Timeline'),
              SizedBox(height: width * 0.03),
              _buildDateField(width, 'Start Date', _startDate, () => _pickDate(true)),
              // SizedBox(height: width * 0.04),
              // _buildDateField(width, 'End Date', _endDate, () => _pickDate(false)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(double width, String title) {
    return FadeTransition(
      opacity: _animation,
      child: Text(
        title,
        style: TextStyle(
          fontSize: width * 0.045,
          fontWeight: FontWeight.bold,
          color: kTravailFuteMainColor,
          shadows: [
            Shadow(
              color: Colors.black12,
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(double width, TextEditingController controller, String label, IconData icon, {int maxLines = 1}) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(color: Colors.grey[600]),
            prefixIcon: Icon(icon, color: kTravailFuteMainColor),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: width * 0.04, horizontal: width * 0.04),
          ),
        ),
      ),
    );
  }

  Widget _buildDateField(double width, String label, DateTime? date, VoidCallback onTap) {
    return FadeTransition(
      opacity: _animation,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(width * 0.04),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today, color: kTravailFuteMainColor, size: width * 0.05),
              SizedBox(width: width * 0.03),
              Text(
                date != null ? DateFormat('yyyy MMM dd  ').format(date) : label,
                style: TextStyle(
                  fontSize: width * 0.04,
                  color: date != null ? Colors.black87 : Colors.grey[600],
                  fontWeight: date != null ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay(double width) {
    return Container(
      color: Colors.black.withOpacity(0.4),
      child: Center(
        child: Container(
          padding: EdgeInsets.all(width * 0.05),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(kTravailFuteMainColor),
            strokeWidth: 4,
          ),
        ),
      ),
    );
  }

  Widget _buildFAB(double width) {
    return FloatingActionButton(
      onPressed: _submitProject,
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [kTravailFuteMainColor, kTravailFuteSecondaryColor],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: kTravailFuteMainColor.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: EdgeInsets.all(width * 0.04),
        child: ScaleTransition(
          scale: _animation,
          child: Icon(Icons.check, size: width * 0.07, color: kWhiteColor),
        ),
      ),
    );
  }
}