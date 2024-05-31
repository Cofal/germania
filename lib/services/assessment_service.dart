import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AssessmentService {
  Future<Map<String, dynamic>?> assessPronunciation(
      Uint8List audioData, String text) async {
    final uri = Uri.parse(
        'https://localhost:7244/api/PronunciationAssessment/assessment'); // Update URL
    final request = http.MultipartRequest('POST', uri)
      ..fields['ReferenceText'] = text
      ..files.add(http.MultipartFile.fromBytes('AudioFile', audioData,
          filename: 'audio.wav'));

    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        return json.decode(responseBody);
      } else {
        final responseBody = await response.stream.bytesToString();
        print('Failed to assess pronunciation: ${response.statusCode}');
        print('Response body: $responseBody');
        return null;
      }
    } catch (e) {
      print('Error during pronunciation assessment: $e');
      return null;
    }
  }
}
