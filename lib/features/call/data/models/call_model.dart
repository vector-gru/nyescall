import 'package:cloud_firestore/cloud_firestore.dart';

enum CallStatus { pending, inProgress, completed, failed }

class CallModel {
  const CallModel({
    required this.id,
    required this.userId,
    required this.recipientName,
    required this.phoneNumber,
    required this.language,
    required this.reason,
    required this.status,
    required this.createdAt,
    this.blandCallId,
    this.durationSeconds,
    this.recordingUrl,
    this.transcript,
  });

  final String id;
  final String userId;
  final String recipientName;
  final String phoneNumber;
  final String language;
  final String reason;
  final CallStatus status;
  final DateTime createdAt;
  final String? blandCallId;
  final int? durationSeconds;
  final String? recordingUrl;
  final String? transcript;

  String get statusLabel => switch (status) {
        CallStatus.pending => 'Pending',
        CallStatus.inProgress => 'In progress',
        CallStatus.completed => 'Completed',
        CallStatus.failed => 'Failed',
      };

  factory CallModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return CallModel(
      id: doc.id,
      userId: d['userId'] as String? ?? '',
      recipientName: d['recipientName'] as String? ?? '',
      phoneNumber: d['phoneNumber'] as String? ?? '',
      language: d['language'] as String? ?? 'English',
      reason: d['reason'] as String? ?? '',
      status: CallStatus.values.firstWhere(
        (s) => s.name == (d['status'] as String? ?? 'pending'),
        orElse: () => CallStatus.pending,
      ),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      blandCallId: d['blandCallId'] as String?,
      durationSeconds: d['durationSeconds'] as int?,
      recordingUrl: d['recordingUrl'] as String?,
      transcript: d['transcript'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'recipientName': recipientName,
        'phoneNumber': phoneNumber,
        'language': language,
        'reason': reason,
        'status': status.name,
        'createdAt': Timestamp.fromDate(createdAt),
        if (blandCallId != null) 'blandCallId': blandCallId,
      };
}
