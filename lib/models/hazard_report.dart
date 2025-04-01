import 'dart:convert';
import 'package:flutter/material.dart';

class HazardReport {
  final String? id;
  final String? reporterName;
  final String? reporterPosition;
  final String? reporterSignature;
  final DateTime? reportDatetime;
  final String? location;
  final String? observationType;
  final String? hazardDescription;
  final String? suggestedAction;
  final String? imagePath;
  final String? status;
  final String? lsbNumber;
  final DateTime? createdAt;
  final DateTime? updatedAt;

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

  // --- Field Workflow Tambahan ---
  final String? assignedToUserId; // ID Pengguna Supabase Auth?
  final String? assignedToName;   // Nama penanggung jawab
  final String? priority;         // 'Rendah', 'Sedang', 'Tinggi'
  final DateTime? dueDate;        // Batas waktu penyelesaian
  final String? validationStatus; // 'Pending', 'Valid', 'Invalid'
  final List<Map<String, dynamic>>? followUpActions; // Riwayat tindak lanjut

  // Field untuk koreksi tata bahasa dan typo
  final bool? correctionDetected;
  final String? correctionReport;

  // Metadata untuk menyimpan informasi tambahan
  final Map<String, dynamic>? metadata;

  HazardReport({
    this.id,
    this.reporterName,
    this.reporterPosition,
    this.reporterSignature,
    this.reportDatetime,
    this.location,
    this.observationType = 'Unsafe Condition',
    this.hazardDescription,
    this.suggestedAction,
    this.imagePath,
    this.status = 'submitted',
    this.lsbNumber,
    this.createdAt,
    this.updatedAt,
    this.validatedBy,
    this.validationNotes,
    this.validatedAt,
    this.followUp,
    this.followedUpBy,
    this.followedUpAt,
    this.closedBy,
    this.closingNotes,
    this.closedAt,
    // Workflow
    this.assignedToUserId,
    this.assignedToName,
    this.priority,
    this.dueDate,
    this.validationStatus,
    this.followUpActions,
    // Koreksi AI
    this.correctionDetected,
    this.correctionReport,
    this.metadata,
  });

  factory HazardReport.fromJson(Map<String, dynamic> json) {
    // Helper untuk parse list of map dari JSON
    List<Map<String, dynamic>>? parseFollowUpActions(dynamic data) {
      if (data is List) {
        return data.map((item) => Map<String, dynamic>.from(item)).toList();
      }
      return null;
    }

    return HazardReport(
      id: json['id'],
      reporterName: json['reporter_name'],
      reporterPosition: json['reporter_position'],
      reporterSignature: json['reporter_signature'],
      reportDatetime:
          json['report_datetime'] != null
              ? DateTime.parse(json['report_datetime'])
              : null,
      location: json['location'],
      observationType: json['observation_type'],
      hazardDescription: json['hazard_description'],
      suggestedAction: json['suggested_action'],
      imagePath: json['image_path'],
      status: json['status'] ?? 'submitted',
      lsbNumber: json['lsb_number'],
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
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
      // Workflow
      assignedToUserId: json['assigned_to_user_id'],
      assignedToName: json['assigned_to_name'],
      priority: json['priority'],
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
      validationStatus: json['validation_status'],
      followUpActions: parseFollowUpActions(json['follow_up_actions']), // Parse list map
      // Koreksi AI
      correctionDetected: json['correction_detected'],
      correctionReport: json['correction_report'],
      metadata:
          json['metadata'] is Map
              ? Map<String, dynamic>.from(json['metadata'])
              : (json['metadata'] is String ? jsonDecode(json['metadata']) : null), // Handle jika metadata string JSON
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'reporter_name': reporterName,
      'reporter_position': reporterPosition,
      'reporter_signature': reporterSignature,
      'report_datetime': reportDatetime?.toIso8601String(),
      'location': location,
      'observation_type': observationType,
      'hazard_description': hazardDescription,
      'suggested_action': suggestedAction,
      'image_path': imagePath,
      'status': status,
      'lsb_number': lsbNumber,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'validated_by': validatedBy,
      'validation_notes': validationNotes,
      'validated_at': validatedAt?.toIso8601String(),
      'follow_up': followUp,
      'followed_up_by': followedUpBy,
      'followed_up_at': followedUpAt?.toIso8601String(),
      'closed_by': closedBy,
      'closing_notes': closingNotes,
      'closed_at': closedAt?.toIso8601String(),
      // Workflow
      'assigned_to_user_id': assignedToUserId,
      'assigned_to_name': assignedToName,
      'priority': priority,
      'due_date': dueDate?.toIso8601String(),
      'validation_status': validationStatus,
      'follow_up_actions': followUpActions, // Simpan list map langsung
      // Koreksi AI
      'correction_detected': correctionDetected,
      'correction_report': correctionReport,
      if (metadata != null) 'metadata': metadata,
    };
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }

  String get statusTranslated {
    switch (status?.toLowerCase()) {
      case 'submitted':
        return 'Submitted';
      case 'validated':
        return 'Tervalidasi';
      case 'in_progress':
        return 'Proses';
      case 'completed':
        return 'Selesai';
      default:
        return status ?? '';
    }
  }

  Color get statusColor {
    switch (status?.toLowerCase()) {
      case 'submitted':
        return const Color(0xFFE83F5B);
      case 'validated':
        return const Color(0xFF3F83E8);
      case 'in_progress':
        return const Color(0xFFFFAD33);
      case 'completed':
        return const Color(0xFF00E05D);
      default:
        return const Color(0xFF91969D);
    }
  }

  HazardReport copyWith({
    String? id,
    String? reporterName,
    String? reporterPosition,
    String? reporterSignature,
    DateTime? reportDatetime,
    String? location,
    String? observationType,
    String? hazardDescription,
    String? suggestedAction,
    String? imagePath,
    String? status,
    String? lsbNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? validatedBy,
    String? validationNotes,
    DateTime? validatedAt,
    String? followUp,
    String? followedUpBy,
    DateTime? followedUpAt,
    String? closedBy,
    String? closingNotes,
    DateTime? closedAt,
    // Workflow
    String? assignedToUserId,
    String? assignedToName,
    String? priority,
    DateTime? dueDate,
    String? validationStatus,
    List<Map<String, dynamic>>? followUpActions,
    // Koreksi AI
    bool? correctionDetected,
    String? correctionReport,
    Map<String, dynamic>? metadata,
  }) {
    return HazardReport(
      id: id ?? this.id,
      reporterName: reporterName ?? this.reporterName,
      reporterPosition: reporterPosition ?? this.reporterPosition,
      reporterSignature: reporterSignature ?? this.reporterSignature,
      reportDatetime: reportDatetime ?? this.reportDatetime,
      location: location ?? this.location,
      observationType: observationType ?? this.observationType,
      hazardDescription: hazardDescription ?? this.hazardDescription,
      suggestedAction: suggestedAction ?? this.suggestedAction,
      imagePath: imagePath ?? this.imagePath,
      status: status ?? this.status,
      lsbNumber: lsbNumber ?? this.lsbNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      validatedBy: validatedBy ?? this.validatedBy,
      validationNotes: validationNotes ?? this.validationNotes,
      validatedAt: validatedAt ?? this.validatedAt,
      followUp: followUp ?? this.followUp,
      followedUpBy: followedUpBy ?? this.followedUpBy,
      followedUpAt: followedUpAt ?? this.followedUpAt,
      closedBy: closedBy ?? this.closedBy,
      closingNotes: closingNotes ?? this.closingNotes,
      closedAt: closedAt ?? this.closedAt,
      // Workflow
      assignedToUserId: assignedToUserId ?? this.assignedToUserId,
      assignedToName: assignedToName ?? this.assignedToName,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      validationStatus: validationStatus ?? this.validationStatus,
      followUpActions: followUpActions ?? this.followUpActions,
      // Koreksi AI
      correctionDetected: correctionDetected ?? this.correctionDetected,
      correctionReport: correctionReport ?? this.correctionReport,
      metadata: metadata ?? this.metadata,
    );
  }
}

class HazardAction {
  final String? id;
  final DateTime date;
  final String action;
  final String personInCharge;
  final String? notes;

  HazardAction({
    this.id,
    required this.date,
    required this.action,
    required this.personInCharge,
    this.notes,
  });

  factory HazardAction.fromJson(Map<String, dynamic> json) {
    return HazardAction(
      id: json['id'],
      date:
          json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      action: json['action'] ?? '',
      personInCharge: json['person_in_charge'] ?? '',
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'date': date.toIso8601String(),
      'action': action,
      'person_in_charge': personInCharge,
      if (notes != null) 'notes': notes,
    };
  }
}
