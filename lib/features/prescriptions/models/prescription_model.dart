import 'package:cloud_firestore/cloud_firestore.dart';

/// Model class representing a prescription
class PrescriptionModel {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String? userPhone;
  final String imageUrl;
  final String? fileName; // New field for image file name
  final String patientName;
  final String? email; // New field - patient/user email for notifications
  final String? doctorName; // Keep for backward compatibility
  final String? notes;
  final String status; // pending, verified, declined, processed
  final DateTime submittedAt;
  final DateTime? approvedAt;
  final String? approvedBy;
  final String? rejectionReason;
  final String? linkedOrderId;
  final String? source; // 'website' or 'mobile'
  final bool? emailSent; // Track if email notification was sent
  final DateTime? emailSentAt; // When email was sent

  PrescriptionModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.userPhone,
    required this.imageUrl,
    this.fileName,
    required this.patientName,
    this.email,
    this.doctorName,
    this.notes,
    this.status = 'pending',
    required this.submittedAt,
    this.approvedAt,
    this.approvedBy,
    this.rejectionReason,
    this.linkedOrderId,
    this.source,
    this.emailSent,
    this.emailSentAt,
  });

  /// Empty helper function
  static PrescriptionModel empty() => PrescriptionModel(
        id: '',
        userId: '',
        userName: '',
        userEmail: '',
        imageUrl: '',
        patientName: '',
        submittedAt: DateTime.now(),
      );

  /// Convert model to JSON structure for storing data in Firebase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'userPhone': userPhone,
      'imageUrl': imageUrl,
      'fileName': fileName,
      'patientName': patientName,
      'email': email,
      'doctorName': doctorName,
      'notes': notes,
      'status': status,
      'submittedAt': submittedAt,
      'approvedAt': approvedAt,
      'approvedBy': approvedBy,
      'rejectionReason': rejectionReason,
      'linkedOrderId': linkedOrderId,
      'source': source,
      'emailSent': emailSent,
      'emailSentAt': emailSentAt,
    };
  }

  /// Helper method to safely convert any date format to DateTime
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    
    try {
      if (value is Timestamp) {
        return value.toDate();
      } else if (value is DateTime) {
        return value;
      } else if (value is String) {
        return DateTime.parse(value);
      } else if (value is int) {
        return DateTime.fromMillisecondsSinceEpoch(value);
      }
    } catch (e) {
      print('⚠️ Failed to parse date: $e');
    }
    
    return null;
  }

  /// Factory method to create a PrescriptionModel from a Firebase document snapshot
  factory PrescriptionModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.data() != null) {
      final data = document.data()!;
      return PrescriptionModel(
        id: document.id,
        userId: data['userId'] ?? '',
        userName: data['userName'] ?? '',
        userEmail: data['userEmail'] ?? '',
        userPhone: data['userPhone'],
        imageUrl: data['imageUrl'] ?? '',
        fileName: data['fileName'],
        patientName: data['patientName'] ?? '',
        email: data['email'],
        doctorName: data['doctorName'],
        notes: data['notes'],
        status: data['status'] ?? 'pending',
        submittedAt: _parseDateTime(data['submittedAt']) ?? DateTime.now(),
        approvedAt: _parseDateTime(data['approvedAt']),
        approvedBy: data['approvedBy'],
        rejectionReason: data['rejectionReason'],
        linkedOrderId: data['linkedOrderId'],
        source: data['source'],
        emailSent: data['emailSent'],
        emailSentAt: _parseDateTime(data['emailSentAt']),
      );
    } else {
      return PrescriptionModel.empty();
    }
  }

  /// Copy with method
  PrescriptionModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userEmail,
    String? userPhone,
    String? imageUrl,
    String? fileName,
    String? patientName,
    String? email,
    String? doctorName,
    String? notes,
    String? status,
    DateTime? submittedAt,
    DateTime? approvedAt,
    String? approvedBy,
    String? rejectionReason,
    String? linkedOrderId,
    String? source,
    bool? emailSent,
    DateTime? emailSentAt,
  }) {
    return PrescriptionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userPhone: userPhone ?? this.userPhone,
      imageUrl: imageUrl ?? this.imageUrl,
      fileName: fileName ?? this.fileName,
      patientName: patientName ?? this.patientName,
      email: email ?? this.email,
      doctorName: doctorName ?? this.doctorName,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      submittedAt: submittedAt ?? this.submittedAt,
      approvedAt: approvedAt ?? this.approvedAt,
      approvedBy: approvedBy ?? this.approvedBy,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      linkedOrderId: linkedOrderId ?? this.linkedOrderId,
      source: source ?? this.source,
      emailSent: emailSent ?? this.emailSent,
      emailSentAt: emailSentAt ?? this.emailSentAt,
    );
  }
}
