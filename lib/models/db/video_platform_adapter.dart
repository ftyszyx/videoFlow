import 'package:hive/hive.dart';
import 'package:videoflow/entity/common.dart';

class VideoPlatformAdapter extends TypeAdapter<VideoPlatform> {
  @override
  final int typeId = 3; // ensure unique id across adapters

  @override
  VideoPlatform read(BinaryReader reader) {
    final index = reader.readByte();
    return VideoPlatform.values[index];
  }

  @override
  void write(BinaryWriter writer, VideoPlatform obj) {
    writer.writeByte(obj.index);
  }
}
