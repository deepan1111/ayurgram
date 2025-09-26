// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection_event.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CollectionEventAdapter extends TypeAdapter<CollectionEvent> {
  @override
  final int typeId = 1;

  @override
  CollectionEvent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CollectionEvent(
      eventId: fields[0] as String?,
      collectorId: fields[1] as String,
      gps: fields[2] as GPSLocation,
      species: fields[3] as String,
      quantity: fields[4] as double,
      notes: fields[5] as String,
      qualityMetrics: fields[6] as QualityMetrics,
      timestamp: fields[7] as DateTime?,
      syncStatus: fields[8] as SyncStatus,
      smsPayload: fields[9] as String?,
      lastSyncAttempt: fields[10] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, CollectionEvent obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.eventId)
      ..writeByte(1)
      ..write(obj.collectorId)
      ..writeByte(2)
      ..write(obj.gps)
      ..writeByte(3)
      ..write(obj.species)
      ..writeByte(4)
      ..write(obj.quantity)
      ..writeByte(5)
      ..write(obj.notes)
      ..writeByte(6)
      ..write(obj.qualityMetrics)
      ..writeByte(7)
      ..write(obj.timestamp)
      ..writeByte(8)
      ..write(obj.syncStatus)
      ..writeByte(9)
      ..write(obj.smsPayload)
      ..writeByte(10)
      ..write(obj.lastSyncAttempt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CollectionEventAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GPSLocationAdapter extends TypeAdapter<GPSLocation> {
  @override
  final int typeId = 2;

  @override
  GPSLocation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GPSLocation(
      latitude: fields[0] as double,
      longitude: fields[1] as double,
      altitude: fields[2] as double?,
      accuracy: fields[3] as double?,
      timestamp: fields[4] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, GPSLocation obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.latitude)
      ..writeByte(1)
      ..write(obj.longitude)
      ..writeByte(2)
      ..write(obj.altitude)
      ..writeByte(3)
      ..write(obj.accuracy)
      ..writeByte(4)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GPSLocationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class QualityMetricsAdapter extends TypeAdapter<QualityMetrics> {
  @override
  final int typeId = 3;

  @override
  QualityMetrics read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QualityMetrics(
      freshness: fields[0] as int,
      purity: fields[1] as int,
      size: fields[2] as int,
      additionalNotes: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, QualityMetrics obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.freshness)
      ..writeByte(1)
      ..write(obj.purity)
      ..writeByte(2)
      ..write(obj.size)
      ..writeByte(3)
      ..write(obj.additionalNotes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QualityMetricsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SyncStatusAdapter extends TypeAdapter<SyncStatus> {
  @override
  final int typeId = 4;

  @override
  SyncStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SyncStatus.pending;
      case 1:
        return SyncStatus.syncing;
      case 2:
        return SyncStatus.synced;
      case 3:
        return SyncStatus.failed;
      case 4:
        return SyncStatus.smsQueued;
      case 5:
        return SyncStatus.smsSent;
      default:
        return SyncStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, SyncStatus obj) {
    switch (obj) {
      case SyncStatus.pending:
        writer.writeByte(0);
        break;
      case SyncStatus.syncing:
        writer.writeByte(1);
        break;
      case SyncStatus.synced:
        writer.writeByte(2);
        break;
      case SyncStatus.failed:
        writer.writeByte(3);
        break;
      case SyncStatus.smsQueued:
        writer.writeByte(4);
        break;
      case SyncStatus.smsSent:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
