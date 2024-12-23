// lib/services/clothing_classifier_service.dart

import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http_parser/http_parser.dart';

class ClothingClassifierService {
  static const String baseUrl = 'http://localhost:8000';

  static Future<Map<String, dynamic>> classifyImage(Uint8List imageBytes) async {
    try {
      // Préparer la requête multipart
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/predict'));
      
       // Ajout du type MIME et meilleure gestion du nom de fichier
      var multipartFile = http.MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename: 'image.jpg',
        contentType: MediaType('image', 'jpeg'), // Ajout du type MIME
      );
      
      request.files.add(multipartFile);

      // Afficher plus de détails pour le débogage
      print('Sending request to API...');
      print('Image size: ${imageBytes.length} bytes');

      // Envoyer la requête
      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        Map<String, dynamic> result = json.decode(responseData);
        return {
          'category': result['predicted_class'],
          'confidence': result['confidence'],
        };
      } else {
        print('Error: ${response.statusCode}');
        print('Response: $responseData');
        throw Exception('Failed to classify image');
      }
    } catch (e) {
      print('Classification error: $e');
      throw Exception('Failed to communicate with the server');
    }
  }
}