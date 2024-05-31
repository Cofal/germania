import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:async';

class RecordingService {
  late html.MediaRecorder mediaRecorder;
  final List<html.Blob> chunks = [];

  Future<void> startRecording() async {
    final stream = await html.window.navigator.getUserMedia(audio: true);
    mediaRecorder = html.MediaRecorder(stream);

    chunks.clear(); // Clear previous recordings

    mediaRecorder.addEventListener('dataavailable', (html.Event event) {
      final dataEvent = event as html.BlobEvent;
      chunks.add(dataEvent.data!);
    });

    mediaRecorder.start();
  }

  Future<Uint8List> stopRecording() async {
    final completer = Completer<Uint8List>();

    mediaRecorder.addEventListener('stop', (html.Event event) async {
      final blob = html.Blob(chunks);
      final reader = html.FileReader();
      reader.readAsArrayBuffer(blob);
      reader.onLoadEnd.listen((_) {
        completer.complete(reader.result as Uint8List);
      });
    });

    mediaRecorder.stop();
    return completer.future;
  }

  void playAudio(Uint8List data) {
    final blob = html.Blob([data]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final audioElement = html.AudioElement(url)
      ..autoplay = true
      ..onEnded.listen((event) {
        html.Url.revokeObjectUrl(url);
        print("Audio playback finished.");
      });
    audioElement.play().then((_) {
      print("Audio playback started.");
    }).catchError((error) {
      print("Error during audio playback: $error");
    });
  }
}
