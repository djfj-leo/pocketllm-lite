import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/m3_app_bar.dart';
import '../../../../core/widgets/m3_empty_state.dart';
import '../../../../services/audio_transcription_service.dart';

class AudioTranscriptionScreen extends ConsumerStatefulWidget {
  const AudioTranscriptionScreen({super.key});

  @override
  ConsumerState<AudioTranscriptionScreen> createState() => _AudioTranscriptionScreenState();
}

class _AudioTranscriptionScreenState extends ConsumerState<AudioTranscriptionScreen> {
  AudioTranscriptionResult? _currentResult;
  bool _isProcessing = false;

  Future<void> _processSampleAudio() async {
    setState(() => _isProcessing = true);
    final result = await AudioTranscriptionService().transcribeAudioFile(
      filePath: '/sample/project_review.mp3',
      fileName: 'project_architecture_review.mp3',
    );
    setState(() {
      _currentResult = result;
      _isProcessing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: M3AppBar(
        title: '音频工作区',
        subtitle: '离线语音转录与摘要',
        actions: [
          if (_currentResult != null)
            IconButton(
              icon: const Icon(Icons.share_rounded),
              onPressed: () {
                final md = _currentResult!.exportToMarkdown();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('已导出文本 (${md.length}字符) 到剪贴板')),
                );
              },
            ),
        ],
      ),
      body: _isProcessing
          ? const Center(child: CircularProgressIndicator())
          : _currentResult == null
              ? M3EmptyState(
                  icon: Icons.graphic_eq_rounded,
                  title: '无活跃音频会话',
                  description: 'Import or record an audio file to view timestamped transcriptions, meeting summaries, and extracted tasks.',
                  action: FilledButton.icon(
                    icon: const Icon(Icons.mic_rounded),
                    label: const Text('开始音频会话'),
                    onPressed: _processSampleAudio,
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card.filled(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.audio_file_rounded, color: theme.colorScheme.primary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _currentResult!.fileName,
                                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Chip(label: Text('${_currentResult!.durationSeconds}秒')),
                              ],
                            ),
                            const Divider(height: 24),
                            Text(
                              'Meeting Summary',
                              style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary),
                            ),
                            const SizedBox(height: 4),
                            Text(_currentResult!.summary),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Action Items & Tasks',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ..._currentResult!.extractedTasks.map(
                      (task) => Card.outlined(
                        child: ListTile(
                          leading: Icon(Icons.check_circle_outline_rounded, color: theme.colorScheme.tertiary),
                          title: Text(task),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Timestamped Transcript',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ..._currentResult!.segments.map(
                      (seg) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: theme.colorScheme.primaryContainer,
                            child: Text(
                              seg.speaker.substring(0, 1),
                              style: TextStyle(color: theme.colorScheme.onPrimaryContainer),
                            ),
                          ),
                          title: Text(seg.text),
                          subtitle: Text('[${seg.formatTimestamp()}] ${seg.speaker}'),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
