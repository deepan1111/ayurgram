import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';

part 'collection_event.g.dart';

@HiveType(typeId: 1)
class CollectionEvent extends HiveObject {
  @HiveField(0)
  final String eventId;

  @HiveField(1)
  final String collectorId;

  @HiveField(2)
  final GPSLocation gps;

  @HiveField(3)
  final String species;

  @HiveField(4)
  final double quantity;

  @HiveField(5)
  final String notes;

  @HiveField(6)
  final QualityMetrics qualityMetrics;

  @HiveField(7)
  final DateTime timestamp;

  @HiveField(8)
  final SyncStatus syncStatus;

  @HiveField(9)
  final String? smsPayload;

  @HiveField(10)
  final DateTime? lastSyncAttempt;

  CollectionEvent({
    String? eventId,
    required this.collectorId,
    required this.gps,
    required this.species,
    required this.quantity,
    required this.notes,
    required this.qualityMetrics,
    DateTime? timestamp,
    this.syncStatus = SyncStatus.pending,
    this.smsPayload,
    this.lastSyncAttempt,
  }) : eventId = eventId ?? const Uuid().v4(),
       timestamp = timestamp ?? DateTime.now();

  factory CollectionEvent.fromJson(Map<String, dynamic> json) {
    return CollectionEvent(
      eventId: json['eventId'] as String,
      collectorId: json['collectorId'] as String,
      gps: GPSLocation.fromJson(json['gps'] as Map<String, dynamic>),
      species: json['species'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      notes: json['notes'] as String,
      qualityMetrics: QualityMetrics.fromJson(json['qualityMetrics'] as Map<String, dynamic>),
      timestamp: DateTime.parse(json['timestamp'] as String),
      syncStatus: SyncStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['syncStatus'],
        orElse: () => SyncStatus.pending,
      ),
      smsPayload: json['smsPayload'] as String?,
      lastSyncAttempt: json['lastSyncAttempt'] != null 
          ? DateTime.parse(json['lastSyncAttempt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'collectorId': collectorId,
      'gps': gps.toJson(),
      'species': species,
      'quantity': quantity,
      'notes': notes,
      'qualityMetrics': qualityMetrics.toJson(),
      'timestamp': timestamp.toIso8601String(),
      'syncStatus': syncStatus.toString().split('.').last,
      'smsPayload': smsPayload,
      'lastSyncAttempt': lastSyncAttempt?.toIso8601String(),
    };
  }

  // FHIR-style metadata bundle
  Map<String, dynamic> toFHIRBundle() {
    return {
      'resourceType': 'Bundle',
      'id': eventId,
      'type': 'collection',
      'timestamp': timestamp.toIso8601String(),
      'entry': [
        {
          'resource': {
            'resourceType': 'Observation',
            'id': eventId,
            'status': 'final',
            'category': [
              {
                'coding': [
                  {
                    'system': 'http://terminology.hl7.org/CodeSystem/observation-category',
                    'code': 'survey',
                    'display': 'Survey'
                  }
                ]
              }
            ],
            'code': {
              'coding': [
                {
                  'system': 'http://ayurgram.org/species',
                  'code': species.toLowerCase().replaceAll(' ', '_'),
                  'display': species
                }
              ]
            },
            'subject': {
              'reference': 'Collector/$collectorId'
            },
            'effectiveDateTime': timestamp.toIso8601String(),
            'valueQuantity': {
              'value': quantity,
              'unit': 'kg',
              'system': 'http://unitsofmeasure.org',
              'code': 'kg'
            },
            'component': [
              {
                'code': {
                  'coding': [
                    {
                      'system': 'http://ayurgram.org/quality',
                      'code': 'freshness',
                      'display': 'Freshness'
                    }
                  ]
                },
                'valueInteger': qualityMetrics.freshness
              },
              {
                'code': {
                  'coding': [
                    {
                      'system': 'http://ayurgram.org/quality',
                      'code': 'purity',
                      'display': 'Purity'
                    }
                  ]
                },
                'valueInteger': qualityMetrics.purity
              }
            ],
            'note': [
              {
                'text': notes
              }
            ]
          }
        },
        {
          'resource': {
            'resourceType': 'Location',
            'id': '${eventId}_location',
            'position': {
              'longitude': gps.longitude,
              'latitude': gps.latitude,
              'altitude': gps.altitude
            }
          }
        }
      ]
    };
  }

  // Generate SMS payload for offline transmission
  String generateSMSPayload() {
    return 'AYUR:$eventId:$collectorId:${gps.latitude.toStringAsFixed(6)}:${gps.longitude.toStringAsFixed(6)}:$species:$quantity:${qualityMetrics.freshness}:${qualityMetrics.purity}:${timestamp.millisecondsSinceEpoch}';
  }

  CollectionEvent copyWith({
    String? eventId,
    String? collectorId,
    GPSLocation? gps,
    String? species,
    double? quantity,
    String? notes,
    QualityMetrics? qualityMetrics,
    DateTime? timestamp,
    SyncStatus? syncStatus,
    String? smsPayload,
    DateTime? lastSyncAttempt,
  }) {
    return CollectionEvent(
      eventId: eventId ?? this.eventId,
      collectorId: collectorId ?? this.collectorId,
      gps: gps ?? this.gps,
      species: species ?? this.species,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
      qualityMetrics: qualityMetrics ?? this.qualityMetrics,
      timestamp: timestamp ?? this.timestamp,
      syncStatus: syncStatus ?? this.syncStatus,
      smsPayload: smsPayload ?? this.smsPayload,
      lastSyncAttempt: lastSyncAttempt ?? this.lastSyncAttempt,
    );
  }
}

@HiveType(typeId: 2)
class GPSLocation {
  @HiveField(0)
  final double latitude;

  @HiveField(1)
  final double longitude;

  @HiveField(2)
  final double? altitude;

  @HiveField(3)
  final double? accuracy;

  @HiveField(4)
  final DateTime timestamp;

  GPSLocation({
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.accuracy,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory GPSLocation.fromJson(Map<String, dynamic> json) {
    return GPSLocation(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      altitude: json['altitude'] != null ? (json['altitude'] as num).toDouble() : null,
      accuracy: json['accuracy'] != null ? (json['accuracy'] as num).toDouble() : null,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'accuracy': accuracy,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

@HiveType(typeId: 3)
class QualityMetrics {
  @HiveField(0)
  final int freshness; // 1-10 scale

  @HiveField(1)
  final int purity; // 1-10 scale

  @HiveField(2)
  final int size; // 1-10 scale

  @HiveField(3)
  final String? additionalNotes;

  QualityMetrics({
    required this.freshness,
    required this.purity,
    required this.size,
    this.additionalNotes,
  });

  factory QualityMetrics.fromJson(Map<String, dynamic> json) {
    return QualityMetrics(
      freshness: json['freshness'] as int,
      purity: json['purity'] as int,
      size: json['size'] as int,
      additionalNotes: json['additionalNotes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'freshness': freshness,
      'purity': purity,
      'size': size,
      'additionalNotes': additionalNotes,
    };
  }
}

@HiveType(typeId: 4)
enum SyncStatus {
  @HiveField(0)
  pending,

  @HiveField(1)
  syncing,

  @HiveField(2)
  synced,

  @HiveField(3)
  failed,

  @HiveField(4)
  smsQueued,

  @HiveField(5)
  smsSent,
}
