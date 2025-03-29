import 'dart:convert';

class HazardReport {
  final String? id;
  final DateTime? createdAt;
  final String reporterName;
  final String reporterPosition;
  final String location;
  final DateTime reportDatetime;
  final String observationType;
  final String hazardDescription;
  final String suggestedAction;
  final String? imagePath;
  final String? status;
  final DateTime? updatedAt;
  final String? lsbNumber;
  final String? reporterSignature;

  // Field untuk validasi
  final String? validatedBy;
  final String? validationNotes;
  final DateTime? validatedAt;

  // Field untuk tindak lanjut
  final String? followUp;
  final String? followedUpBy;
  final DateTime? followedUpAt;

  // Field untuk penutupan laporan
  final String? closedBy;
  final String? closingNotes;
  final DateTime? closedAt;

  HazardReport({
    this.id,
    this.createdAt,
    required this.reporterName,
    required this.reporterPosition,
    required this.location,
    required this.reportDatetime,
    required this.observationType,
    required this.hazardDescription,
    required this.suggestedAction,
    this.imagePath,
    this.status = 'submitted',
    this.updatedAt,
    this.lsbNumber,
    this.reporterSignature,
    this.validatedBy,
    this.validationNotes,
    this.validatedAt,
    this.followUp,
    this.followedUpBy,
    this.followedUpAt,
    this.closedBy,
    this.closingNotes,
    this.closedAt,
  });

  factory HazardReport.fromJson(Map<String, dynamic> json) {
    return HazardReport(
      id: json['id']?.toString(),
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      reporterName: json['reporter_name'] ?? '',
      reporterPosition: json['reporter_position'] ?? '',
      location: json['location'] ?? '',
      reportDatetime:
          json['report_datetime'] != null
              ? DateTime.parse(json['report_datetime'])
              : DateTime.now(),
      observationType: json['observation_type'] ?? 'Unsafe Condition',
      hazardDescription: json['hazard_description'] ?? '',
      suggestedAction: json['suggested_action'] ?? '',
      imagePath: json['image_path'],
      status: json['status'] ?? 'submitted',
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
      lsbNumber: json['lsb_number'],
      reporterSignature: json['reporter_signature'],
      validatedBy: json['validated_by'],
      validationNotes: json['validation_notes'],
      validatedAt:
          json['validated_at'] != null
              ? DateTime.parse(json['validated_at'])
              : null,
      followUp: json['follow_up'],
      followedUpBy: json['followed_up_by'],
      followedUpAt:
          json['followed_up_at'] != null
              ? DateTime.parse(json['followed_up_at'])
              : null,
      closedBy: json['closed_by'],
      closingNotes: json['closing_notes'],
      closedAt:
          json['closed_at'] != null ? DateTime.parse(json['closed_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      'reporter_name': reporterName,
      'reporter_position': reporterPosition,
      'location': location,
      'report_datetime': reportDatetime.toIso8601String(),
      'observation_type': observationType,
      'hazard_description': hazardDescription,
      'suggested_action': suggestedAction,
      if (imagePath != null) 'image_path': imagePath,
      'status': status,
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      if (lsbNumber != null) 'lsb_number': lsbNumber,
      if (reporterSignature != null) 'reporter_signature': reporterSignature,
      'validated_by': validatedBy,
      'validation_notes': validationNotes,
      if (validatedAt != null) 'validated_at': validatedAt!.toIso8601String(),
      'follow_up': followUp,
      'followed_up_by': followedUpBy,
      if (followedUpAt != null)
        'followed_up_at': followedUpAt!.toIso8601String(),
      'closed_by': closedBy,
      'closing_notes': closingNotes,
      if (closedAt != null) 'closed_at': closedAt!.toIso8601String(),
    };
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
