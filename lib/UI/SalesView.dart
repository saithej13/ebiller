import 'package:ebiller2/UI/tabbed.dart';
import 'package:ebiller2/models/Item.dart';
import 'package:ebiller2/models/Licencemodel.dart';
import 'package:ebiller2/models/SaleModel.dart';
import 'package:ebiller2/models/SaledetailsModel.dart';
import 'package:ebiller2/models/TR_SaleModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'dart:io';
import 'package:ebiller2/models/printerenum.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ebiller2/models/ItemModel.dart';
import 'package:ebiller2/models/RatesModel.dart';
import 'package:sqflite/sqflite.dart';
import '../DatabaseHelper.dart';
import  'package:intl/intl.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:ebiller2/models/categorymodel.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
//import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import '../Home.dart';

class SalesView extends StatefulWidget{

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sales',
      home: Sales(),
    );
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }
}

class Sales extends StatefulWidget {

  const Sales({Key? key}) : super(key: key);

  @override
  _Sales_Entery createState() => _Sales_Entery();

}
DatabaseHelper databaseHelper = DatabaseHelper();
class _Sales_Entery extends State<Sales> {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  bool _isSortOptionsVisible = false;

  void _toggleSortOptions() {
    setState(() {
      _isSortOptionsVisible = !_isSortOptionsVisible;
    });
  }
  List<ItemModel> MT_PSL_ITEMS = [];
  List<Item> itemList=[];
  List<Licencemodel> Licence = [];
  List<categorymodel> MT_PSL_CATEGORY = [];
  List<RatesModel> MT_PSL_RATES =[];
  List<TR_SaleModel> TR_PSL_SALES =[];
  List<Map<String, dynamic>> _data = [];
  List<Map<String, dynamic>> _saledata = [];
  List<Map<String, dynamic>> _items = [];
  List<SaledetailsModel> _saledetailsarry=[];
  List<SaleModel> _salesarry=[];
  List<Map<String, dynamic>> _saledetailslistview=[];
  List<Map<String, dynamic>> _salelistview=[];
  List<Map<String, dynamic>> _printdata=[];
  late double totalSum=0;
  final key = GlobalKey();
  @override
  void initState() {
    super.initState();
    _refreshItemList();
    _loadLicence();
    _refreshListview(format.format(DateTime.now()));
    _loadData(DateFormat('dd-MM-yyyy').format(DateTime.now()),);
    _loaditems(DateFormat('dd-MM-yyyy').format(DateTime.now()),'');
  }
  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now();
  Future<void> _selectfromDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime maxDate = now;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fromDate,
      firstDate: DateTime(now.year - 1, now.month, now.day),
      lastDate: maxDate,
    );
    if (picked != null && picked != _fromDate) {
      setState(() {
        _fromDate = picked;
      });
    }
  }
  void _refreshItemList() {
    databaseHelper.getItem().then((list) {
      setState(() {
        MT_PSL_ITEMS = list;
      });
    });
  }
  Future<void> _refreshListview (TDate) async{
    try {
    final data = await databaseHelper.getlistdata(TDate);
    final Sdata = await databaseHelper.getlistdatadetails(TDate);
    double sum = 0;
    for (final item in data) {
      sum += item['SALE_AMOUNT'];
    }
    setState(() {
      _salelistview = data;
      _saledetailslistview = Sdata;
      totalSum = sum;
      itemList = combineData(_salelistview, _saledetailslistview);
    });
    } catch (error) {
      // Handle any errors that occur during data retrieval
      print('Error refreshing: $error');
    }
  }
  //gettokenprint
  Future<void> _PRINTTOKEN(SLNO) async {
    final data = await databaseHelper.gettokenprint(SLNO);
      setState(() {
        _printdata = data;
      });
  }

  List<Item> combineData(List<Map<String, dynamic>> salelistview,List<Map<String, dynamic>> saledetailslistview) {
    List<Item> items = [];
    for (var parentData in salelistview) {
      Map<String, dynamic> parent = {};
      parentData.forEach((key, value) {
        parent[key] = parentData[key];
      });
      List<Map<String, dynamic>> children = [];
      for (var childData in saledetailslistview) {
        if (childData['SLNO'] == parentData['SLNO']) {
          Map<String, dynamic> child = {};
          childData.forEach((key, value) {
            child[key] = childData[key];
          });
          children.add(child);
        }
      }
      Item item = Item(
        parentData: parent,
        childData: children,
      );
      items.add(item);
    }
    return items;
  }

  Future<void> _selecttoDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime minDate = now;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _toDate,
      firstDate: minDate,
      lastDate: DateTime(now.year + 1, now.month, now.day),
    );
    if (picked != null && picked != _toDate) {
      setState(() {
        _toDate = picked;
      });
    }
  }
  String getPlainText(Widget text) {
    if (text is RichText) {
      RichText richText = text;
      return richText.text.toPlainText();
    }
    return '';
  }
  Future<void> _loadLicence() async {
    final data = await databaseHelper.getLicence();
    setState(() {
      Licence = data;
    });
  }
  Future<void> _loadData(TDate) async {
    final data = await databaseHelper.getSaleData(TDate);
    setState(() {
      _data = data;
    });
  }

  Future<void> _getfilterTRSaledata(FDate,TDate) async {
    final data = await databaseHelper.getfilterbydatesSaleData(FDate,TDate);
    double sum = 0;
    for (final item in data) {
      sum += item['AMOUNT'];
    }
    setState(() {
      _saledata = data;
      totalSum = sum;
    });
  }
  
  Future<void> _loaditems(TDate,searchQuery) async {
    final data = await databaseHelper.loaditems(TDate,searchQuery);
    setState(() {
      _items = data;
    });
  }
  late bool ISACTIVE;
  late String ITEMNAME, CREATEDBY;
  late String fromdate="";
  late String todate="";
  String _switchText = "PayMode Cash";
  String? _selectedUOM,_selectedPKG,_selectedCATID,_ItemnamebasedonITEMID;
  int? _ITEMID;
  //double _QTY=0,_AMT=0;
  DateFormat format = DateFormat('dd-MM-yyyy');
  double? _RATE,_SGST,_CGST,_IGST;
  bool _isSwitched = false;
  TextEditingController _QTYcontroller = TextEditingController();
  final _Ratecontroller = TextEditingController();
  final _CGSTcontroller = TextEditingController();
  final _SGSTcontroller = TextEditingController();
  final _IGSTcontroller = TextEditingController();

  @override
  void dispose() {
    _Ratecontroller.dispose();
    _CGSTcontroller.dispose();
    _SGSTcontroller.dispose();
    _IGSTcontroller.dispose();
    super.dispose();
  }


  Future<void> gotohome() async {
    Navigator.push(context, MaterialPageRoute(builder: (_) => Home()));
  }
 String _centerText(String content,int totalWidth){
   final int padding = (totalWidth - content.length) ~/ 2;
   final String centeredText = ' ' * padding + content;
   return centeredText;
 }
 String _fourcolumnText (String col1,String col2,String col3, String col4,int totalWidth){
   String formattedText4='';
   String formattedText3='';
   String formattedText2='';
   String formattedText1='';
   // if(col4.length>6)
   //   {
   //     final int columnWidth = 32 ~/ 4;
   //     formattedText1 = col1.padRight(columnWidth+6);
   //     formattedText2 = col2.padRight(columnWidth-2);
   //     formattedText3 = col3.padRight(columnWidth-2);
   //     formattedText4 = col4.padRight(columnWidth-2);
   //   }
   // else{
     final int columnWidth = totalWidth ~/ 4;
     formattedText1 = col1.padRight(columnWidth+6);
     formattedText2 = col2.padRight(columnWidth-2);
     formattedText3 = col3.padRight(columnWidth-2);
     formattedText4 = col4.padRight(columnWidth-2);
   //}

   final String row = formattedText1 + formattedText2 + formattedText3 + formattedText4;
   return row;
 }


  String _applyAlignment(String content, PosAlign align) {
    switch (align) {
      case PosAlign.left:
        return content; // No alignment needed for left-aligned text
      case PosAlign.center:
        return '\u001B[center]$content\u001B[align]';
      case PosAlign.right:
        return '\u001B[right]$content\u001B[align]';
    }
  }

  String _applyTextSize(String content, PosTextSize size) {
    switch (size) {
      case PosTextSize.size1:
        return '\u001B[1T$content';
      case PosTextSize.size2:
        return '\u001B[2T$content';
      case PosTextSize.size3:
        return '\u001B[3T$content';
      default:
        return content; // Handle any other possible values
    }
  }

  String _applyTextWidth(String content, PosTextSize width) {
    switch (width) {
      case PosTextSize.size1:
        return '\u001B[1W$content';
      case PosTextSize.size2:
        return '\u001B[2W$content';
      case PosTextSize.size3:
        return '\u001B[3W$content';
      default:
        return content;
    }
  }
  //show popup dialog
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo,
        appBar: AppBar(
          title: Text('Sales'),
          actions: [
            IconButton(
              icon: Icon(Icons.sort_sharp),
              // onPressed:() {
              //   //nothing
              //   Navigator.push(context, MaterialPageRoute(builder: (_) => TabbedDialog()));
              // }
              onPressed:() {
                _toggleSortOptions();
              }
            ),
          ],
          // iconTheme: IconThemeData(
          //   color: Colors.white,
          // ),

        ),
        body:  Stack(
          children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                padding: EdgeInsets.only(bottom: 120),
                children: List.generate(_items.length, (index) {
                  //final item = MT_PSL_ITEMS[index];
                  final item = _items[index];
                  return GestureDetector(
                    onTap: () {
                      //popup with selected item
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          double _QTY = 0;
                          double _AMT = 0;
                          double _TAX =0;
                          return AlertDialog(
                            contentPadding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                            //title: Text("tabname",style: TextStyle(fontSize: 28,fontWeight: FontWeight.bold)),
                              content:FractionallySizedBox(
                            heightFactor: 0.5, // Set the height factor to 0.5 for half of the screen height
                            child: DefaultTabController(
                              length: 2,
                              child: SizedBox(
                                //width: double.maxFinite,
                              width: double.maxFinite,
                              child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                              TabBar(
                              tabs: [
                              Tab(child: Text(
                                'Entry',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo,
                                ),
                              ),),
                          Tab(child: Text(
                            'Checkout',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo,
                            ),
                          ),),
                          ],
                          ),
                          Expanded(
                          child: TabBarView(
                          children: [StatefulBuilder(
    builder: (BuildContext context, StateSetter setState) {
      return
        Container(
          key: key,
          child:
          SingleChildScrollView(
          child:
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(item['ITEMNAME'].toString(),style: TextStyle(fontSize: 28,fontWeight: FontWeight.bold)),
              Text("Rate: " + item['SRATE'].toString(),style: TextStyle(fontSize: 20)),
              //Image.asset('assets/cattle.png'),
              Row(
                children: [
                  Expanded(
                    child:
                    Container(
                      //child:Image.asset('assets/cattle.png'),
                      color: Colors.white,
                      padding: EdgeInsets.all(7),
                      child: TextField(
                        keyboardType: TextInputType.number,
                        //controller: _QTYcontroller,
                        style: TextStyle(
                            color: Colors.indigo[700], fontSize: 20),
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.monetization_on),
                          border: OutlineInputBorder(),
                          labelText: "QTY",
                        ),
                        onChanged: (value) {
                          double qty = double.tryParse(value) ?? 0.0;
                          double amt = item['SRATE'] * qty;
                          double tax = item['TRATE'] * qty;
                          setState(() {
                            _QTY = qty;
                            _AMT = amt;
                            _TAX = tax;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                  "Amount: " + _AMT.toString(), style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold)),
              SwitchListTile(
                title: Text(_switchText),
                value: _isSwitched,
                onChanged: (bool value) {
                  setState(() {
                    _isSwitched = value;
                    if(_isSwitched){
                      _switchText="PayMode Online";
                    }
                    else{
                      _switchText="PayMode Cash";
                    }
                  });
                },
              )
            ],
          ),
          ),
        );
    },
                          ),
                            //int id = _saledetailsarry[index].ITEMID;
                            //MT_PSL_ITEMS[id].ITEMNAME
    StatefulBuilder(
    builder: (BuildContext context, StateSetter setState) {
      return
        Container(
          //height: MediaQuery.of(context).size.height * 0.5,
          child: ListView.builder(
            itemCount: _saledetailsarry.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                //_saledetailsarry[index].ITEMID.toString(),
                //int id = _saledetailsarry[index].ITEMID;
                title: Text(_items.firstWhere((item) => item['ITEMID'] == _saledetailsarry[index].ITEMID)['ITEMNAME'].toString(),
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold)),
                subtitle: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Qty: " + _saledetailsarry[index].QTY.toString() + " " +
                          "Rate: " + _saledetailsarry[index].RATE.toString() +
                          " Tax: " +
                          (_saledetailsarry[index].TAXRATE * 100).toString() +
                          "%  " +
                          "Tax Amt: " +
                          _saledetailsarry[index].TAXAMOUNT.toString() +
                          "  Amount: " +
                          _saledetailsarry[index].AMOUNT.toString(),
                      style: TextStyle(color: Colors.black),),
                  ],
                ),
                trailing: Row(
                  mainAxisSize:MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
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
                                  onPressed: () async {
                                    setState(() {
                                      _saledetailsarry.removeAt(index);
                                      Navigator.of(context).pop();
                                    });
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        );
    },
                                ),
                            ],
                          ),
                              ),
                            ],
                          ),
                          ),
                          ),
                              ),
                            actions: [
                              IconButton(
                                icon: Icon(Icons.cancel_outlined),
                                onPressed: () async{
                                  Navigator.of(context).pop();
    bluetooth.isConnected.then((isConnected) {
                                    if (isConnected == true) {
                                      //final content = '\x1B\x45\x01' + 'This is bold text\n' + '\x1B\x45\x00';
                                      //final content = '\x1B\x2D\x01' + 'This is underlined text\n' + '\x1B\x2D\x00';
                                      //final  content = '\x1B\x34' + 'This is italic text\n' + '\x1B\x35';
                                      //String largecontent = '\x1B\x21\x35' + 'This is large text\n' + '\x1B\x21\x00';
                                      //final content = '\u001B\cA' + 'This is large text\n' + '\x1B\x21\x00';
                                      //String content = '\x1B\x45\x10\x1B\x2D\x01' + 'This is bold and underlined text\n' + '\x1B\x2D\x00\x1B\x45\x00';
                                      //bluetooth.write(content);
                                      //bluetooth.write(centeredText);
                                    }
                                  });
                                },
                              ),

                              IconButton(
                                icon: Icon(Icons.remove_circle_outline),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  setState(() {
                                    _saledetailsarry.clear();
                                  });

                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.add_circle_outline),
                                onPressed: () async {
                                  try {
                                    if(_QTY>0) {
                                      var saledetails = SaledetailsModel(
                                          ITEMID: item['ITEMID'],
                                          QTY: _QTY,
                                          RATE: (_AMT / _QTY),
                                          AMOUNT: _AMT,
                                          SGST: double.parse(
                                              item['SGST'].toString()),
                                          CGST: double.parse(
                                              item['CGST'].toString()),
                                          IGST: double.parse(
                                              item['IGST'].toString()),
                                          CRDATE: format.format(DateTime.now()),
                                          TAXRATE: double.parse(
                                              item['TRATE'].toString()),
                                          TAXAMOUNT: _TAX,
                                          CREATEDBY: "ADMIN"
                                      );
                                      setState(() {
                                         _saledetailsarry.add(saledetails);
                                      });
                                    }
                                  }
                                  catch (e) {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Error'),
                                          content: Text('An error occurred c: $e'),
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
                              ),
                              IconButton(
                                icon: Icon(Icons.local_print_shop_outlined),
                                onPressed: () async {
                                  try {
                                    if(_saledetailsarry.length>0) {
                                      var dbHelper = DatabaseHelper();
                                      double SUM_SALEQTY = _saledetailsarry.fold(0, (previousValue, element) => previousValue + element.QTY);
                                      double SUM_SALEAMOUNT = _saledetailsarry.fold(0, (previousValue, element) => previousValue + element.AMOUNT);
                                      var saleModel = SaleModel(BCODE: 1,
                                          TDATE: format.format(DateTime.now()),
                                          CCODE: 1,
                                          SALE_QTY: SUM_SALEQTY,
                                          SALE_AMOUNT: SUM_SALEAMOUNT,
                                          PAYMODE: _isSwitched
                                              ? 'Online'
                                              : 'Cash',
                                          CRDATE: format.format(DateTime.now()),
                                          CREATEDBY: "ADMIN");
                                      int slno = await dbHelper.insertSales(saleModel, _saledetailsarry);
                                      Navigator.of(context).pop();
                                      _refreshListview(format.format(DateTime.now()));
                                      await _PRINTTOKEN(slno);
                                      bluetooth.isConnected.then((isConnected) {
                                        if (isConnected == true) {
                                          String BusinessName = _printdata[0]['BNAME']!;
                                          bluetooth.write(_centerText('Welcome\n', 34));//'\x1B\x21\x35' + 'This is large text\n' + '\x1B\x21\x00';
                                          bluetooth.write(_centerText('\x1B\x21\x35' + BusinessName+'\n' + '\x1B\x21\x00', 34));
                                          bluetooth.write('Address: '+_printdata[0]['ADDRESS']+'\n');
                                          bluetooth.write('Contact : '+_printdata[0]['PHONENO']+'\n');
                                          bluetooth.write("Token No:"+_printdata[0]['SLNO'].toString()+'\n');
                                          bluetooth.write("Date: "+_printdata[0]['TDATE']+'\n');
                                          bluetooth.write('--------------------------------');//32  '\x1B\x45\x01' + 'This is bold text\n' + '\x1B\x45\x00';
                                          bluetooth.write(_fourcolumnText('\x1B\x45\x01'+'ITEMNAME'+'\x1B\x45\x00', '\x1B\x45\x01'+'QTY'+'\x1B\x45\x00', '\x1B\x45\x01'+'RATE'+'\x1B\x45\x00', '\x1B\x45\x01'+'AMOUNT'+'\x1B\x45\x00', 58));
                                          bluetooth.write('--------------------------------');//32
                                          int _qty, _rate, _amount, _sumqty = 0, _sumamt = 0;
                                          for (int i = 0; i <
                                              _printdata.length; i++) {
                                            String itemname = _printdata[i]['ITEMNAME']
                                                .toString();
                                            _qty = int.parse(_printdata[i]['QTY'].toString());
                                            _rate = int.parse(_printdata[i]['RATE'].toString());
                                            _amount = int.parse(_printdata[i]['AMOUNT'].toString());
                                            _sumqty += int.parse(_printdata[i]['QTY'].toString());
                                            _sumamt += int.parse(_printdata[i]['AMOUNT'].toString());
                                            bluetooth.write(_fourcolumnText(itemname, _qty.toString(), _rate.toString(), _amount.toString(), 32));
                                          }
                                          String tqty = _sumqty.toString();
                                          String tamt = _sumamt.toString();
                                          bluetooth.write('--------------------------------');//32
                                          bluetooth.write(_fourcolumnText('\x1B\x45\x01'+'Total'+'\x1B\x45\x00', '\x1B\x45\x01'+'  '+tqty+'\x1B\x45\x00', "", '\x1B\x45\x01'+tamt+'\r\n'+'\x1B\x45\x00', 50));
                                          bluetooth.write('--------------------------------');//32
                                          bluetooth.printNewLine();
                                          bluetooth.printNewLine();
                                          bluetooth.printNewLine();
                                        }
                                      });
                                      _saledetailsarry.clear();
                                    }
                                  }
                                  catch (e) {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Error'),
                                          content: Text('An error occurred c: $e'),
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
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: GridTile(
                      child: Container(
                        margin: EdgeInsets.all(10),
                        color: Colors.blueGrey,
                        child: item['IMAGE']!=null? Image(image: item['IMAGE'].getImageProvider(), fit: BoxFit.cover):Text('No Image',style: TextStyle(fontSize: 18),),
                      ),
                      footer: GridTileBar(
                        backgroundColor: Colors.black26,
                        //title: Text(MT_PSL_ITEMS[index].ITEMNAME.toString(), style: TextStyle(fontSize: 18)),
                        title: Text(item['ITEMNAME'].toString(), style: TextStyle(fontSize: 18)),
                        subtitle: Text("Rate : "+item['SRATE'].toString()),
                      ),
                    ),
                  );
                }),
              )
    ),

          ],
        ),
    Align(
    alignment: Alignment.bottomCenter,
      child: Stack(
        children: [
      DraggableScrollableSheet(
        initialChildSize: 0.2,
        minChildSize: 0.2,
        maxChildSize: 0.7,
        builder: (BuildContext context, ScrollController scrollController) {
          return Container(
            color: Colors.white,
            child: Column(
              children: [
            Expanded(
            child:ListView.builder(
              controller: scrollController,
              itemCount: itemList.length,
              itemBuilder: (BuildContext context, int index) {
                Item item = itemList[index];
                return ExpansionPanelList(
                  elevation: 1,
                  expandedHeaderPadding: EdgeInsets.all(0),
                  expansionCallback: (int index, bool isExpanded) {
                    setState(() {
                      item.isExpanded = !isExpanded;
                    });
                  },
                  children: [
                    ExpansionPanel(
                      headerBuilder: (BuildContext context, bool isExpanded) {
                        return ListTile(
                          title: Text("Token No: "+item.parentData['SLNO'].toString()),
                          subtitle: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text("Qty: " + item.parentData['SALE_QTY'].toString() + " " + "AMOUNT: " + item.parentData['SALE_AMOUNT'].toString(), style: TextStyle(color: Colors.black),),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
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
                                            onPressed: () async {
                                              await databaseHelper.deleteSale(item.parentData['SLNO']);
                                              await _refreshListview(format.format(DateTime.now()));
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                      body: Container(
                      color: Colors.indigo[300], // Set the desired background color
                child:
                      ListView.builder(
                        controller: scrollController,
                        shrinkWrap: true,
                        itemCount: item.childData.length,
                        itemBuilder: (BuildContext context, int index) {
                          Map<String, dynamic> childData = item.childData[index];
                          return ListTile(
                            title: Text(childData['ITEMNAME'].toString(),style:TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text("Qty: "+childData['QTY'].toString()+" "+"Rate: "+childData['RATE'].toString()+" Tax: "+(childData['TAXRATE']*100).toString()+"%  "+"Tax Amt: "+childData['TAXAMOUNT'].toString()+"  Amount: "+childData['AMOUNT'].toString(),style:TextStyle(color: Colors.white),),
                              ],
                            ),
                          );
                        },
                      ),
                      ),
                      isExpanded: item.isExpanded,
                    ),
                  ],
                );
              },
            ),
            ),
          // New row
         Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.black,  // Specify the color of the border
                  width: 1.0,           // Specify the width of the border
                ),
              ),
            ),
          padding: EdgeInsets.all(2),

          child:Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
          Text('  Total Sold Amount : ',style: TextStyle(color: Colors.black, fontSize: 18)), // Column for "Total"
          Text(totalSum.toString()+'  ',style: TextStyle(color: Colors.black, fontSize: 18),), // Column for totalSum.toString()
          ],
          ) ,
          ),
          ],
          ),
          );
        },
      ),
      Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child:
          Visibility(
            visible: _isSortOptionsVisible,
            child: Container(
              height: 200, // Set the height of the filter options
              color: Colors.white,
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.black,
                          width: 1.0,
                        ),
                      ),
                    ),
                    padding: EdgeInsets.only(left: 15, right: 15, top: 5,bottom: 5),
                    child: InkWell(
                      onTap: () {
                        print('Clear Filter pressed');
                        fromdate=DateFormat('dd-MM-yyyy').format(DateTime.now());
                        todate=DateFormat('dd-MM-yyyy').format(DateTime.now());
                        _fromDate=DateTime.now();
                        _toDate=DateTime.now();
                      },
                    child:  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Clear Filter',style:TextStyle(fontWeight:FontWeight.bold)),
                      ],
                    ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 15, right: 15, top: 5),
                    color: Colors.white,
                    child:  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Select FromDate',style:TextStyle(fontWeight:FontWeight.bold)),
                        ElevatedButton.icon(
                          onPressed: () {
                            _selectfromDate(context);
                            setState(() {
                              fromdate = '${_fromDate.day.toString().padLeft(2, '0')}-${_fromDate.month.toString().padLeft(2, '0')}-${_fromDate.year.toString()}';
                            });
                          },
                          icon: Icon(Icons.date_range_sharp),
                          label: Text(
                            '${_fromDate.day}/${_fromDate.month}/${_fromDate.year}',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 15, right: 15, top: 5),
                    color: Colors.white,
                    child:  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Select ToDate',style:TextStyle(fontWeight:FontWeight.bold)),
                        ElevatedButton.icon(
                          onPressed: () {
                            _selecttoDate(context);
                            setState(() {
                              todate = '${_toDate.day.toString().padLeft(2, '0')}-${_toDate.month.toString().padLeft(2, '0')}-${_toDate.year.toString()}';
                            });
                          },

                          icon: Icon(Icons.date_range_sharp),
                          label: Text(
                            '${_toDate.day}/${_toDate.month}/${_toDate.year}',
                          ),
                        ),
                      ],
                    ),
                  ),
          // Other widgets in the stack
                  Container(
                    padding: EdgeInsets.all(5),
                    child: SizedBox(
                      height: 40,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async{
                          try {
                            _getfilterTRSaledata(fromdate,todate);
                            setState(() {
                              _isSortOptionsVisible = false;
                            });
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
                          'Apply',
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
              ),
            ),
          ),
      ),
      ],
      ),
    ),
      ],
        ),
    );
  }
}



