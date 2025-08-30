import 'package:hive/hive.dart';
import 'package:videoflow/entity/common.dart';

class TaskStatusAdapter extends TypeAdapter<TaskStatus> {
  @override
  final int typeId = 5; // ensure unique id across adapters

  @override
  TaskStatus read(BinaryReader reader) {
    final index = reader.readByte();
    return TaskStatus.values[index];
  }

  @override
  void write(BinaryWriter writer, TaskStatus obj) {
    writer.writeByte(obj.index);
  }
}
