import 'dart:convert';
import 'package:http/http.dart' as http;
import 'image_model.dart';

class ApiService {
  final String _baseUrl = 'https://api.unsplash.com/photos/';
  final String _accessKey = 'c6d5M3FEgEcOlGE_LFg-8S0rhYXN5OJU2OBetwu6kHc'; // Replace with your actual Unsplash API access key
  final String _searchUrl = 'https://api.unsplash.com/search/photos/';

  Future<List<ImageModel>> fetchImages({int page = 1, int perPage = 10}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl?page=$page&per_page=$perPage&client_id=$_accessKey'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body);
      print(' Responses: ${jsonResponse}');
      return jsonResponse.map((image) => ImageModel.fromJson(image)).toList();
    } else {
      throw Exception('Failed to load images');
    }
  }

  // Search images by query, with pagination

  Future<List<ImageModel>> searchImages(String query, {int page = 1, int perPage = 10}) async {
    final response = await http.get(Uri.parse('$_searchUrl?query=$query&page=$page&per_page=$perPage&client_id=$_accessKey'));

    if (response.statusCode == 200) {

      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      if (jsonResponse.containsKey('results') && jsonResponse['results'] is List) {
        final List<dynamic> results = jsonResponse['results'];
        return results.map((image) => ImageModel.fromJson(image as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Invalid response structure: "results" key is missing or is not a list');
      }
    } else {
      throw Exception('Failed to search images');
    }
  }

}
