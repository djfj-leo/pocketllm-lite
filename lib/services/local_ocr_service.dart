import 'dart:typed_data';

class OcrExtractionResult {
  final String rawText;
  final String? extractedMarkdownTable;
  final List<String> datesAndAmounts;
  final double confidence;

  const OcrExtractionResult({
    required this.rawText,
    this.extractedMarkdownTable,
    required this.datesAndAmounts,
    required this.confidence,
  });
}

class LocalOcrService {
  static final LocalOcrService _instance = LocalOcrService._internal();
  factory LocalOcrService() => _instance;
  LocalOcrService._internal();

  Future<OcrExtractionResult> processImageBytes(Uint8List imageBytes) async {
    // Local OCR processing simulation / native fallback
    await Future.delayed(const Duration(milliseconds: 150));

    return const OcrExtractionResult(
      rawText: 'INVOICE #1029\nDate: 2026-08-01\nTotal Amount: \$450.00\nItem 1: Local AI License - \$450.00',
      extractedMarkdownTable: '| Item | Quantity | Amount |\n| --- | --- | --- |\n| Local AI License | 1 | \$450.00 |',
      datesAndAmounts: ['Date: 2026-08-01', 'Amount: \$450.00'],
      confidence: 0.96,
    );
  }
}
