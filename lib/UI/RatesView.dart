import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:ebiller2/models/ItemModel.dart';
import 'package:ebiller2/models/RatesModel.dart';
import 'package:sqflite/sqflite.dart';
import '../DatabaseHelper.dart';
import  'package:intl/intl.dart';
import 'package:ebiller2/models/categorymodel.dart';

import '../Home.dart';
class RatesView extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rates Master',
      home: RateMaster(),
    );
  }
}

class RateMaster extends StatefulWidget {

  const RateMaster({Key? key}) : super(key: key);

  @override
  _Rate_Entery createState() => _Rate_Entery();

}
DatabaseHelper databaseHelper = DatabaseHelper();
class _Rate_Entery extends State<RateMaster> {
  List<ItemModel> MT_PSL_ITEMS = [];
  List<categorymodel> MT_PSL_CATEGORY = [];
  List<RatesModel> MT_PSL_RATES =[];
  @override
  void initState() {
    super.initState();
    _getItemList();
    databaseHelper.getRates().then((list) {
      setState(() {
        MT_PSL_RATES  = list;
      });
    });
  }
  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now();
  Future<void> _selectfromDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fromDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _fromDate) {
      setState(() {
        _fromDate = picked;
      });
    }
  }
  Future<void> _selecttoDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _toDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _toDate) {
      setState(() {
        _toDate = picked;
      });
    }
  }
  void _refreshRatesList() {
    databaseHelper.getRates().then((list) {
      setState(() {
        MT_PSL_RATES = list;
      });
    });
  }
  late bool ISACTIVE;
  late String ITEMNAME, CREATEDBY;
  String? _selectedUOM,_selectedPKG,_selectedCATID,_ItemnamebasedonITEMID;
  int? _ITEMID;
  String _buttonText = "SAVE";
  int?  _SLNOFORUPDATE;
  DateFormat format = DateFormat('dd-MM-yyyy');
  double? _RATE,_SGST,_CGST,_IGST;
  final _Ratecontroller = TextEditingController();
  final _CGSTcontroller = TextEditingController();
  final _SGSTcontroller = TextEditingController();
  final _IGSTcontroller = TextEditingController();
  List<String> itemsUOM = [
    'KGS',
    'NOS',
    'LTRS',
    'BOXS',
  ];
  List<String> itemsPKG = [
    'TUBS',
    'CANS',
    'OTHERS',
  ];
  @override
  void dispose() {
    _Ratecontroller.dispose();
    _CGSTcontroller.dispose();
    _SGSTcontroller.dispose();
    _IGSTcontroller.dispose();
    super.dispose();
  }
  void _getItemList() async {
    databaseHelper.getItem().then((list) {
      setState(() {
        MT_PSL_ITEMS = list;
      });
    });
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
          title: Text('RATES MASTER'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: FutureBuilder<List<RatesModel>>(
                future: databaseHelper.getRates(),
                builder: (BuildContext context,AsyncSnapshot<List<RatesModel>> snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  return ListView.builder(
                    itemCount: MT_PSL_RATES.length,
                    itemBuilder: (context, index) {
                      return Slidable(
                        actionPane: SlidableDrawerActionPane(),
                        actionExtentRatio: 0.25,
                        child: ListTile(
                          title:  FutureBuilder<String>(
                      future: databaseHelper.getItemNamebasedOnITEMID(MT_PSL_RATES[index].ITEMID),
                      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                      if (snapshot.hasData) {
                      return Text(snapshot.data!,style: TextStyle(fontSize: 18,color: Colors.white));
                      } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}',style: TextStyle(fontSize: 18,color: Colors.white));
                      } else {
                      return Text('Loading...',style: TextStyle(fontSize: 18,color: Colors.white));
                      }
                      },
                          ),
                          subtitle: Text(MT_PSL_RATES[index].RATE.toString(),style: TextStyle(fontSize: 18,color: Colors.white)),
                        ),
                        actions: <Widget>[
                          IconSlideAction(
                            caption: 'Edit',
                            color: Colors.blue,
                            icon: Icons.edit_outlined,
                            onTap: () {
                              _SLNOFORUPDATE=MT_PSL_RATES[index].SLNO;
                              _ITEMID=MT_PSL_RATES[index].ITEMID;
                              setState(() {
                                _Ratecontroller.text=MT_PSL_RATES[index].RATE.toString();
                                _RATE=MT_PSL_RATES[index].RATE;
                                _CGSTcontroller.text=MT_PSL_RATES[index].CGST.toString();
                                _CGST=MT_PSL_RATES[index].CGST;
                                _SGSTcontroller.text=MT_PSL_RATES[index].SGST.toString();
                                _SGST=MT_PSL_RATES[index].SGST;
                                _IGSTcontroller.text=MT_PSL_RATES[index].IGST.toString();
                                _IGST=MT_PSL_RATES[index].IGST;
                                _fromDate=format.parse(MT_PSL_RATES[index].FROMDATE);
                                _toDate = format.parse(MT_PSL_RATES[index].TODATE);
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
                                          databaseHelper.deleteRates(MT_PSL_RATES[index].SLNO!);
                                          Navigator.of(context).pop();
                                          _refreshRatesList();
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
              padding: EdgeInsets.only(left: 15, right: 15, top: 10,bottom: 5),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child:Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 1.0),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    child: DropdownButtonHideUnderline(
                      child: ButtonTheme(
                        alignedDropdown: true,
                        child: DropdownButton<int>(
                          hint:Text('--Select Item--'),
                          value:  _ITEMID != null ? _ITEMID! : null,
                          onChanged: (value) {
                            setState(() {
                              _ITEMID = value;
                            });
                          },
                          items: MT_PSL_ITEMS.map((item) {
                            return DropdownMenuItem<int>(
                              child: new Text(item.ITEMNAME),
                              value: item.ITEMID,
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:[
                Expanded(
                  child:
            Container(
              color: Colors.white,
              padding: EdgeInsets.only(left: 2,top: 2,right: 2,bottom: 10),
              child: TextField(
                keyboardType: TextInputType.number,
                controller: _Ratecontroller,
                //set password controller
                style: TextStyle(color: Colors.indigo[700], fontSize: 20),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.monetization_on),
                  border: OutlineInputBorder(),
                  labelText: "RATE",
                ),
                onChanged: (value) {
                  // change password text
                  if(value.toString().isNotEmpty){
                    _RATE = double.tryParse(value);
                  }
                },
              ),
             ),
    ),
    Expanded(
    child:
            Container(
              color: Colors.white,
              padding: EdgeInsets.only(left: 2,top: 2,right: 2,bottom: 10),
              child: TextField(
                keyboardType: TextInputType.number,
                controller: _CGSTcontroller,
                //set password controller
                style: TextStyle(color: Colors.indigo[700], fontSize: 20),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.villa),
                  border: OutlineInputBorder(),
                  labelText: "CGST",
                ),
                onChanged: (value) {
                  // change password text
                  if(value.toString().isNotEmpty){
                    _CGST = double.parse(value.toString());
                  }
                },
              ),
            ),
    ),
              ],
            ),

            Row(
              children:[
                Expanded(
                  child:
            Container(
              color: Colors.white,
              padding: EdgeInsets.only(left: 2,top: 2,right: 2,bottom: 10),
              child: TextField(
                keyboardType: TextInputType.number,
                controller: _SGSTcontroller,
                //set password controller
                style: TextStyle(color: Colors.indigo[700], fontSize: 20),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.villa),
                  border: OutlineInputBorder(),
                  labelText: "SGST",
                ),
                onChanged: (value) {
                  // change password text
                  if(value.toString().isNotEmpty)
                    {
                      _SGST = double.parse(value.toString());
                    }
                },
              ),
            ),
    ),
    Expanded(
    child:
            Container(
              color: Colors.white,
              padding: EdgeInsets.only(left: 2,top: 2,right: 2,bottom: 10),
              child: TextField(
                keyboardType: TextInputType.number,
                controller: _IGSTcontroller,
                //set password controller
                style: TextStyle(color: Colors.indigo[700], fontSize: 20),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.villa),
                  border: OutlineInputBorder(),
                  labelText: "IGST",
                ),
                onChanged: (value) {
                  // change password text
                  if(value.toString().isNotEmpty){
                    _IGST = double.parse(value);
                  }
                },
              ),
            ),
    ),
    ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    color: Colors.white,
                    padding: EdgeInsets.only(left: 2,top: 2,right: 2,bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                      crossAxisAlignment: CrossAxisAlignment.start,
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
    Row(
    children:[
    Expanded(
    child:
            Container(
              padding: EdgeInsets.all(5),
              child: SizedBox(
                height: 40,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async{
                    try {
                      if(_ITEMID!=null&&_IGSTcontroller.text.isNotEmpty&&_SGSTcontroller.text.isNotEmpty&&_CGSTcontroller.text.isNotEmpty){
                      var dbHelper = DatabaseHelper();
                      //SLNO INTEGER PRIMARY KEY AUTOINCREMENT,ITEMID INTEGER,RATE NUMERIC(18,2),SGST NUMERIC(18,2),CGST NUMERIC(18,2),
                      // IGST NUMERIC(18,2),CRDATE DATETIME,FROMDATE DATETIME,TODATE DATETIME,CREATEDBY VARCHAR(50) NULL)');
                      if(_buttonText=="UPDATE")
                        {
                          var UPDATEitem = RatesModel(SLNO:_SLNOFORUPDATE,
                              ITEMID: _ITEMID!,
                              RATE: _RATE!,
                              SGST: _SGST!,
                              CGST: _CGST!,
                              IGST: _IGST!,
                              CRDATE: format.format(DateTime.now()),
                              FROMDATE: format.format(_fromDate),
                              TODATE: format.format(_toDate),
                              CREATEDBY: "ADMIN");
                          await dbHelper.updateRATE(UPDATEitem);
                        }
                      else{
                        var item = RatesModel(ITEMID: _ITEMID!,
                            RATE: _RATE!,
                            SGST: _SGST!,
                            CGST: _CGST!,
                            IGST: _IGST!,
                            CRDATE: format.format(DateTime.now()),
                            FROMDATE: format.format(_fromDate),
                            TODATE: format.format(_toDate),
                            CREATEDBY: "ADMIN");
                        await dbHelper.insertRates(item);
                      }
                      _refreshRatesList();
                      setState(() {
                        _ITEMID=null;
                        _Ratecontroller.text="";
                        _CGSTcontroller.text="";
                        _SGSTcontroller.text="";
                        _IGSTcontroller.text="";
                        _fromDate=format.parse(format.format(DateTime.now()));
                        _toDate=format.parse(format.format(DateTime.now()));
                        _buttonText="SAVE";
                      });
    }
    else{
    throw Exception('please check the fields');
    }
                    }
                    on DatabaseException catch (e){
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
                    catch (e) {
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
    ),
    ],
    ),
          ],
        )
    );
  }
}
