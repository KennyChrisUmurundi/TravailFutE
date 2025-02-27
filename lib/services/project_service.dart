import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travail_fute/utils/provider.dart';
import 'package:http/http.dart' as http;

const String apiUrl = "https://tfte.azurewebsites.net/api/project";

class ProjectService{
  List<dynamic> projects = [];
  
  Future<List> fetchProjects(BuildContext context) async {
    try {
      final url = Uri.parse(apiUrl);
      final token = Provider.of<TokenProvider>(context, listen: false).token;
      final response = await http.get(
        url,
        headers: {'Authorization': 'Token $token'},
      );

      if (response.statusCode == 200) {
        projects = jsonDecode(response.body)['results'];
        return projects;
      } else {
        print(response.body);
        throw Exception('Failed to load projects');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
  Future<http.Response> createProject(BuildContext context, Map<String, dynamic> projectData) async {
    try {
      final url = Uri.parse("$apiUrl/");
      final token = Provider.of<TokenProvider>(context, listen: false).token;
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
        body: jsonEncode(projectData),
      );

      if (response.statusCode == 201) {
        return response;
      } else {
        print("Screen response ${response.body}");
        throw Exception('Failed to create project');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}