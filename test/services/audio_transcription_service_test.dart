import 'package:flutter_test/flutter_test.dart';
import 'package:pocketllm_lite/services/audio_transcription_service.dart';

void main() {
  group('AudioTranscriptionService Tests', () {
    final service = AudioTranscriptionService();

    test('transcribes audio file and exports markdown and SRT formats', () async {
      final res = await service.transcribeAudioFile(
        filePath: '/test/sample.mp3',
        fileName: 'meeting.mp3',
      );

      expect(res.fileName, equals('meeting.mp3'));
      expect(res.segments.isNotEmpty, isTrue);
      expect(res.extractedTasks.length, equals(2));

      final md = res.exportToMarkdown();
      expect(md.contains('# Audio Transcript: meeting.mp3'), isTrue);

      final srt = res.exportToSrt();
      expect(srt.contains('00:00:00,000 --> 00:00:04,500'), isTrue);
    });
  });
}
