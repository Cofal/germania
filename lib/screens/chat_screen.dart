import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:typed_data';
import '../widgets/animated_icon_widget.dart';
import '../widgets/circle_button.dart';
import '../services/recording_service.dart';
import '../services/assessment_service.dart';
import 'dart:html' as html;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final FlutterTts _flutterTts = FlutterTts();
  final RecordingService _recordingService = RecordingService();
  final AssessmentService _assessmentService = AssessmentService();
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  final List<Map<String, dynamic>> _messages = [];
  bool _isSpeaking = false;
  bool _isRecording = false;
  Uint8List? _recordedData;
  String _transcribedText = '';

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  // Initialize permissions for microphone access
  Future<void> _initialize() async {
    final micPermission =
        await html.window.navigator.permissions?.query({'name': 'microphone'});
    if (micPermission != null && micPermission.state == 'granted') {
      print("Microphone permission granted");
    } else {
      print("Microphone permission denied");
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _controller.dispose();
    super.dispose();
  }

  // Send a text message
  void _sendMessage() {
    if (_controller.text.isEmpty) return;

    setState(() {
      _messages.add({
        'text': _controller.text,
        'isBot': false,
        'type': 'text',
      });
    });

    _controller.clear();
    _sendBotResponse('Response from bot');
  }

  // Send the recorded voice message and text for assessment
  Future<void> _sendVoiceMessage() async {
    if (_recordedData == null && _transcribedText.isEmpty) {
      print("No recorded data or transcribed text to send.");
      return;
    }

    // Call the pronunciation assessment API
    final response = await _assessmentService.assessPronunciation(
        _recordedData!, _transcribedText);

    if (response == null) {
      print("Pronunciation assessment failed.");
      return;
    }

    setState(() {
      if (_recordedData != null) {
        _messages.add({
          'text': 'Voice message sent',
          'isBot': false,
          'type': 'audio',
          'data': _recordedData,
        });
        print("Voice message added to messages list.");
      }

      if (_transcribedText.isNotEmpty) {
        _messages.add({
          'text': _transcribedText,
          'isBot': false,
          'type': 'text',
        });
        print("Transcribed text message added to messages list.");
      }

      _messages.add({
        'text': response['RecognizedText'],
        'isBot': true,
        'type': 'assessment',
        'assessment': response,
      });
      print("Assessment result added to messages list.");

      _recordedData = null; // Remove recording after sending
      _transcribedText = ''; // Clear transcribed text after sending
    });

    _sendBotResponse('Bot received your voice message');
  }

  // Handle bot response
  void _sendBotResponse(String response) async {
    setState(() {
      _messages.add({
        'text': response,
        'isBot': true,
        'type': 'text',
      });
      _isSpeaking = true;
    });

    await _flutterTts.speak(response);

    setState(() {
      _isSpeaking = false;
    });
  }

  // Start recording audio and transcription
  Future<void> _startRecording() async {
    if (!_isRecording) {
      await _recordingService.startRecording();
      bool available = await _speechToText.initialize();
      if (available) {
        _speechToText.listen(onResult: (result) {
          setState(() {
            _transcribedText = result.recognizedWords;
          });
        });
      }
      setState(() {
        _isRecording = true;
      });
      print("Recording and transcription started...");
    }
  }

  // Stop recording audio and transcription
  Future<void> _stopRecording() async {
    if (_isRecording) {
      _recordedData = await _recordingService.stopRecording();
      _speechToText.stop();
      setState(() {
        _isRecording = false;
      });
      print("Recording stopped, data size: ${_recordedData?.length}");
      print("Transcribed text: $_transcribedText");
    }
  }

  // Build the message widget based on its type
  Widget _buildMessage(Map<String, dynamic> message) {
    bool isBot = message['isBot'];
    String messageType = message['type'];

    return Align(
      alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: isBot ? Colors.grey[300] : Colors.blue[300],
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: messageType == 'text'
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isBot) AnimatedIconWidget(isSpeaking: _isSpeaking),
                  const SizedBox(width: 8.0),
                  Flexible(child: Text(message['text'])),
                ],
              )
            : messageType == 'audio'
                ? IconButton(
                    icon: const Icon(Icons.play_arrow),
                    onPressed: () => _recordingService.playAudio(message['data']),
                  )
                : messageType == 'assessment'
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(message['text']),
                          Text(
                              'Pronunciation Score: ${message['assessment']['PronunciationScore']}'),
                          // Add more graphical representation here
                        ],
                      )
                    : Container(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Germania'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessage(_messages[index]);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                  margin: const EdgeInsets.symmetric(vertical: 10.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6.0,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _transcribedText.isEmpty
                          ? 'Transcribed text will appear here...'
                          : _transcribedText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleButton(
                      icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                      color: Colors.red,
                      onPressed:
                          _isRecording ? _stopRecording : _startRecording,
                    ),
                    SizedBox(width: 16.0),
                    CircleButton(
                      icon: const Icon(Icons.play_arrow),
                      color: Colors.green,
                      onPressed: _recordedData != null
                          ? () => _recordingService.playAudio(_recordedData!)
                          : null,
                    ),
                    SizedBox(width: 16.0),
                    CircleButton(
                      icon: const Icon(Icons.send),
                      color: Colors.blue,
                      onPressed: _sendVoiceMessage,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
