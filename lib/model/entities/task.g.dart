// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 0;

  @override
  Task read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Task(
      id: fields[0] as String,
      title: fields[1] as String,
      energyReward: (fields[3] as num).toInt(),
      cadence: fields[2] == null ? TaskCadence.never : fields[2] as TaskCadence,
      isCompleted: fields[4] == null ? false : fields[4] as bool,
      completedAt: fields[5] as DateTime?,
      category: fields[6] as TaskCategory,
      createdDate: fields[7] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.cadence)
      ..writeByte(3)
      ..write(obj.energyReward)
      ..writeByte(4)
      ..write(obj.isCompleted)
      ..writeByte(5)
      ..write(obj.completedAt)
      ..writeByte(6)
      ..write(obj.category)
      ..writeByte(7)
      ..write(obj.createdDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TaskCategoryAdapter extends TypeAdapter<TaskCategory> {
  @override
  final int typeId = 1;

  @override
  TaskCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TaskCategory.selfCare;
      case 1:
        return TaskCategory.productivity;
      case 2:
        return TaskCategory.exercise;
      case 3:
        return TaskCategory.mindfulness;
      default:
        return TaskCategory.selfCare;
    }
  }

  @override
  void write(BinaryWriter writer, TaskCategory obj) {
    switch (obj) {
      case TaskCategory.selfCare:
        writer.writeByte(0);
      case TaskCategory.productivity:
        writer.writeByte(1);
      case TaskCategory.exercise:
        writer.writeByte(2);
      case TaskCategory.mindfulness:
        writer.writeByte(3);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TaskCadenceAdapter extends TypeAdapter<TaskCadence> {
  @override
  final int typeId = 10;

  @override
  TaskCadence read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TaskCadence.daily;
      case 1:
        return TaskCadence.weekly;
      case 2:
        return TaskCadence.monthly;
      case 3:
        return TaskCadence.never;
      default:
        return TaskCadence.daily;
    }
  }

  @override
  void write(BinaryWriter writer, TaskCadence obj) {
    switch (obj) {
      case TaskCadence.daily:
        writer.writeByte(0);
      case TaskCadence.weekly:
        writer.writeByte(1);
      case TaskCadence.monthly:
        writer.writeByte(2);
      case TaskCadence.never:
        writer.writeByte(3);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskCadenceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
