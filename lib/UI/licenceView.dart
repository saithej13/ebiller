import 'package:ebiller2/models/Licencemodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:sqflite/sqflite.dart';
import '../DatabaseHelper.dart';
import  'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:share/share.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../Home.dart';
class licenceView extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Item Master',
      home: LicenceMaster(),
    );
  }
}

class LicenceMaster extends StatefulWidget {

  const LicenceMaster({Key? key}) : super(key: key);

  @override
  _licence createState() => _licence();

}
DatabaseHelper databaseHelper = DatabaseHelper();
class _licence extends State<LicenceMaster> {
  List<Licencemodel> Licencem = [];
  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now();
  DateFormat format = DateFormat('dd-MM-yyyy');
  final _BNAME = TextEditingController();
  final _Address = TextEditingController();
  final _phoneno = TextEditingController();
  String RestorePath ="";
  int? _ID;
  @override
  void initState() {
    super.initState();
    databaseHelper.getLicence().then((list) {
      setState(() {
        Licencem = list;
      });
    });
  }
  Future<void> backupDatabase() async {
    String databasesPath = await getDatabasesPath();
    String sourcePath = path.join(databasesPath, 'ebiller.db');
    String timestamp = DateTime.now().toString();
    Directory? backupDir = await getExternalStorageDirectory();
    String backupPath = path.join(backupDir!.path, 'ebiller_$timestamp.db');
    await File(sourcePath).copy(backupPath);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Backup Success'),
          content: Text('Backup Completed , Backup path : $backupPath'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Share.shareFiles([backupPath]);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }


    Future<void> restoreTable(Database database, String tableName) async {
      List<Map<String, dynamic>> tableSchema =
      await database.rawQuery('PRAGMA table_info($tableName)');
      String createTableQuery = generateCreateTableQuery(tableName, tableSchema);
      await database.execute(createTableQuery);
      List<Map<String, dynamic>> tableData =
      await database.query(tableName);
      await database.transaction((txn) async {
        for (var row in tableData) {
          await txn.insert(tableName, row);
        }
      });
    }

  void openFileManager() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      PlatformFile file = result.files.first;
      String filePath = file.path!;
      RestorePath = filePath;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirm Restore'),
            content: Text('Are you Sure to Restore the DB path:$RestorePath'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  restoreBackup();
                },
                child: Text('Restore'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              ),
            ],
          );
        },
      );
    } else {
      print('No file selected');
    }
  }

Future<void> restoreBackup() async {
  String backupPath = '$RestorePath';
  String databasesPath = await getDatabasesPath();
  String restorePath = path.join(databasesPath, 'ebiller.db');
  await deleteDatabase(restorePath);
  await File(backupPath).copy(restorePath);
  Database database = await openDatabase(restorePath);
  List<Map<String, dynamic>> tables = await database.query('sqlite_master',
      where: 'type = ?',
      whereArgs: ['table'],
      columns: ['name']);
  for (var table in tables) {
    String tableName = table['name'];
    await restoreTable(database, tableName);
  }
  database.close();
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('DB Restored'),
        content: Text('Restore Completed, \r\n App needs to be Restarted'),
        actions: [
          TextButton(
            child: Text('Restart'),
            onPressed: () {
              Navigator.of(context).pop();
              if (Platform.isAndroid) {
                SystemNavigator.pop();
              } else if (Platform.isIOS) {
                exit(0);
              }
            },
          ),
        ],
      );
    },
  );
}
  String generateCreateTableQuery(String tableName, List<Map<String, dynamic>> tableSchema) {
    String query = 'CREATE TABLE IF NOT EXISTS $tableName (';
    for (var column in tableSchema) {
      String columnName = column['name'];
      String columnType = column['type'];
      bool isPrimaryKey = column['pk'] == 1;
      query += '$columnName $columnType';
      if (isPrimaryKey) {
        query += ' PRIMARY KEY';
      }
      query += ',';
    }
    query = query.trim();
    query = query.substring(0, query.length - 1);
    query += ')';
    return query;
  }
  void _refreshLicenceList() {
    databaseHelper.getLicence().then((list) {
      setState(() {
        Licencem = list;
      });
    });
  }
  late String BNAME="";
  late String Address="";
  late String Phoneno="";
  String _buttonText = "SAVE";
  @override
  void dispose() {
    super.dispose();
  }
  Future<void> gotohome() async {
    Navigator.push(context, MaterialPageRoute(builder: (_) => Home()));
  }

  //show popup dialog
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.indigo,
        appBar: AppBar(
          title: Text('Configuration'),
          actions: [
            IconButton(
              icon: Icon(Icons.backup),
              onPressed:(){
              backupDatabase();
            },
            ),
            IconButton(
              icon: Icon(Icons.restore),
              onPressed:(){
                  openFileManager();
              },
            ),
          ],
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: FutureBuilder<List<Licencemodel>>(
                future: databaseHelper.getLicence(),
                builder: (BuildContext context,AsyncSnapshot<List<Licencemodel>> snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  return ListView.builder(
                    itemCount: Licencem.length,
                    itemBuilder: (context, index) {
                      return Slidable(
                        actionPane: SlidableDrawerActionPane(),
                        actionExtentRatio: 0.25,
                        child: ListTile(
                          title: Text(Licencem[index].BNAME,style: TextStyle(fontSize: 18,color: Colors.white,fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text("Licence Valid from : "+Licencem[index].FROMDATE,style:TextStyle(fontSize: 18,color: Colors.white),),
                              Text("Licence Valid to : "+Licencem[index].TODATE,style:TextStyle(fontSize: 18,color: Colors.white),),
                            ],
                          ),
                        ),
                        actions: <Widget>[
                          IconSlideAction(
                            caption: 'Edit',
                            color: Colors.blue,
                            icon: Icons.edit_outlined,
                            onTap: () {
                              _ID=Licencem[index].ID;
                              _BNAME.text=Licencem[index].BNAME;
                              _Address.text=Licencem[index].ADDRESS;
                              _phoneno.text=Licencem[index].PHONENO;
                              setState(() {
                                _fromDate = format.parse(Licencem[index].FROMDATE);
                                _toDate = format.parse(Licencem[index].TODATE);
                                _buttonText="UPDATE";
                              });
                            },
                          ),
                        ],
                        secondaryActions: <Widget>[
                          IconSlideAction(
                            caption: 'Delete',
                            color: Colors.red,
                            icon: Icons.delete,
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Delete'),
                                    content: Text('are you sure to delete'),
                                    actions: [
                                      TextButton(
                                        child: Text('Cancel'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      TextButton(
                                        child: Text('Yes'),
                                        onPressed: () {
                                          databaseHelper.deleteLicence(Licencem[index].ID!);
                                          Navigator.of(context).pop();
                                          _refreshLicenceList();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );

                            },
                          ),
                        ],
                      );

                    },
                  );
                },
              ),
            ),
            Container(
                color: Colors.indigo,
                padding: EdgeInsets.all(1)
            ),
            Container(
              color: Colors.white,
              padding: EdgeInsets.only(left: 15, right: 15,top: 15,bottom: 5),
              child: TextField(
                controller: _BNAME,
                //set password controller
                style: TextStyle(color: Colors.indigo[700], fontSize: 20),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.villa),
                  border: OutlineInputBorder(),
                  labelText: "Business Name",
                ),
                onChanged: (value) {
                  // change password text
                  BNAME = value;
                },
              ),
            ),
            Container(
              color: Colors.white,
              padding: EdgeInsets.only(left: 15, right: 15,top: 5,bottom: 5),
              child: TextField(
                controller: _Address,
                //set password controller
                style: TextStyle(color: Colors.indigo[700], fontSize: 20),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.villa),
                  border: OutlineInputBorder(),
                  labelText: "Address",
                ),
                onChanged: (value) {
                  // change password text
                  Address = value;
                },
              ),
            ),
            Container(
              color: Colors.white,
              padding: EdgeInsets.only(left: 15, right: 15,top: 5,bottom: 10),
              child: TextField(
                controller: _phoneno,
                //set password controller
                style: TextStyle(color: Colors.indigo[700], fontSize: 20),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.villa),
                  border: OutlineInputBorder(),
                  labelText: "Phone No.",
                ),
                onChanged: (value) {
                  // change password text
                  Phoneno = value;
                },
              ),
            ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      padding:EdgeInsets.only(left: 2,top: 2,right: 2,bottom: 10),
                      child: Column(
                        //crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () async {
                              DateTime? date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (date != null) {
                                setState(() {
                                  _fromDate = date;
                                });
                              }
                            },
                            child: IgnorePointer(
                              child: TextFormField(
                                controller: TextEditingController(
                                  text: _fromDate != null
                                      ? DateFormat.yMd().format(_fromDate)
                                      : '',
                                ),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: "From Date",
                                  hintText: 'Select Date',
                                  prefixIcon: Icon(Icons.date_range_sharp),
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Select Date';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      padding: EdgeInsets.only(left: 2,top: 2,right: 2,bottom: 10),
                      child: Column(
                        //crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () async {
                              DateTime? date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (date != null) {
                                setState(() {
                                  _toDate = date;
                                });
                              }
                            },
                            child: IgnorePointer(
                              child: TextFormField(
                                controller: TextEditingController(
                                  text: _toDate != null
                                      ? DateFormat.yMd().format(_toDate)
                                      : '',
                                ),
                                decoration: InputDecoration(
                                  labelText: "To Date",
                                  hintText: 'Select Date',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.date_range_sharp),
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Select Date';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            Container(
              padding: EdgeInsets.all(5),
              child: SizedBox(
                height: 40,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async{
                    try {
                      print(_fromDate);
                      print(_toDate);
                      if(_fromDate.toString().isNotEmpty&&_toDate.toString().isNotEmpty) {
                        var dbHelper = DatabaseHelper();
                        if(_buttonText=="UPDATE")
                        {
                          var UPDATElicence = Licencemodel(ID: 1,BNAME:_BNAME.text,FROMDATE:format.format(_fromDate),
                              TODATE:format.format(_toDate),ADDRESS: _Address.text,PHONENO: _phoneno.text);
                          await dbHelper.updateLicence(UPDATElicence);
                        }
                        else{
                          var INSERTlicence = Licencemodel(ID: 1,BNAME:_BNAME.text,FROMDATE:format.format(_fromDate),
                              TODATE:format.format(_toDate),ADDRESS: _Address.text,PHONENO: _phoneno.text);
                          await dbHelper.insertLicence(INSERTlicence);
                        }
                        _refreshLicenceList();
                      }
                      else{
                        throw Exception('please check the fields');
                      }
                    }
                    catch(e){
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Error'),
                            content: Text('An error occurred: $e'),
                            actions: [
                              TextButton(
                                child: Text('OK'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  child: Text(
                    _buttonText,
                    style: TextStyle(fontSize: 20,color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.indigoAccent,
                    onPrimary: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ),
            ),

          ],
        )
    );
  }
}
