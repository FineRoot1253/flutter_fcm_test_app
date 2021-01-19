import 'package:intl/intl.dart';

class MessageModel {

  String _msgType;

  String _title;

  String _body;

  String _url;

  String _userId;

  String _compCd;

  String _compNm;

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

  MessageModel.fromJson(Map<String, dynamic> map)
      : _msgType = map["msgType"] ?? "0",
        _title = map["title"] ?? "Default_Title_Text",
        _body = map["body"] ?? "Default_Body_Text",
        _url = map["url"] ?? map["URL"] ??  "/",
        _userId = map["userId"] ?? null,
        _compCd = map["compCd"] ?? null,
        _compNm = map["compNm"] ?? "Default_Company_Text",
        _receivedDate = map["receivedDate"] ?? DateFormat("yyyy-MM-dd hh:mm:ss").format(DateTime.now());

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

  @override
  bool operator ==(Object other) {
    // TODO: implement ==
    return (identical(this, other) ||
            other is MessageModel &&
            this.runtimeType == other.runtimeType &&
            other.title == this.title &&
            other.body == this.body &&
            other.msgType == this.msgType &&
            other.compCd == this.compCd &&
            other.compNm == this.compNm &&
            other.url == this.url &&
            other.receivedDate == this.receivedDate);
  }

  @override
  // TODO: implement hashCode
  int get hashCode => this._msgType.hashCode
  ^ this._body.hashCode
  ^ this._title.hashCode
  ^ this._compCd.hashCode
  ^ this._compNm.hashCode
  ^ this._url.hashCode
  ^ this._userId.hashCode
  ^ this._receivedDate.hashCode;
}
