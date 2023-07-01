import 'package:ebiller2/models/Licencemodel.dart';
import 'package:ebiller2/models/usersmodel.dart';
import 'package:flutter/foundation.dart';
import 'package:ebiller2/models/ItemModel.dart';
import 'package:ebiller2/models/LogtableModel.dart';
import 'package:ebiller2/models/RatesModel.dart';
import 'package:ebiller2/models/SaleModel.dart';
import 'package:ebiller2/models/SaledetailsModel.dart';
import 'package:ebiller2/models/categorymodel.dart';
import 'package:googleapis/datastore/v1.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'models/TR_SaleModel.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'ebiller.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute('PRAGMA foreign_keys = ON');
        db.execute('CREATE TABLE MT_PSL_CATEGORY (CATID INTEGER PRIMARY KEY AUTOINCREMENT, CATNAME VARCHAR(100),ISACTIVE BIT,CRDATE DATETIME,CREATEDBY VARCHAR(50) NULL)');
        db.execute('CREATE TABLE MT_PSL_ITEMS (ITEMID INTEGER PRIMARY KEY AUTOINCREMENT,CATID INTEGER, ITEMNAME VARCHAR(100),image BLOB,PKGUNIT VARCHAR(50),ISACTIVE BIT,CRDATE DATETIME,CREATEDBY VARCHAR(50) NULL,UOM VARCHAR(50) NULL,FOREIGN KEY (CATID) REFERENCES MT_PSL_CATEGORY(CATID) ON DELETE NO ACTION)');
        db.execute('CREATE TABLE MT_PSL_RATES (SLNO INTEGER PRIMARY KEY AUTOINCREMENT,ITEMID INTEGER UNIQUE,RATE NUMERIC(18,2),SGST NUMERIC(18,2),CGST NUMERIC(18,2),IGST NUMERIC(18,2),CRDATE DATETIME,FROMDATE DATETIME,TODATE DATETIME,CREATEDBY VARCHAR(50) NULL,FOREIGN KEY (ITEMID) REFERENCES MT_PSL_ITEMS(ITEMID) ON DELETE RESTRICT)');
        db.execute('CREATE TABLE TR_PSL_SALE (SLNO INTEGER PRIMARY KEY AUTOINCREMENT,ITEMID INTEGER,TDATE DATETIME,CCODE INTEGER,QTY NUMERIC(18,2),RATE NUMERIC(18,2),AMOUNT NUMERIC(18,2),SGST NUMERIC(18,2),CGST NUMERIC(18,2),IGST NUMERIC(18,2),TAXRATE NUMERIC(18,2) DEFAULT(0),TAXAMOUNT NUMERIC(18,2) DEFAULT(0),PAYMODE VARCHAR(50),CRDATE DATETIME,CREATEDBY VARCHAR(50) NULL)');
        db.execute('CREATE TABLE MT_PSL_SALE (SLNO INTEGER PRIMARY KEY,BCODE INTEGER,TDATE DATETIME,CCODE INTEGER,SALE_QTY NUMERIC(18,2),SALE_AMOUNT NUMERIC(18,2),PAYMODE VARCHAR(50),CRDATE DATETIME,CREATEDBY VARCHAR(50) NULL)');
        db.execute('CREATE TABLE MT_PSL_SALEDETAILS (SLNO INTEGER ,ITEMID INTEGER,QTY NUMERIC(18,2),RATE NUMERIC(18,2),AMOUNT NUMERIC(18,2),SGST NUMERIC(18,2),CGST NUMERIC(18,2),IGST NUMERIC(18,2),CRDATE DATETIME,TAXRATE NUMERIC(18,2) DEFAULT(0),TAXAMOUNT NUMERIC(18,2) DEFAULT(0),CREATEDBY VARCHAR(50) NULL,FOREIGN KEY (SLNO) REFERENCES MT_PSL_SALE(SLNO) ON DELETE RESTRICT,FOREIGN KEY (ITEMID) REFERENCES MT_PSL_ITEMS(ITEMID) ON DELETE RESTRICT)');
        db.execute('CREATE TABLE LOGTABLE (LOGID INTEGER PRIMARY KEY AUTOINCREMENT,TABLENAME VARCHAR(50),TDATE DATETIME,DESCRIPTION VARCHAR(150),ACTION NCHAR(50),OLDAMT NUMERIC(18,2),NEWAMT NUMERIC(18,2),CRDATE DATETIME,CREATEDBY VARCHAR(50) NULL)');
        db.execute('CREATE TABLE USERS (USERID INTEGER PRIMARY KEY AUTOINCREMENT,USERNAME VARCHAR(50),PASSWORD VARCHAR(50),ROLEID INTEGER)');
        db.execute('CREATE TABLE LICENCE (ID INTEGER PRIMARY KEY UNIQUE,BNAME VARCHAR(50),FROMDATE DATETIME,TODATE DATETIME,ADDRESS VARCHAR(50),PHONENO VARCHAR(50))');
        db.execute("INSERT INTO USERS (USERID, USERNAME, PASSWORD, ROLEID) VALUES(1, 'admin', '1997', 1)");
        db.execute("INSERT INTO USERS (USERID, USERNAME, PASSWORD, ROLEID) VALUES(2, 'pranav', '1234', 0)");
      },
    );
  }


  Future<void> insertCategory(categorymodel category) async {
    final db = await database;
    await db.insert('MT_PSL_CATEGORY', category.toMap());
  }
  Future<void> insertUsers(usersmodel users) async {
    final db = await database;
    await db.insert('USERS', users.toMap());
  }
  Future<void> insertLicence(Licencemodel licencemodel) async {
    final db = await database;
    final result = await db.rawQuery('SELECT ID FROM LICENCE WHERE ID=?',[licencemodel.ID]);
    if (result.isNotEmpty) {
      throw Exception('LICENCE EXISTS');
    } else {
      await db.insert('LICENCE', licencemodel.toMap());
    }
  }
  Future<void> insertItem(ItemModel itemModel) async {
    final db = await database;
    final result = await db.rawQuery('SELECT CATID FROM MT_PSL_CATEGORY WHERE CATID=?',[itemModel.CATID]);
    if (result.isNotEmpty) {
      await db.insert('MT_PSL_ITEMS', itemModel.toMap());
   } else {
      throw Exception('CATEGORY not found');
    }
  }
  Future<void> updateItem(ItemModel itemModel) async {
    final db = await database;
    await db.update(
      'MT_PSL_ITEMS',
      itemModel.toMap(),
      where: 'ITEMID = ?',
      whereArgs: [itemModel.ITEMID],
    );
  }
  Future<void> updateLicence(Licencemodel licencemodel) async {
    final db = await database;
    await db.update(
      'LICENCE',
      licencemodel.toMap(),
      where: 'ID = ?',
      whereArgs: [licencemodel.ID],
    );
  }
  Future<void> updateRATE(RatesModel ratesModel) async {
    final db = await database;
    await db.update(
      'MT_PSL_RATES',
      ratesModel.toMap(),
      where: 'SLNO = ?',
      whereArgs: [ratesModel.SLNO],
    );
  }


  Future<int> insertSales(SaleModel saleModel, List<SaledetailsModel> saledetailsModel) async {
    final db = await database;
    int maxSlno = await db.transaction((txn) async {
      int? maxSlno = Sqflite.firstIntValue(await txn.rawQuery('SELECT IFNULL(MAX(SLNO), 0) + 1 FROM MT_PSL_SALE WHERE BCODE = ?', [saleModel.BCODE]));
      int saleInsertResult = await txn.insert('MT_PSL_SALE', {
        'SLNO':maxSlno,
        'BCODE':saleModel.BCODE,
        'TDATE':saleModel.TDATE,
        'CCODE':saleModel.CCODE,
        'SALE_QTY':saleModel.SALE_QTY,
        'SALE_AMOUNT':saleModel.SALE_AMOUNT,
        'PAYMODE':saleModel.PAYMODE,
        'CRDATE':saleModel.CRDATE,
        'CREATEDBY':saleModel.CREATEDBY,
      });
      if (saleInsertResult > 0) {
        for(var saledetails in saledetailsModel)
          {
            await txn.insert('MT_PSL_SALEDETAILS', {
              'SLNO':maxSlno,
              'ITEMID':saledetails.ITEMID,
              'QTY':saledetails.QTY,
              'RATE':saledetails.RATE,
              'AMOUNT':saledetails.AMOUNT,
              'SGST':saledetails.SGST,
              'CGST':saledetails.CGST,
              'IGST':saledetails.IGST,
              'CRDATE':saledetails.CRDATE,
              'TAXRATE':saledetails.TAXRATE,
              'TAXAMOUNT':saledetails.TAXAMOUNT,
            });
          }
        return maxSlno!;
      } else {
        // Handle failure scenario
        return 0;
      }
    });
    return maxSlno;
  }

  Future<void> insertSale(SaleModel saleModel) async {
    final db = await database;
    await db.insert('MT_PSL_SALE', saleModel.toMap());
  }
  Future<void> insertSaleDetails(SaledetailsModel saledetailsModel) async {
    final db = await database;
    await db.insert('MT_PSL_SALEDETAILS', saledetailsModel.toMap());
  }
  Future<void> insertTRSale(TR_SaleModel tr_saleModel) async {
    final db = await database;
    await db.insert('TR_PSL_SALE', tr_saleModel.toMap());
  }

  Future<void> insertRates(RatesModel ratesModel) async {
    final db = await database;
    await db.insert('MT_PSL_RATES', ratesModel.toMap());
  }
  Future<void> insertLogtable(LogtableModel logtableModel) async {
    final db = await database;
    await db.insert('LOGTABLE', logtableModel.toMap());
  }

  Future<List<categorymodel>> getCategory() async {
    final db = await database;
    var result = await db.query("MT_PSL_CATEGORY");
    return List.generate(result.length, (i) {
      return categorymodel.fromMap(result[i]);
    });
  }
  Future<List<ItemModel>> getItem() async {
    final db = await database;
    var result = await db.query("MT_PSL_ITEMS");
    return List.generate(result.length, (i) {
      return ItemModel.fromMap(result[i]);
    });
  }
  Future<List<Licencemodel>> getLicence() async {
    final db = await database;
    var result = await db.query("LICENCE");
    return List.generate(result.length, (i) {
      return Licencemodel.fromMap(result[i]);
    });
  }
  Future<List<TR_SaleModel>> getTRSALES() async {
    final db = await database;
    var result = await db.query("TR_PSL_SALE");
    return List.generate(result.length, (i) {
      return TR_SaleModel.fromMap(result[i]);
    });
  }
  Future<List<RatesModel>> getRates() async {
    final db = await database;
    var result = await db.query("MT_PSL_RATES");
    return List.generate(result.length, (i) {
      return RatesModel.fromMap(result[i]);
    });
  }
  /*Future<int> updateCategory(Map<String, dynamic> row) async {
    final db = await database;
    return await db.update('MT_PSL_CATEGORY', row, where: 'CATID = ?', whereArgs: ['CATID']);
  }*/
  Future<void> updateCategory(categorymodel catmodel) async {
    final db = await database;
    await db.update(
      'MT_PSL_CATEGORY',
      catmodel.toMap(),
      where: 'CATID = ?',
      whereArgs: [catmodel.CATID],
    );
  }

  /*Future<int> updateItem(Map<String, dynamic> row) async {
    final db = await database;
    return await db.update('MT_PSL_ITEMS', row, where: 'ITEMID = ?', whereArgs: ['ITEMID']);
  }*/

  Future<void> deleteCategory(int CATID) async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM MT_PSL_ITEMS WHERE CATID=?',[CATID]);
    if(result.isNotEmpty && (result.first['COUNT(*)'] as int) > 0)
      {
        print('Category Cannot be deleted because Items Exists On this CATID');
        //throw Exception('Category Cannot be deleted because Items Exists On this CATID');
      }
    else{
      await db.delete('MT_PSL_CATEGORY', where: 'CATID = ?', whereArgs: [CATID]);
    }
  }
  Future<void> deleteItem(int ITEMID) async {
    final db = await database;
    await db.delete('MT_PSL_ITEMS', where: 'ITEMID = ?', whereArgs: [ITEMID]);
  }
  Future<void> deleteLicence(int id) async {
    final db = await database;
    await db.delete('LICENCE', where: 'ID = ?', whereArgs: [id]);
  }
  Future<void> deleteTRSale(int SLNO) async {
    final db = await database;
    await db.delete('TR_PSL_SALE', where: 'SLNO = ?', whereArgs: [SLNO]);
  }
  Future<void> deleteSale(int SLNO) async {
    final db = await database;
    final result =await db.delete('MT_PSL_SALEDETAILS', where: 'SLNO = ?', whereArgs: [SLNO]);
    await db.delete('MT_PSL_SALE', where: 'SLNO = ?', whereArgs: [SLNO]);
    if(result>0) {

    }
  }
  Future<void> deleteRates(int SLNO) async {
    final db = await database;
    await db.delete('MT_PSL_RATES', where: 'SLNO = ?', whereArgs: [SLNO]);
  }
  Future<String> getItemNamebasedOnITEMID(int ITEMID) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT I.ITEMNAME FROM MT_PSL_ITEMS I INNER JOIN MT_PSL_RATES R ON I.ITEMID=R.ITEMID WHERE R.ITEMID=?',
      [ITEMID],
    );
    if (result.isNotEmpty) {
      return result.first['ITEMNAME'] as String;
    } else {
      return ''; // Or you can throw an exception here
    }
  }
  Future<String> getuser(String username,String password) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT USERID,USERNAME,PASSWORD,ROLEID FROM USERS WHERE USERNAME=? AND PASSWORD=?',
      [username,password]
    );
    if (result.isNotEmpty) {
      return result.first['USERNAME'] as String;
    } else {
      return ''; // Or you can throw an exception here
    }
  }
  Future<String> isvalidlicence() async {
    final db = await database;
    final currentDate = DateTime.now();
    final result = await db.rawQuery(
        'SELECT ID,BNAME,FROMDATE,TODATE FROM LICENCE WHERE ? BETWEEN FROMDATE AND TODATE',
      [currentDate.toIso8601String()]
    );
    if (result.isNotEmpty) {
      return result.first['BNAME'] as String;
    } else {
      return 'Licence Expired, please conact : 9705966305'; // Or you can throw an exception here
    }
  }
  Future<String> getCATnamebasedOnCATID(int CATID) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT CATNAME FROM MT_PSL_CATEGORY WHERE CATID=?',
      [CATID],
    );
    if (result.isNotEmpty) {
      return result.first['CATNAME'] as String;
    } else {
      return ''; // Or you can throw an exception here
    }
  }
  //BETWEEN ? AND ?',[FDate,TDate]
  Future<List<Map<String, dynamic>>>getSaleData(String TDate) async {
    final db = await database;
    return db.rawQuery('SELECT SD.SLNO,S.TDATE,S.CCODE,S.SALE_QTY,S.SALE_AMOUNT,S.PAYMODE,SD.ITEMID,I.ITEMNAME,SD.QTY,SD.RATE,SD.AMOUNT,SD.SGST,SD.CGST,SD.IGST,SD.TAXRATE,SD.TAXAMOUNT FROM MT_PSL_SALE S INNER JOIN MT_PSL_SALEDETAILS SD ON S.SLNO=SD.SLNO INNER JOIN MT_PSL_ITEMS I ON SD.ITEMID=I.ITEMID WHERE S.TDATE=?',[TDate]);
  }
  Future<List<Map<String, dynamic>>>getfilterbydatesSaleData(String FDate,String TDate) async {
    final db = await database;
    return db.rawQuery('SELECT SD.SLNO,S.TDATE,S.CCODE,S.SALE_QTY,S.SALE_AMOUNT,S.PAYMODE,SD.ITEMID,I.ITEMNAME,SD.QTY,SD.RATE,SD.AMOUNT,SD.SGST,SD.CGST,SD.IGST,SD.TAXRATE,SD.TAXAMOUNT FROM MT_PSL_SALE S INNER JOIN MT_PSL_SALEDETAILS SD ON S.SLNO=SD.SLNO INNER JOIN MT_PSL_ITEMS I ON SD.ITEMID=I.ITEMID WHERE S.TDATE BETWEEN ? AND ?',[FDate,TDate]);
  }
  Future<List<Map<String, dynamic>>>loaditems(String TDate,String searchQuery) async {
    final db = await database;
    if(searchQuery!='')
      {
        return db.rawQuery('SELECT I.ITEMID,I.ITEMNAME,I.IMAGE,I.CATID,R.RATE,R.SGST,R.CGST,R.IGST,R.RATE+(R.RATE*(R.SGST+R.CGST+R.IGST)/100) AS SRATE,((R.SGST+R.CGST+R.IGST)/100) AS TRATE FROM MT_PSL_ITEMS I INNER JOIN MT_PSL_RATES R ON I.ITEMID=R.ITEMID WHERE ? BETWEEN R.FROMDATE AND R.TODATE AND I.ITEMNAME like ?',
            [TDate,'%$searchQuery%']);
      }
    else{
      return db.rawQuery('SELECT I.ITEMID,I.ITEMNAME,I.IMAGE,I.CATID,R.RATE,R.SGST,R.CGST,R.IGST,R.RATE+(R.RATE*(R.SGST+R.CGST+R.IGST)/100) AS SRATE,((R.SGST+R.CGST+R.IGST)/100) AS TRATE FROM MT_PSL_ITEMS I INNER JOIN MT_PSL_RATES R ON I.ITEMID=R.ITEMID WHERE ? BETWEEN R.FROMDATE AND R.TODATE',[TDate]);
    }
  }
  Future<List<Map<String, dynamic>>>getTRSale(String TDate) async {
    final db = await database;
    return db.rawQuery('SELECT S.SLNO,S.ITEMID,I.IMAGE,I.ITEMNAME,I.CATID,C.CATNAME,S.TDATE,S.CCODE,S.QTY,S.RATE,S.AMOUNT,S.SGST,S.CGST,S.IGST,S.TAXRATE,S.TAXAMOUNT,S.PAYMODE FROM MT_PSL_ITEMS I INNER JOIN TR_PSL_SALE S ON I.ITEMID=S.ITEMID INNER JOIN MT_PSL_CATEGORY C ON C.CATID=I.CATID WHERE S.TDATE=?',[TDate]);
  }
  Future<List<Map<String, dynamic>>>getfilterbydatesTRSale(String FDate,String TDate) async {
    final db = await database;
    return db.rawQuery('SELECT S.SLNO,S.ITEMID,I.IMAGE,I.ITEMNAME,I.CATID,C.CATNAME,S.TDATE,S.CCODE,S.QTY,S.RATE,S.AMOUNT,S.SGST,S.CGST,S.IGST,S.TAXRATE,S.TAXAMOUNT,S.PAYMODE FROM MT_PSL_ITEMS I INNER JOIN TR_PSL_SALE S ON I.ITEMID=S.ITEMID INNER JOIN MT_PSL_CATEGORY C ON C.CATID=I.CATID WHERE S.TDATE BETWEEN ? AND ?',[FDate,TDate]);
  }
  Future<List<Map<String, dynamic>>>getlistdata(String TDate) async {
    final db = await database;
    return db.rawQuery('SELECT SLNO,BCODE,TDATE,CCODE,SALE_QTY,SALE_AMOUNT,PAYMODE,CRDATE,CREATEDBY FROM MT_PSL_SALE WHERE TDATE=?',[TDate]);
  }
  Future<List<Map<String, dynamic>>>getlistdatadetails(String TDate) async {
    final db = await database;
    return db.rawQuery('SELECT SD.SLNO,SD.ITEMID,I.ITEMNAME,SD.QTY,SD.RATE,SD.AMOUNT,SD.SGST,SD.CGST,SD.IGST,SD.CRDATE,SD.TAXRATE,SD.TAXAMOUNT,SD.CREATEDBY FROM MT_PSL_SALEDETAILS SD INNER JOIN MT_PSL_SALE S ON S.SLNO=SD.SLNO INNER JOIN MT_PSL_ITEMS I ON I.ITEMID=SD.ITEMID WHERE S.TDATE=?',[TDate]);
  }
  Future<List<Map<String, dynamic>>>gettokenprint(int Slno) async {
    final db = await database;
    return db.rawQuery('SELECT SD.SLNO,L.BNAME,L.ADDRESS,L.PHONENO,SD.ITEMID,I.ITEMNAME,S.TDATE,SD.QTY,SD.RATE,SD.AMOUNT,SD.SGST,SD.CGST,SD.IGST,SD.CRDATE,SD.TAXRATE,SD.TAXAMOUNT,SD.CREATEDBY FROM MT_PSL_SALEDETAILS SD INNER JOIN MT_PSL_SALE S ON S.SLNO=SD.SLNO INNER JOIN MT_PSL_ITEMS I ON I.ITEMID=SD.ITEMID INNER JOIN LICENCE L ON S.BCODE=L.ID WHERE S.SLNO=?',[Slno]);
  }
}
