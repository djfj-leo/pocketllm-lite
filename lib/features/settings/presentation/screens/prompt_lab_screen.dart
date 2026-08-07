import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/m3_app_bar.dart';
import '../../../../services/model_profile_registry.dart';

class PromptLabScreen extends ConsumerStatefulWidget {
  const PromptLabScreen({super.key});

  @override
  ConsumerState<PromptLabScreen> createState() => _PromptLabScreenState();
}

class _PromptLabScreenState extends ConsumerState<PromptLabScreen> {
  final _systemPromptController = TextEditingController(
    text: 'You are an expert software engineer. Explain {{topic}} clearly.',
  );
  final _variableController = TextEditingController(text: 'Recursion in Dart');

  double _temperature = 0.6;
  double _topP = 0.95;
  String? _outputResult;
  bool _isRunning = false;

  void _runExperiment() {
    setState(() => _isRunning = true);
    final prompt = _systemPromptController.text.replaceAll('{{topic}}', _variableController.text.trim());

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        _outputResult = 'PROMPT LAB RUN:\n\nSystem Instruction: "$prompt"\nTemperature: $_temperature, TopP: $_topP\n\nResult: Recursion in Dart is a technique where a function calls itself until a base termination condition is satisfied.';
        _isRunning = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final registry = ModelProfileRegistry();
    final profile = registry.getProfileForModel('qwen3-1.7b');

    return Scaffold(
      appBar: const M3AppBar(
        title: '提示词实验室',
        subtitle: '参数调优与模板测试',
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card.filled(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '当前模型配置默认值',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(label: Text('Family: ${profile.modelFamily}')),
                      Chip(label: Text('Chat Template: ${profile.chatTemplate}')),
                      Chip(label: Text('Context: ${profile.contextLength}')),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _systemPromptController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: '系统提示词模板',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _variableController,
            decoration: const InputDecoration(
              labelText: '变量值',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Text('Temperature: ${_temperature.toStringAsFixed(2)}'),
          Slider(
            value: _temperature,
            min: 0.0,
            max: 1.5,
            divisions: 15,
            onChanged: (val) => setState(() => _temperature = val),
          ),
          Text('Top P: ${_topP.toStringAsFixed(2)}'),
          Slider(
            value: _topP,
            min: 0.1,
            max: 1.0,
            divisions: 18,
            onChanged: (val) => setState(() => _topP = val),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Run Benchmark Experiment'),
            onPressed: _isRunning ? null : _runExperiment,
          ),
          if (_isRunning) ...[
            const SizedBox(height: 16),
            const LinearProgressIndicator(),
          ],
          if (_outputResult != null) ...[
            const SizedBox(height: 24),
            Text(
              'Experiment Output',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card.outlined(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _outputResult!,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
