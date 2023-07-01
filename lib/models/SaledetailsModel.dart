//SLNO INTEGER REFERENCES MT_PSL_SALE(SLNO),ITEMID INTEGER,QTY NUMERIC(18,2),RATE NUMERIC(18,2),AMOUNT NUMERIC(18,2)
// ,SGST NUMERIC(18,2),CGST NUMERIC(18,2),IGST NUMERIC(18,2),CRDATE DATETIME,TAXRATE NUMERIC(18,2) DEFAULT(0)
// ,TAXAMOUNT NUMERIC(18,2) DEFAULT(0),CREATEDBY VARCHAR(50) NULL)')
class SaledetailsModel{
  int? SLNO;
  int ITEMID;
  double QTY;
  double RATE;
  double AMOUNT;
  double SGST;
  double CGST;
  double IGST;
  String CRDATE;
  double TAXRATE;
  double TAXAMOUNT;
  String CREATEDBY;
  SaledetailsModel({this.SLNO,required this.ITEMID,required this.QTY,required this.RATE,required this.AMOUNT,
  required this.SGST,required this.CGST,required this.IGST,required this.CRDATE,required this.TAXRATE,required this.TAXAMOUNT,required this.CREATEDBY});
  factory SaledetailsModel.fromMap(Map<String,dynamic>json)=>new SaledetailsModel(
      SLNO: json["SLNO"],
      ITEMID: json["ITEMID"],
      QTY: json["QTY"],
      RATE: json["RATE"],
      AMOUNT: json["AMOUNT"],
      SGST: json["SGST"],
      CGST: json["CGST"],
      IGST: json["IGST"],
      CRDATE: json["CRDATE"],
      TAXRATE: json["TAXRATE"],
      TAXAMOUNT: json["TAXAMOUNT"],
      CREATEDBY: json["CREATEDBY"],
  );
  Map<String,dynamic>toMap(){
    return{
      'SLNO': SLNO,
      'ITEMID': ITEMID,
      'QTY': QTY,
      'RATE': RATE,
      'AMOUNT': AMOUNT,
      'SGST': SGST,
      'CGST': CGST,
      'IGST': IGST,
      'CRDATE': CRDATE,
      'TAXRATE': TAXRATE,
      'TAXAMOUNT': TAXAMOUNT,
      'CREATEDBY': CREATEDBY,
    };
  }
}