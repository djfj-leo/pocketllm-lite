import 'dart:math';
import 'local_memory_service.dart';

class MemorySearchResult {
  final UserMemoryEntry memory;
  final double score;
  final double embeddingSim;
  final double bm25Score;
  final double recencyScore;
  final String debugReason;

  const MemorySearchResult({
    required this.memory,
    required this.score,
    required this.embeddingSim,
    required this.bm25Score,
    required this.recencyScore,
    required this.debugReason,
  });
}

class HybridRetrievalService {
  static final HybridRetrievalService _instance = HybridRetrievalService._internal();
  factory HybridRetrievalService() => _instance;
  HybridRetrievalService._internal();

  double computeBm25(String query, String text) {
    final queryTerms = query.toLowerCase().split(RegExp(r'\s+'));
    final textTerms = text.toLowerCase().split(RegExp(r'\s+'));
    if (queryTerms.isEmpty || textTerms.isEmpty) return 0.0;

    int matches = 0;
    for (final term in queryTerms) {
      if (textTerms.contains(term)) matches++;
    }
    return (matches / queryTerms.length).clamp(0.0, 1.0);
  }

  double computeSimulatedEmbedding(String query, String text) {
    // Exact or partial string match approximation for dense vector score
    final q = query.toLowerCase();
    final t = text.toLowerCase();
    if (t.contains(q) || q.contains(t)) return 0.95;

    final stopWords = {'how', 'should', 'i', 'my', 'the', 'is', 'a', 'an', 'and', 'or', 'in', 'on', 'at', 'to', 'for', 'with'};
    final qWords = q.split(RegExp(r'\s+')).where((w) => !stopWords.contains(w) && w.length > 2).toList();
    if (qWords.isEmpty) return 0.05;

    int count = 0;
    for (final w in qWords) {
      if (t.contains(w)) count++;
    }
    return count > 0 ? (count / qWords.length).clamp(0.15, 0.95) : 0.05;
  }

  List<MemorySearchResult> retrieveMemories({
    required String userQuery,
    required List<UserMemoryEntry> candidateMemories,
    int topK = 5,
    double lambdaMMR = 0.7,
  }) {
    final List<MemorySearchResult> scored = [];
    final now = DateTime.now();

    for (final mem in candidateMemories) {
      if (!mem.enabled) continue;

      final embSim = computeSimulatedEmbedding(userQuery, mem.fact);
      final bm25 = computeBm25(userQuery, mem.fact);

      final daysOld = now.difference(mem.createdAt).inDays;
      final recency = max(0.0, 1.0 - (daysOld / 30.0));
      final importance = mem.confidence;
      final pinnedScore = mem.pinned ? 1.0 : 0.0;

      // Hybrid score: 0.45*emb + 0.25*bm25 + 0.15*recency + 0.10*importance + 0.05*pinned
      final finalScore = (0.45 * embSim) +
          (0.25 * bm25) +
          (0.15 * recency) +
          (0.10 * importance) +
          (0.05 * pinnedScore);

      scored.add(MemorySearchResult(
        memory: mem,
        score: finalScore,
        embeddingSim: embSim,
        bm25Score: bm25,
        recencyScore: recency,
        debugReason: 'Score: ${finalScore.toStringAsFixed(2)} (Emb: ${embSim.toStringAsFixed(2)}, BM25: ${bm25.toStringAsFixed(2)})',
      ));
    }

    scored.sort((a, b) => b.score.compareTo(a.score));

    // Maximum Marginal Relevance (MMR) deduplication
    final List<MemorySearchResult> selected = [];
    for (final candidate in scored) {
      if (selected.length >= topK) break;

      bool isTooSimilar = false;
      for (final existing in selected) {
        final similarity = computeSimulatedEmbedding(candidate.memory.fact, existing.memory.fact);
        if (similarity > 0.80) {
          isTooSimilar = true;
          break;
        }
      }

      if (!isTooSimilar) {
        selected.add(candidate);
        candidate.memory.lastUsedAt = DateTime.now();
      }
    }

    return selected;
  }
}
