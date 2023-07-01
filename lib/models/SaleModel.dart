//SLNO INTEGER PRIMARY KEY,TDATE DATETIME,CCODE INTEGER,SALE_QTY NUMERIC(18,2),SALE_AMOUNT(18,2),PAYMODE VARCHAR(50)
// ,CRDATE DATETIME,CREATEDBY VARCHAR(50) NULL)');
import 'package:ebiller2/models/RatesModel.dart';

class SaleModel{
  int? SLNO;
  int BCODE;
  String TDATE;
  int CCODE;
  double SALE_QTY;
  double SALE_AMOUNT;
  String PAYMODE;
  String CRDATE;
  String CREATEDBY;
  SaleModel({this.SLNO ,required this.BCODE,required this.TDATE,required this.CCODE,required this.SALE_QTY,required this.SALE_AMOUNT,required this.PAYMODE,required this.CRDATE,required this.CREATEDBY});
  factory SaleModel.fromMap(Map<String,dynamic>json)=>new SaleModel(
      SLNO: json["SLNO"],
      BCODE: json["BCODE"],
      TDATE: json["TDATE"],
      CCODE: json["CCODE"],
      SALE_QTY: json["SALE_QTY"],
      SALE_AMOUNT: json["SALE_AMOUNT"],
      PAYMODE: json["PAYMODE"],
      CRDATE: json["CRDATE"],
      CREATEDBY: json["CREATEDBY"],
  );
  Map<String,dynamic>toMap(){
    return{
      'SLNO': SLNO,
      'BCODE':BCODE,
      'TDATE': TDATE,
      'CCODE': CCODE,
      'SALE_QTY': SALE_QTY,
      'SALE_AMOUNT': SALE_AMOUNT,
      'PAYMODE': PAYMODE,
      'CRDATE': CRDATE,
      'CREATEDBY': CREATEDBY,
    };
  }
}