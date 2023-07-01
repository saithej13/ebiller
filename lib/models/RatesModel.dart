class RatesModel{
  //SLNO INTEGER PRIMARY KEY AUTOINCREMENT,ITEMID INTEGER,RATE NUMERIC(18,2),SGST NUMERIC(18,2),CGST NUMERIC(18,2),
  // IGST NUMERIC(18,2),CRDATE DATETIME,FROMDATE DATETIME,TODATE DATETIME,CREATEDBY VARCHAR(50) NULL)');
  int? SLNO;
  int ITEMID;
  double RATE;
  double SGST;
  double CGST;
  double IGST;
  String CRDATE;
  String FROMDATE;
  String TODATE;
  String CREATEDBY;
  RatesModel({this.SLNO,required this.ITEMID,required this.RATE,required this.SGST,required this.CGST,required this.IGST,required this.CRDATE,required this.FROMDATE,required this.TODATE,required this.CREATEDBY});
  factory RatesModel.fromMap(Map<String, dynamic>json)=>new RatesModel(
      SLNO:json["SLNO"],
      ITEMID: json["ITEMID"],
      RATE: json["RATE"].toDouble(),
      SGST: json["SGST"].toDouble(),
      CGST: json["CGST"].toDouble(),
      IGST: json["IGST"].toDouble(),
      CRDATE: json["CRDATE"],
      FROMDATE: json["FROMDATE"],
      TODATE: json["TODATE"],
      CREATEDBY: json["CREATEDBY"],
  );
  Map<String, dynamic>toMap(){
    return{
      'SLNO': SLNO,
      'ITEMID': ITEMID,
      'RATE': RATE,
      'SGST': SGST,
      'CGST': CGST,
      'IGST': IGST,
      'CRDATE': CRDATE,
      'FROMDATE': FROMDATE,
      'TODATE': TODATE,
      'CREATEDBY': CREATEDBY,
    };
}
}