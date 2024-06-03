import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // Importuj odpowiednią bibliotekę

class AssessmentService {
  Future<Map<String, dynamic>?> assessPronunciation(Uint8List audioData, String text) async {
    final uri = Uri.parse('https://localhost:7244/api/PronunciationAssessment/assessment');

    var request = http.MultipartRequest('POST', uri)
      ..fields['ReferenceText'] = text
      ..files.add(http.MultipartFile.fromBytes(
        'AudioFile',
        audioData,
        filename: 'audio.wav',
        contentType: MediaType('audio', 'wav'),
      ));

    // Dodanie nagłówków
    request.headers['Accept'] = 'application/json';

    print('Sending request to: $uri');
    print('Headers: ${request.headers}');
    print('Fields: ${request.fields}');
    print('Files: ${request.files.map((file) => file.filename).toList()}');
    print('Audio data length: ${audioData.length}');

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Failed to assess pronunciation: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error during pronunciation assessment: $e');
      return null;
    }
  }
}
