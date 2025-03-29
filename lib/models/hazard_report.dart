import 'dart:convert';
import 'package:flutter/material.dart';

class HazardReport {
  final String? id;
  final String? reporterName;
  final String? reporterDepartment;
  final String? reporterPosition;
  final DateTime? reportDate;
  final String? location;
  final String? hazardDescription;
  final String? suggestedAction;
  final String? imageUrl;
  final String? status;
  final Map<String, dynamic>? metadata;
  final String? assignedTo;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  HazardReport({
    this.id,
    this.reporterName,
    this.reporterDepartment,
    this.reporterPosition,
    this.reportDate,
    this.location,
    this.hazardDescription,
    this.suggestedAction,
    this.imageUrl,
    this.status = 'open',
    this.metadata,
    this.assignedTo,
    this.createdAt,
    this.updatedAt,
  });

  factory HazardReport.fromJson(Map<String, dynamic> json) {
    return HazardReport(
      id: json['id'],
      reporterName: json['reporter_name'],
      reporterDepartment: json['reporter_department'],
      reporterPosition: json['reporter_position'],
      reportDate:
          json['report_date'] != null
              ? DateTime.parse(json['report_date'])
              : null,
      location: json['location'],
      hazardDescription: json['hazard_description'],
      suggestedAction: json['suggested_action'],
      imageUrl: json['image_url'],
      status: json['status'] ?? 'open',
      metadata: json['metadata'] != null ? jsonDecode(json['metadata']) : null,
      assignedTo: json['assigned_to'],
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reporter_name': reporterName,
      'reporter_department': reporterDepartment,
      'reporter_position': reporterPosition,
      'report_date': reportDate?.toIso8601String(),
      'location': location,
      'hazard_description': hazardDescription,
      'suggested_action': suggestedAction,
      'image_url': imageUrl,
      'status': status,
      'metadata': metadata != null ? jsonEncode(metadata) : null,
      'assigned_to': assignedTo,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }

  String get statusTranslated {
    switch (status?.toLowerCase()) {
      case 'open':
        return 'Open';
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
      case 'open':
        return const Color(0xFFE83F5B);
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
    String? reporterDepartment,
    String? reporterPosition,
    DateTime? reportDate,
    String? location,
    String? hazardDescription,
    String? suggestedAction,
    String? imageUrl,
    String? status,
    Map<String, dynamic>? metadata,
    String? assignedTo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HazardReport(
      id: id ?? this.id,
      reporterName: reporterName ?? this.reporterName,
      reporterDepartment: reporterDepartment ?? this.reporterDepartment,
      reporterPosition: reporterPosition ?? this.reporterPosition,
      reportDate: reportDate ?? this.reportDate,
      location: location ?? this.location,
      hazardDescription: hazardDescription ?? this.hazardDescription,
      suggestedAction: suggestedAction ?? this.suggestedAction,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
      assignedTo: assignedTo ?? this.assignedTo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
