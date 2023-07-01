//LOGID INTEGER PRIMARY KEY AUTOINCREMENT,TABLENAME VARCHAR(50),TDATE DATETIME,DESCRIPTION VARCHAR(150),
// ACTION NCHAR(50),OLDAMT NUMERIC(18,2),NEWAMT NUMERIC(18,2),CRDATE DATETIME,CREATEDBY VARCHAR(50) NULL)');
class LogtableModel{
  int LOGID;
  String TABLENAME;
  String TDATE;
  String DESCRIPTION;
  String ACTION;
  double OLDAMT;
  double NEWAMT;
  String CRDATE;
  String CREATEDBY;
  LogtableModel({required this.LOGID,required this.TABLENAME,required this.TDATE,required this.DESCRIPTION,required this.ACTION,required this.OLDAMT,required this.NEWAMT,required this.CRDATE,required this.CREATEDBY});
  factory LogtableModel.fromMap(Map<String,dynamic>json)=>new LogtableModel(
      LOGID: json["LOGID"],
      TABLENAME: json["TABLENAME"],
      TDATE: json["TDATE"],
      DESCRIPTION: json["DESCRIPTION"],
      ACTION: json["ACTION"],
      OLDAMT: json["OLDAMT"],
      NEWAMT: json["NEWAMT"],
      CRDATE: json["CRDATE"],
      CREATEDBY: json["CREATEDBY"],
  );
  Map<String,dynamic>toMap(){
    return{
      'LOGID': LOGID,
      'TABLENAME': TABLENAME,
      'TDATE': TDATE,
      'DESCRIPTION': DESCRIPTION,
      'ACTION': ACTION,
      'OLDAMT': OLDAMT,
      'NEWAMT': NEWAMT,
      'CRDATE': CRDATE,
      'CREATEDBY': CREATEDBY,
    };
  }
}