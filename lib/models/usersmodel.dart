class usersmodel{
  int? USERID;
  String USERNAME;
  String PASSWORD;
  int? ROLEID;
  usersmodel({this.USERID,required this.USERNAME,required this.PASSWORD,this.ROLEID});

  factory usersmodel.fromMap(Map<String, dynamic> json) => new usersmodel(
    USERID: json["USERID"],
    USERNAME: json["USERNAME"],
    PASSWORD: json["PASSWORD"],
    ROLEID: json["ROLEID"],
  );
  Map<String, dynamic>toMap(){
    return{
      'USERID':USERID,
      'USERNAME':USERNAME,
      'PASSWORD':PASSWORD,
      'ROLEID':ROLEID,
    };
  }
}