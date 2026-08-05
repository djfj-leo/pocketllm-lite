// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override String get appTitle => 'PocketLLM Lite';
  @override String get chatSettings => '聊天设置';
  @override String get enableTools => '本地 Agent 工具';
  @override String get enableRag => '知识库 (RAG)';
  @override String get temperature => '温度';
  @override String get topP => 'Top P';
  @override String get systemPrompt => '系统提示词';
  @override String get applyChanges => '应用更改';
  @override String get cancel => '取消';
  @override String get deleteMessage => '删除消息';
  @override String get clearChat => '清空对话';
  @override String get settings => '设置';
  @override String get benchmarks => '性能测试';
  @override String get history => '历史记录';
  @override String get chat => '聊天';
}
