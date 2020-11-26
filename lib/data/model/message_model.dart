import 'package:hive/hive.dart';


part 'message_model_adapter.dart';

@HiveType(typeId: 0, adapterName: "MessageModelListAdapter")
class MessageModel {

  @HiveField(0)
  String _msgType;

  @HiveField(1)
  String _title;

  @HiveField(2)
  String _body;

  @HiveField(3)
  String _url;

  @HiveField(4)
  String _userId;

  @HiveField(5)
  String _compCd;

  @HiveField(6)
  String _compNm;

  @HiveField(7)
  String _receivedDate;

  MessageModel(
      {msgType = "0",
      title = "Default_Title_Text",
      body = "Default_Body_Text",
      url = "/",
      userId,
      compCd,
      compNm = "Default_Company_Text",
      receivedDate = "0000-00-00 00:00:00"}) {
    _msgType = msgType ?? "0";
    _title = title ?? "Default_Title_Text";
    _body = body ?? "Default_Body_Text";
    _url = url ?? "/";
    _userId = userId ?? null;
    _compCd = compCd ?? null;
    _compNm = compNm ?? "Default_Company_Text";
    _receivedDate = receivedDate ?? "0000-00-00 00:00:00";
  }

  get msgType => _msgType;

  get title => _title;

  get body => _body;

  get url => _url;

  get userId => _userId;

  get compCd => _compCd;

  get compNm => _compNm;

  get receivedDate => _receivedDate;

  set msgType(msgType) {
    this._msgType = msgType;
  }

  set title(title) {
    this._title = title;
  }

  set body(body) {
    this._body = body;
  }

  set url(url) {
    this._url = url;
  }

  set userId(userId) {
    this._userId = userId;
  }

  set compCd(compCd) {
    this._compCd = compCd;
  }

  set compNm(compNm) {
    this._compNm = compNm;
  }

  set receivedDate(receivedDate) {
    this._receivedDate = receivedDate;
  }

  toMap() {
    return {
      "msgType": this._msgType,
      "title": this._title,
      "body": this._body,
      "url": this._url,
      "userId": this._userId,
      "compCd": this._compCd,
      "compNm": this._compNm,
      "receivedDate": this._receivedDate
    };
  }

  toString() {
    return toMap().toString();
  }
}
