class EssayGradingCriteria {
  final double keywordWeight;
  final double lengthWeight;
  final double coherenceWeight;
  final int minLength;
  final int maxLength;
  final List<String> keywords;

  EssayGradingCriteria({
    required this.keywordWeight,
    required this.lengthWeight,
    required this.coherenceWeight,
    required this.minLength,
    required this.maxLength,
    required this.keywords,
  });

  factory EssayGradingCriteria.defaultCriteria(List<String> keywords) {
    return EssayGradingCriteria(
      keywordWeight: 0.5,
      lengthWeight: 0.2,
      coherenceWeight: 0.3,
      minLength: 50,
      maxLength: 500,
      keywords: keywords,
    );
  }
}

class EssayGradingResult {
  final double totalScore; // 0-1
  final double keywordScore; // 0-1
  final double lengthScore; // 0-1
  final double coherenceScore; // 0-1
  final String feedback;
  final List<String> strengths;
  final List<String> improvements;

  EssayGradingResult({
    required this.totalScore,
    required this.keywordScore,
    required this.lengthScore,
    required this.coherenceScore,
    required this.feedback,
    required this.strengths,
    required this.improvements,
  });
}

class AiGradingService {
  // Mock AI grading service for essays
  Future<EssayGradingResult> gradeEssay(
    String essayText,
    EssayGradingCriteria criteria,
  ) async {
    // Simulate AI processing delay
    await Future.delayed(const Duration(seconds: 2));

    // Keyword matching analysis
    final keywordScore = _calculateKeywordScore(essayText, criteria.keywords);

    // Length analysis
    final lengthScore = _calculateLengthScore(essayText.length, criteria.minLength, criteria.maxLength);

    // Coherence analysis (mock)
    final coherenceScore = _calculateCoherenceScore(essayText);

    // Calculate weighted total score
    final totalScore = (keywordScore * criteria.keywordWeight) +
                      (lengthScore * criteria.lengthWeight) +
                      (coherenceScore * criteria.coherenceWeight);

    // Generate feedback
    final feedback = _generateFeedback(keywordScore, lengthScore, coherenceScore, essayText.length, criteria);
    final strengths = _identifyStrengths(keywordScore, lengthScore, coherenceScore, essayText.length, criteria);
    final improvements = _identifyImprovements(keywordScore, lengthScore, coherenceScore, essayText.length, criteria);

    return EssayGradingResult(
      totalScore: totalScore.clamp(0.0, 1.0),
      keywordScore: keywordScore,
      lengthScore: lengthScore,
      coherenceScore: coherenceScore,
      feedback: feedback,
      strengths: strengths,
      improvements: improvements,
    );
  }

  double _calculateKeywordScore(String text, List<String> keywords) {
    if (keywords.isEmpty) return 0.0;

    final lowerText = text.toLowerCase();
    int matchedKeywords = 0;

    for (final keyword in keywords) {
      if (lowerText.contains(keyword.toLowerCase())) {
        matchedKeywords++;
      }
    }

    // Bonus for using more keywords
    final baseScore = matchedKeywords / keywords.length;
    final bonus = matchedKeywords > keywords.length * 0.7 ? 0.1 : 0.0;

    return (baseScore + bonus).clamp(0.0, 1.0);
  }

  double _calculateLengthScore(int actualLength, int minLength, int maxLength) {
    if (actualLength < minLength) {
      // Too short - score based on how close to minimum
      return (actualLength / minLength).clamp(0.0, 1.0);
    } else if (actualLength > maxLength) {
      // Too long - penalty but not zero
      return 0.8 - ((actualLength - maxLength) / maxLength * 0.3).clamp(0.0, 0.5);
    } else {
      // Within range - perfect score
      return 1.0;
    }
  }

  double _calculateCoherenceScore(String text) {
    // Mock coherence analysis based on sentence structure and transitions
    final sentences = text.split(RegExp(r'[.!?]+')).where((s) => s.trim().isNotEmpty).length;
    final words = text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;

    if (sentences == 0 || words == 0) return 0.0;

    final avgWordsPerSentence = words / sentences;

    // Ideal range: 10-20 words per sentence
    if (avgWordsPerSentence >= 10 && avgWordsPerSentence <= 20) {
      return 0.9;
    } else if (avgWordsPerSentence >= 5 && avgWordsPerSentence <= 25) {
      return 0.7;
    } else {
      return 0.4;
    }
  }

  String _generateFeedback(double keywordScore, double lengthScore, double coherenceScore, int length, EssayGradingCriteria criteria) {
    final feedback = StringBuffer();

    if (keywordScore >= 0.8) {
      feedback.writeln('Excellent use of key concepts and terminology.');
    } else if (keywordScore >= 0.6) {
      feedback.writeln('Good coverage of key concepts, but could include more specific terms.');
    } else {
      feedback.writeln('Limited use of key concepts. Consider incorporating more relevant terminology.');
    }

    if (lengthScore >= 0.9) {
      feedback.writeln('Appropriate length for the response.');
    } else if (length < criteria.minLength) {
      feedback.writeln('Response is too brief. Aim for at least ${criteria.minLength} characters.');
    } else if (length > criteria.maxLength) {
      feedback.writeln('Response is too lengthy. Try to be more concise while covering key points.');
    }

    if (coherenceScore >= 0.8) {
      feedback.writeln('Well-structured and coherent response.');
    } else if (coherenceScore >= 0.6) {
      feedback.writeln('Response has decent structure but could be more organized.');
    } else {
      feedback.writeln('Response lacks clear structure. Consider organizing thoughts into paragraphs.');
    }

    return feedback.toString().trim();
  }

  List<String> _identifyStrengths(double keywordScore, double lengthScore, double coherenceScore, int length, EssayGradingCriteria criteria) {
    final strengths = <String>[];

    if (keywordScore >= 0.8) {
      strengths.add('Strong understanding of key concepts');
    }
    if (lengthScore >= 0.9) {
      strengths.add('Appropriate response length');
    }
    if (coherenceScore >= 0.8) {
      strengths.add('Clear and well-organized writing');
    }
    if (keywordScore >= 0.6 && lengthScore >= 0.6 && coherenceScore >= 0.6) {
      strengths.add('Balanced approach covering multiple aspects');
    }

    return strengths;
  }

  List<String> _identifyImprovements(double keywordScore, double lengthScore, double coherenceScore, int length, EssayGradingCriteria criteria) {
    final improvements = <String>[];

    if (keywordScore < 0.6) {
      improvements.add('Include more specific terminology and key concepts');
    }
    if (lengthScore < 0.6) {
      if (length < criteria.minLength) {
        improvements.add('Expand on your ideas with more detail');
      } else {
        improvements.add('Focus on being more concise while maintaining key points');
      }
    }
    if (coherenceScore < 0.6) {
      improvements.add('Improve organization with clear paragraphs and transitions');
    }
    if (keywordScore < 0.8 || lengthScore < 0.8 || coherenceScore < 0.8) {
      improvements.add('Review the question requirements and ensure all aspects are addressed');
    }

    return improvements;
  }
}