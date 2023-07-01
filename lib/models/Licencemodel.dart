class Licencemodel{
  int ID;
  String BNAME;
  String FROMDATE;
  String TODATE;
  String ADDRESS;
  String PHONENO;
  Licencemodel({required this.ID,required this.BNAME,required this.FROMDATE,required this.TODATE,required this.ADDRESS,required this.PHONENO});

  factory Licencemodel.fromMap(Map<String, dynamic> json) => new Licencemodel(
    ID: json["ID"],
    BNAME: json["BNAME"],
    FROMDATE: json["FROMDATE"],
    TODATE: json["TODATE"],
    ADDRESS: json["ADDRESS"],
    PHONENO: json["PHONENO"],
  );
  Map<String, dynamic>toMap(){
    return{
      'ID':ID,
      'BNAME':BNAME,
      'FROMDATE':FROMDATE,
      'TODATE':TODATE,
      'ADDRESS':ADDRESS,
      'PHONENO':PHONENO,
    };
  }
}