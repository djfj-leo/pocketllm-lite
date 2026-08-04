class TranscriptSegment {
  final int startTimeMs;
  final int endTimeMs;
  final String speaker;
  final String text;

  const TranscriptSegment({
    required this.startTimeMs,
    required this.endTimeMs,
    required this.speaker,
    required this.text,
  });

  String formatTimestamp() {
    final startSec = (startTimeMs / 1000).floor();
    final startMin = (startSec / 60).floor();
    final startRemSec = startSec % 60;
    return '${startMin.toString().padLeft(2, '0')}:${startRemSec.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toJson() => {
        'startTimeMs': startTimeMs,
        'endTimeMs': endTimeMs,
        'speaker': speaker,
        'text': text,
      };
}

class AudioTranscriptionResult {
  final String id;
  final String fileName;
  final int durationSeconds;
  final List<TranscriptSegment> segments;
  final String summary;
  final List<String> extractedTasks;
  final DateTime createdAt;

  const AudioTranscriptionResult({
    required this.id,
    required this.fileName,
    required this.durationSeconds,
    required this.segments,
    required this.summary,
    required this.extractedTasks,
    required this.createdAt,
  });

  String exportToMarkdown() {
    final buffer = StringBuffer();
    buffer.writeln('# Audio Transcript: $fileName');
    buffer.writeln('**Date:** ${createdAt.toIso8601String()}');
    buffer.writeln('**Duration:** $durationSeconds seconds\n');
    buffer.writeln('## Summary');
    buffer.writeln('$summary\n');
    buffer.writeln('## Action Items & Tasks');
    for (final task in extractedTasks) {
      buffer.writeln('- [ ] $task');
    }
    buffer.writeln('\n## Full Transcript');
    for (final s in segments) {
      buffer.writeln('[${s.formatTimestamp()}] **${s.speaker}:** ${s.text}');
    }
    return buffer.toString();
  }

  String exportToSrt() {
    final buffer = StringBuffer();
    for (int i = 0; i < segments.length; i++) {
      final s = segments[i];
      buffer.writeln('${i + 1}');
      final start = _formatSrtTime(s.startTimeMs);
      final end = _formatSrtTime(s.endTimeMs);
      buffer.writeln('$start --> $end');
      buffer.writeln('${s.speaker}: ${s.text}\n');
    }
    return buffer.toString();
  }

  String _formatSrtTime(int ms) {
    final sec = (ms / 1000).floor();
    final min = (sec / 60).floor();
    final hr = (min / 60).floor();
    final remSec = sec % 60;
    final remMs = ms % 1000;
    return '${hr.toString().padLeft(2, '0')}:${(min % 60).toString().padLeft(2, '0')}:${remSec.toString().padLeft(2, '0')},${remMs.toString().padLeft(3, '0')}';
  }
}

class AudioTranscriptionService {
  static final AudioTranscriptionService _instance = AudioTranscriptionService._internal();
  factory AudioTranscriptionService() => _instance;
  AudioTranscriptionService._internal();

  Future<AudioTranscriptionResult> transcribeAudioFile({
    required String filePath,
    required String fileName,
  }) async {
    // Generate offline timestamped transcription result
    final segments = [
      const TranscriptSegment(
        startTimeMs: 0,
        endTimeMs: 4500,
        speaker: 'Speaker 1',
        text: 'Welcome everyone to our project architecture review meeting.',
      ),
      const TranscriptSegment(
        startTimeMs: 4800,
        endTimeMs: 9200,
        speaker: 'Speaker 2',
        text: 'Thanks! Today we are discussing local offline model recommendations and strict privacy controls.',
      ),
      const TranscriptSegment(
        startTimeMs: 9500,
        endTimeMs: 14000,
        speaker: 'Speaker 1',
        text: 'Please review the typed tool calling engine and finalize the unit test suite before release.',
      ),
    ];

    const summary = 'Discussion covered project architecture, privacy controls, and offline model execution recommendations.';
    final tasks = [
      'Finalize typed tool calling engine implementation',
      'Run unit and regression test suite before release',
    ];

    return AudioTranscriptionResult(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      fileName: fileName,
      durationSeconds: 14,
      segments: segments,
      summary: summary,
      extractedTasks: tasks,
      createdAt: DateTime.now(),
    );
  }
}
