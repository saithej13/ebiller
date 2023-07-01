import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:sqflite/sqflite.dart';
import '../DatabaseHelper.dart';
import  'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ebiller2/models/categorymodel.dart';

import '../Home.dart';
class Category extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Category Master',
      home: CategoryMaster(),
    );
  }
}




class CategoryMaster extends StatefulWidget {

  const CategoryMaster({Key? key}) : super(key: key);

  @override
  _Category_Entery createState() => _Category_Entery();

}
DatabaseHelper databaseHelper = DatabaseHelper();
class _Category_Entery extends State<CategoryMaster> {
  List<categorymodel> MT_PSL_CATEGORY = [];
  @override
  void initState() {
    super.initState();
    databaseHelper.getCategory().then((list) {
      setState(() {
        MT_PSL_CATEGORY = list;
      });
    });
  }
  void _refreshCategoryList() {
    databaseHelper.getCategory().then((list) {
      setState(() {
        MT_PSL_CATEGORY = list;
      });
    });
  }
  late bool ISACTIVE;
  late String CATNAME, CREATEDBY;
  String _buttonText="SAVE";
  int? _CATIDFORUPDATE;
  final _CATNAME = TextEditingController();
  @override
  void dispose() {
    _CATNAME.dispose();
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
        title: Text('CATEGORY MASTER'),

      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
      Expanded(
        child: FutureBuilder<List<categorymodel>>(
      future: databaseHelper.getCategory(),
          builder: (BuildContext context,AsyncSnapshot<List<categorymodel>> snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            return ListView.builder(
              itemCount: MT_PSL_CATEGORY.length,
              itemBuilder: (context, index) {
                return Slidable(
                  actionPane: SlidableDrawerActionPane(),
                  actionExtentRatio: 0.25,
                  child: ListTile(
                    title: Text(MT_PSL_CATEGORY[index].CATNAME,style: TextStyle(fontSize: 18,color: Colors.white,fontWeight: FontWeight.bold)),
                    subtitle: Text(MT_PSL_CATEGORY[index].CRDATE.toString(),style: TextStyle(fontSize: 18,color: Colors.white)),
                  ),
                  actions: <Widget>[
                    IconSlideAction(
                      caption: 'Edit',
                      color: Colors.blue,
                      icon: Icons.edit_outlined,
                      onTap: () {
                        _CATIDFORUPDATE=MT_PSL_CATEGORY[index].CATID;
                        _CATNAME.text=MT_PSL_CATEGORY[index].CATNAME.toString();
                        _buttonText="UPDATE";
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
                              content: Text('Are you sure you want to delete?'),
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
                                    try {
                                      // Call the delete method here
                                      Navigator.of(context).pop();
                                      databaseHelper.deleteCategory(MT_PSL_CATEGORY[index].CATID!);
                                      //throw Exception('testing...');

                                    }
                                    catch (e) {
                                      print('An error occurred: $e');
                                    }
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
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                  color: Colors.indigo,
                padding: EdgeInsets.all(1)
              ),
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(5),
              child: TextField(
                controller: _CATNAME,
                //set password controller
                style: TextStyle(color: Colors.indigo[600], fontSize: 20),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.category_outlined),
                  border: OutlineInputBorder(),
                  labelText: "Category Name",
                ),
                onChanged: (value) {
                  // change password text
                  CATNAME = value;
                },
              ),
            ),

            Container(
              padding: EdgeInsets.all(5),
              child: SizedBox(
                height: 40,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async{
    try {
      if(_CATNAME.text.isNotEmpty) {
        var dbHelper = DatabaseHelper();
        if(_buttonText=="UPDATE"){
          var UPDATEcategory = categorymodel(CATID: _CATIDFORUPDATE,CATNAME: _CATNAME.text,
              ISACTIVE: 1,
              CRDATE: DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now()),
              CREATEDBY: "ADMIN");
          await dbHelper.updateCategory(UPDATEcategory);
        }
        var category = categorymodel(CATNAME: _CATNAME.text,
            ISACTIVE: 1,
            CRDATE: DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now()),
            CREATEDBY: "ADMIN");
        await dbHelper.insertCategory(category);
        _refreshCategoryList();
        _CATNAME.text = "";
      }
      else{
        throw Exception('Please Enter Category Name!');
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
    ),
    ],
      ),

    );
  }
}
