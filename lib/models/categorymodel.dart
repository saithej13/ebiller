class categorymodel{
  int? CATID;
  String CATNAME;
  int ISACTIVE;
  String CRDATE;
  String CREATEDBY;
  categorymodel({this.CATID,required this.CATNAME,required this.ISACTIVE,required this.CRDATE,required this.CREATEDBY});

  factory categorymodel.fromMap(Map<String, dynamic> json) => new categorymodel(
    CATID: json["CATID"],
    CATNAME: json["CATNAME"],
    ISACTIVE: json["ISACTIVE"],
    CRDATE: json["CRDATE"],
    CREATEDBY: json["CREATEDBY"],
  );
  Map<String, dynamic>toMap(){
    return{
      'CATNAME':CATNAME,
      'ISACTIVE':ISACTIVE,
      'CRDATE':CRDATE,
      'CREATEDBY':CREATEDBY,
    };
  }
}