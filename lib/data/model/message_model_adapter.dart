part of 'message_model.dart';

class MessageModelListAdapter extends TypeAdapter<MessageModel>{

  @override
  final typeId = 0;

  @override
  MessageModel read(BinaryReader reader) {
    // TODO: implement read

    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for(int i =0;i<numOfFields; i++) reader.readByte() :reader.read(),
    };

    return MessageModel(
        msgType: fields[0],
        title: fields[1],
        body: fields[2],
        url: fields[3],
        userId: fields[4],
        compCd: fields[5],
        compNm: fields[6],
        receivedDate: fields[7]);
  }

  @override
  void write(BinaryWriter writer, MessageModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.msgType)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.body)
      ..writeByte(3)
      ..write(obj.url)
      ..writeByte(4)
      ..write(obj.userId)
      ..writeByte(5)
      ..write(obj.compCd)
      ..writeByte(6)
      ..write(obj.compNm)
      ..writeByte(7)
      ..write(obj.receivedDate);
  }

}