import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travail_fute/utils/func.dart';
import 'package:travail_fute/utils/provider.dart';
import 'package:http/http.dart' as http;

const String apiUrl = "https://tfte.azurewebsites.net/api/project";

class ProjectService{
  List<dynamic> projects = [];
  
  Future<List> fetchProjects(BuildContext context) async {
    try {
      final url = Uri.parse(apiUrl + "/projects/");
      final token = Provider.of<TokenProvider>(context, listen: false).token;
      final response = await http.get(
        url,
        headers: {'Authorization': 'Token $token'},
      );
      print("This is the resp ${response.body}");
      checkInvalidTokenOrUser(context, response);
      if (response.statusCode == 200) {
        projects = jsonDecode(response.body)['results'];
        print("Projects: $projects");
        return projects;
      } else {
        throw Exception('Failed to load projects');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List> fetchProjectsByClient(BuildContext context, int clientId) async {
    try {
      final url = Uri.parse("$apiUrl/projects/by-client/$clientId");
      final token = Provider.of<TokenProvider>(context, listen: false).token;
      final response = await http.get(
        url,
        headers: {'Authorization': 'Token $token'},
      );
      print("This is the resp one${response.body}");
      checkInvalidTokenOrUser(context, response);
      if (response.statusCode == 200) {
        projects = jsonDecode(response.body);
        print("Projects by client: $projects");
        return projects;
      } else {
        throw Exception('Failed to load projects by client');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
  Future<http.Response> createProject(BuildContext context, Map<String, dynamic> projectData) async {
    try {
      final url = Uri.parse("$apiUrl/projects/");
      final token = Provider.of<TokenProvider>(context, listen: false).token;
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
        body: jsonEncode(projectData),
      );
      checkInvalidTokenOrUser(context, response);
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
  Future<http.Response> updateProject(BuildContext context,  String projectId, Map<String, dynamic> projectData) async {
    try {
      final url = Uri.parse("$apiUrl/${projectId}/");
      final token = Provider.of<TokenProvider>(context, listen: false).token;
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
        body: jsonEncode(projectData),
      );
      
      checkInvalidTokenOrUser(context, response);
      if (response.statusCode == 200) {
        return response;
      } else {
        print("Screen response ${response.body}");
        throw Exception('Failed to update project');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<http.Response> addComment(BuildContext context, String projectId, String comment) async{
    print("check project data $projectId");

    try {
      final url = Uri.parse("$apiUrl/project-comments/");
      final token = Provider.of<TokenProvider>(context, listen: false).token;
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
        body: jsonEncode({'content': comment,'project':projectId}),
      );
      if (kDebugMode) {
        print("check ${response.body}");
      }
      return response;
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<String> addImage(BuildContext context, String projectId, String imagePath) async {
    try {
      final url = Uri.parse("$apiUrl/project-images/");
      final token = Provider.of<TokenProvider>(context, listen: false).token;
      final request = http.MultipartRequest('POST', url)
        ..headers['Authorization'] = 'Token $token'
        ..fields['project'] = projectId
        ..files.add(await http.MultipartFile.fromPath('image', imagePath));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      checkInvalidTokenOrUser(context, response);
      print("Screen response ${response.body}");
      if (response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);
        return responseBody['image'];
      } else {
        print("Screen response ${response.body}");
        throw Exception('Failed to add image');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}