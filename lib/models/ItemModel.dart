//ITEMID INTEGER PRIMARY KEY,CATID INTEGER, ITEMNAME VARCHAR(100),PKGUNIT VARCHAR(50)
// ,ISACTIVE BIT,CRDATE DATETIME,CREATEDBY VARCHAR(50) NULL,UOM VARCHAR(50) NULL)');
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';


import 'package:flutter/cupertino.dart';

class ItemModel{
  int? ITEMID;
  int CATID;
  String ITEMNAME;
  String PKGUNIT;
  int ISACTIVE;
  String CRDATE;
  String CREATEDBY;
  String UOM;
  Uint8List? image;

  ItemModel({this.ITEMID,required this.CATID,required this.ITEMNAME,required this.PKGUNIT,required this.ISACTIVE,required this.CRDATE,required this.CREATEDBY,required this.UOM,this.image});
  factory ItemModel.fromMap(Map<String, dynamic> json) => new ItemModel(
    ITEMID:json["ITEMID"],
    CATID: json["CATID"],
    ITEMNAME: json["ITEMNAME"],
    PKGUNIT: json["PKGUNIT"],
    ISACTIVE: json["ISACTIVE"],
    CRDATE: json["CRDATE"],
    CREATEDBY: json["CREATEDBY"],
    UOM: json["UOM"],
    image: json["image"],
  );
  Map<String, dynamic>toMap(){
    return{
      'ITEMID':ITEMID,
      'CATID':CATID,
      'ITEMNAME':ITEMNAME,
      'PKGUNIT':PKGUNIT,
      'ISACTIVE':ISACTIVE,
      'CRDATE':CRDATE,
      'CREATEDBY':CREATEDBY,
      'UOM':UOM,
      'image': image,
    };
  }

  ImageProvider getImageProvider() {
    if (image != null) {
      return MemoryImage(image!);
    } else {
      // Return a placeholder image provider if imageBytes is null
      // Image.asset("assets/cattle.png");
      return AssetImage('assets/cattle.png');
    }
  }
}