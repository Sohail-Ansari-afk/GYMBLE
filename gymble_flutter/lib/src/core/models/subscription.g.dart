// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SubscriptionAdapter extends TypeAdapter<Subscription> {
  @override
  final int typeId = 2;

  @override
  Subscription read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Subscription(
      id: fields[0] as String,
      planId: fields[1] as String,
      planName: fields[2] as String,
      price: fields[3] as double,
      startDate: fields[4] as DateTime,
      endDate: fields[5] as DateTime,
      status: fields[6] as SubscriptionStatus,
      paymentMethod: fields[7] as String?,
      transactionId: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Subscription obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.planId)
      ..writeByte(2)
      ..write(obj.planName)
      ..writeByte(3)
      ..write(obj.price)
      ..writeByte(4)
      ..write(obj.startDate)
      ..writeByte(5)
      ..write(obj.endDate)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.paymentMethod)
      ..writeByte(8)
      ..write(obj.transactionId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubscriptionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
