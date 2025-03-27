import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:travail_fute/constants.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart' as dt_picker;
import 'package:travail_fute/screens/project_detail_screen.dart';
import 'package:travail_fute/services/project_service.dart';

class CreateProjectScreen extends StatefulWidget {
  final dynamic user;

  const CreateProjectScreen({super.key, required this.user});

  @override
  State<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  bool isLoading = false;
  final ProjectService projectService = ProjectService();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _addressController.dispose();
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
    if (_nameController.text.isEmpty || _startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs obligatoires')),
      );
      return;
    }

    setState(() => isLoading = true);
    final projectData = {
      'name': _nameController.text,
      'client': widget.user['id'],
      'description': _descriptionController.text,
      'address': _addressController.text,
      'start_date': _startDate?.toIso8601String(),
      'end_date': _endDate?.toIso8601String(), // Optional field
    };

    try {
      await projectService.createProject(context, projectData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chantier créé avec succès')),
      );
      Navigator.pop(context, true);
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la création du chantier: $e')),
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
      body: Container(
        decoration: BoxDecoration(
          // gradient: LinearGradient(
          //   begin: Alignment.topCenter,
          //   end: Alignment.bottomCenter,
          //   colors: [kTravailFuteMainColor.withOpacity(0.05), kWhiteColor],
          // ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(width),
                    SizedBox(height: width * 0.04),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                      child: _buildForm(width),
                    ),
                    SizedBox(height: width * 0.1), // Space for FAB
                  ],
                ),
              ),
              if (isLoading) _buildLoadingOverlay(width),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFAB(width),
    );
  }

  Widget _buildHeader(double width) {
    return Container(
      padding: EdgeInsets.all(width * 0.04),
      decoration: BoxDecoration(
        color: kWhiteColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: kTravailFuteMainColor, size: width * 0.06),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Row(
                children: [
                  SizedBox(
                    height: 30,
                    child: Image.asset('assets/images/splash.png'),
                  ),
                  SizedBox(width: width * 0.03),
                  Text(
                    'Nouveau Chantier',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: width * 0.05,
                      fontWeight: FontWeight.w700,
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

  Widget _buildForm(double width) {
    final phoneNumber = widget.user['phone_number']?.toString().replaceFirst('+32', '0') ?? 'N/A';
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: kWhiteColor,
      child: Padding(
        padding: EdgeInsets.all(width * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(width, 'Chantier pour $phoneNumber'),
            SizedBox(height: width * 0.04),
            _buildTextField(width, _nameController, 'Nom du chantier', Icons.work),
            SizedBox(height: width * 0.04),
            _buildTextField(width, _descriptionController, 'Description', Icons.description, maxLines: 3),
            SizedBox(height: width * 0.06),
            _buildTextField(width, _addressController, 'Addresse', Icons.location_city,),
            SizedBox(height: width * 0.06),
            _buildSectionTitle(width, 'Date de début'),
            SizedBox(height: width * 0.03),
            _buildDateField(width, 'Date de début', _startDate, () => _pickDate(true)),
            // SizedBox(height: width * 0.04),
            // _buildDateField(width, 'Date de fin (optionnel)', _endDate, () => _pickDate(false)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(double width, String title) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: width * 0.045,
          fontWeight: FontWeight.w600,
          color: kTravailFuteMainColor,
        ),
      ),
    );
  }

  Widget _buildTextField(double width, TextEditingController controller, String label, IconData icon, {int maxLines = 1}) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(color: Colors.grey[600], fontFamily: 'Poppins'),
            prefixIcon: Icon(icon, color: kTravailFuteMainColor),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: width * 0.04, horizontal: width * 0.04),
          ),
        ),
      ),
    );
  }

  Widget _buildDateField(double width, String label, DateTime? date, VoidCallback onTap) {
    // Use the provided date or default to current date
    final displayDate = date ?? DateTime.now();
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(width * 0.04),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today, color: kTravailFuteMainColor, size: width * 0.05),
              SizedBox(width: width * 0.03),
              Text(
                DateFormat('d MMM yyyy', 'fr_FR').format(displayDate),
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: width * 0.04,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
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
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          padding: EdgeInsets.all(width * 0.05),
          decoration: BoxDecoration(
            color: kWhiteColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
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
              color: kTravailFuteMainColor.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: EdgeInsets.all(width * 0.04),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Icon(Icons.check, size: width * 0.07, color: kWhiteColor),
        ),
      ),
    );
  }
}