class CareerRecommendation {
  final String id;
  final String careerName;
  final String description;
  final double matchPercentage;
  final List<String> requiredSkills;
  final List<String> recommendedSubjects;
  final String careerCategory;
  final String salaryRange;
  final String jobOutlook;
  final DateTime generatedAt;

  CareerRecommendation({
    required this.id,
    required this.careerName,
    required this.description,
    required this.matchPercentage,
    required this.requiredSkills,
    required this.recommendedSubjects,
    required this.careerCategory,
    required this.salaryRange,
    required this.jobOutlook,
    required this.generatedAt,
  });

  factory CareerRecommendation.fromJson(Map<String, dynamic> json) {
    return CareerRecommendation(
      id: json['id'],
      careerName: json['careerName'],
      description: json['description'],
      matchPercentage: (json['matchPercentage'] ?? 0).toDouble(),
      requiredSkills: List<String>.from(json['requiredSkills'] ?? []),
      recommendedSubjects: List<String>.from(json['recommendedSubjects'] ?? []),
      careerCategory: json['careerCategory'] ?? '',
      salaryRange: json['salaryRange'] ?? '',
      jobOutlook: json['jobOutlook'] ?? '',
      generatedAt: DateTime.parse(json['generatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'careerName': careerName,
      'description': description,
      'matchPercentage': matchPercentage,
      'requiredSkills': requiredSkills,
      'recommendedSubjects': recommendedSubjects,
      'careerCategory': careerCategory,
      'salaryRange': salaryRange,
      'jobOutlook': jobOutlook,
      'generatedAt': generatedAt.toIso8601String(),
    };
  }

  CareerRecommendation copyWith({
    String? id,
    String? careerName,
    String? description,
    double? matchPercentage,
    List<String>? requiredSkills,
    List<String>? recommendedSubjects,
    String? careerCategory,
    String? salaryRange,
    String? jobOutlook,
    DateTime? generatedAt,
  }) {
    return CareerRecommendation(
      id: id ?? this.id,
      careerName: careerName ?? this.careerName,
      description: description ?? this.description,
      matchPercentage: matchPercentage ?? this.matchPercentage,
      requiredSkills: requiredSkills ?? this.requiredSkills,
      recommendedSubjects: recommendedSubjects ?? this.recommendedSubjects,
      careerCategory: careerCategory ?? this.careerCategory,
      salaryRange: salaryRange ?? this.salaryRange,
      jobOutlook: jobOutlook ?? this.jobOutlook,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }
}