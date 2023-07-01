
class TR_SaleModel{
  int? SLNO;
  int ITEMID;
  String TDATE;
  int CCODE;
  double QTY;
  double RATE;
  double AMOUNT;
  double SGST;
  double CGST;
  double IGST;
  double TAXRATE;
  double TAXAMOUNT;
  String PAYMODE;
  String CRDATE;
  String CREATEDBY;
  TR_SaleModel({this.SLNO,required this.ITEMID,required this.TDATE,required this.CCODE,required this.QTY,required this.RATE,required this.AMOUNT,required this.SGST,required this.CGST,required this.IGST,required this.TAXRATE,required this.TAXAMOUNT,required this.PAYMODE,required this.CRDATE,required this.CREATEDBY});
  factory TR_SaleModel.fromMap(Map<String,dynamic>json)=>new TR_SaleModel(
    SLNO: json["SLNO"],
    ITEMID: json["ITEMID"],
    TDATE: json["TDATE"],
    CCODE: json["CCODE"],
    QTY: json["QTY"].toDouble(),
    RATE: json["RATE"].toDouble(),
    AMOUNT: json["AMOUNT"].toDouble(),
    SGST: json["SGST"].toDouble(),
    CGST: json["CGST"].toDouble(),
    IGST: json["IGST"].toDouble(),
    TAXRATE: json["TAXRATE"].toDouble(),
    TAXAMOUNT: json["TAXAMOUNT"].toDouble(),
    PAYMODE: json["PAYMODE"],
    CRDATE: json["CRDATE"],
    CREATEDBY: json["CREATEDBY"],
  );
  Map<String,dynamic>toMap(){
    return{
      'SLNO': SLNO,
      'ITEMID':ITEMID,
      'TDATE': TDATE,
      'CCODE': CCODE,
      'QTY': QTY,
      'RATE':RATE,
      'AMOUNT': AMOUNT,
      'SGST': SGST,
      'CGST': CGST,
      'IGST': IGST,
      'TAXRATE': TAXRATE,
      'TAXAMOUNT': TAXAMOUNT,
      'PAYMODE': PAYMODE,
      'CRDATE': CRDATE,
      'CREATEDBY': CREATEDBY,
    };
  }
}