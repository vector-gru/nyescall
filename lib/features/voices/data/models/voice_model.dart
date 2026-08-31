import 'package:cloud_firestore/cloud_firestore.dart';

enum VoiceType { myVoice, aiMale, aiFemale, other }

class VoiceModel {
  const VoiceModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.language,
    required this.speakingSpeed,
    required this.voiceTone,
    required this.createdAt,
    this.audioUrl,
    this.blandVoiceId,
    this.isDefault = false,
  });

  final String id;
  final String userId;
  final String name;
  final VoiceType type;
  final String language;
  final String speakingSpeed;
  final String voiceTone;
  final DateTime createdAt;
  final String? audioUrl;
  final String? blandVoiceId;
  final bool isDefault;

  factory VoiceModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return VoiceModel(
      id: doc.id,
      userId: d['userId'] as String? ?? '',
      name: d['name'] as String? ?? 'Voice',
      type: VoiceType.values.firstWhere(
        (t) => t.name == (d['type'] as String? ?? 'myVoice'),
        orElse: () => VoiceType.myVoice,
      ),
      language: d['language'] as String? ?? 'English',
      speakingSpeed: d['speakingSpeed'] as String? ?? 'Normal',
      voiceTone: d['voiceTone'] as String? ?? 'Professional',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      audioUrl: d['audioUrl'] as String?,
      blandVoiceId: d['blandVoiceId'] as String?,
      isDefault: d['isDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'name': name,
        'type': type.name,
        'language': language,
        'speakingSpeed': speakingSpeed,
        'voiceTone': voiceTone,
        'createdAt': Timestamp.fromDate(createdAt),
        if (audioUrl != null) 'audioUrl': audioUrl,
        if (blandVoiceId != null) 'blandVoiceId': blandVoiceId,
        'isDefault': isDefault,
      };
}
