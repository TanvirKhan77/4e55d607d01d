// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_vital_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveVitalModelAdapter extends TypeAdapter<HiveVitalModel> {
  @override
  final int typeId = 0;

  @override
  HiveVitalModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveVitalModel(
      deviceId: fields[0] as String,
      timestamp: fields[1] as DateTime,
      thermalValue: fields[2] as int,
      batteryLevel: fields[3] as double,
      memoryUsage: fields[4] as double,
      isSynced: fields[5] as bool,
      createdAt: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, HiveVitalModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.deviceId)
      ..writeByte(1)
      ..write(obj.timestamp)
      ..writeByte(2)
      ..write(obj.thermalValue)
      ..writeByte(3)
      ..write(obj.batteryLevel)
      ..writeByte(4)
      ..write(obj.memoryUsage)
      ..writeByte(5)
      ..write(obj.isSynced)
      ..writeByte(6)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveVitalModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
