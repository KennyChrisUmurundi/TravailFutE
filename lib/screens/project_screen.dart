import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travail_fute/constants.dart';
import 'package:travail_fute/screens/clients.dart';
// New screen for creation
import 'package:travail_fute/screens/project_detail_screen.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

import 'package:travail_fute/services/project_service.dart';
import 'package:travail_fute/utils/provider.dart';

class ProjectScreen extends StatefulWidget {
  const ProjectScreen({super.key});

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> with SingleTickerProviderStateMixin {
  List<dynamic> projects = [];
  bool isLoading = false;
  late AnimationController _controller;
  late Animation<double> _animation;
  final projectService = ProjectService();
  

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    fetchProjects();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> fetchProjects() async {
    setState(() => isLoading = true);
    projectService.fetchProjects(context).then((value) {
      setState(() {
        projects = value;
        isLoading = false;
      });
    }).catchError((error) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to load projects: $error'),
        backgroundColor: Colors.red,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [kTravailFuteMainColor.withOpacity(0.15), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  _buildHeader(size, width),
                  Expanded(child: _buildProjectList(size, width)),
                ],
              ),
              if (isLoading) _buildLoadingOverlay(width),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFAB(width),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildHeader(Size size, double width) {
    return Container(
      padding: EdgeInsets.all(width * 0.04),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kTravailFuteMainColor, kTravailFuteSecondaryColor],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(width * 0.02),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kWhiteColor.withOpacity(0.2),
              ),
              child: Icon(Icons.arrow_back, color: kWhiteColor, size: width * 0.06),
            ),
          ),
          SizedBox(width: width * 0.03),
          Expanded(
            child: FadeTransition(
              opacity: _animation,
              child: Text(
                'Projects',
                style: TextStyle(
                  fontSize: width * 0.05,
                  fontWeight: FontWeight.bold,
                  color: kWhiteColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectList(Size size, double width) {
    return projects.isEmpty
        ? _buildEmptyState(size, width)
        : ListView.builder(
            padding: EdgeInsets.all(width * 0.04),
            itemCount: projects.length,
            itemBuilder: (context, index) {
              return FadeTransition(
                opacity: _animation,
                child: _buildProjectCard(size, width, index),
              );
            },
          );
  }

  Widget _buildProjectCard(Size size, double width, int index) {
    final project = projects[index];
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProjectDetailScreen(project: project,
          ),
        ),
      ),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: width * 0.015),
        padding: EdgeInsets.all(width * 0.03),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              project['name'],
              style: TextStyle(
                fontSize: width * 0.045,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: width * 0.01),
            Text(
              'Client: ${project['client']}',
              style: TextStyle(
                fontSize: width * 0.035,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: width * 0.01),
            Row(
              children: [
                Text(
                  'Start: ${project['start_date']}',
                  style: TextStyle(
                    fontSize: width * 0.035,
                    color: kTravailFuteMainColor,
                  ),
                ),
                SizedBox(width: width * 0.03),
                Text(
                  'End: ${project['end_date']}',
                  style: TextStyle(
                    fontSize: width * 0.035,
                    color: kTravailFuteMainColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(Size size, double width) {
    return Center(
      child: ScaleTransition(
        scale: _animation,
        child: Container(
          padding: EdgeInsets.all(width * 0.06),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.construction,
                size: width * 0.15,
                color: Colors.grey[400],
              ),
              SizedBox(height: width * 0.04),
              Text(
                'No Projects',
                style: TextStyle(
                  fontSize: width * 0.05,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: width * 0.02),
              Text(
                'Ajoutez un nouveau projet pour commencer !',
                style: TextStyle(
                  fontSize: width * 0.04,
                  color: Colors.grey[500],
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
      color: Colors.black.withOpacity(0.3),
      child: Center(
        child: Container(
          padding: EdgeInsets.all(width * 0.04),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(kTravailFuteMainColor),
          ),
        ),
      ),
    );
  }

  Widget _buildFAB(double width) {
    final token = Provider.of<TokenProvider>(context, listen: false).token;
    return FloatingActionButton(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) =>  ClientsList(deviceToken: token)),
      ),
      backgroundColor: kTravailFuteMainColor,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ScaleTransition(
        scale: _animation,
        child: const Icon(Icons.add, size: 30, color: Colors.white),
      ),
    );
  }
}