import 'package:ebiller2/models/Licencemodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:ebiller2/models/ItemModel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:sqflite/sqflite.dart';
import '../DatabaseHelper.dart';
import  'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:ebiller2/models/categorymodel.dart';

import '../Home.dart';
class ItemView extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Item Master',
      home: ItemMaster(),
    );
  }
}

class ItemMaster extends StatefulWidget {

  const ItemMaster({Key? key}) : super(key: key);

  @override
  _Item_Entery createState() => _Item_Entery();

}
DatabaseHelper databaseHelper = DatabaseHelper();
class _Item_Entery extends State<ItemMaster> {
  List<ItemModel> MT_PSL_ITEMS = [];
  List<categorymodel> MT_PSL_CATEGORY = [];
  final picker = ImagePicker();
  var image;

  @override
  void initState() {
    super.initState();
    _getcatList();
    databaseHelper.getItem().then((list) {
      setState(() {
        MT_PSL_ITEMS = list;
      });
    });
  }

  Future _Image(ImageSource media) async {
    final img = await picker.getImage(source: media, imageQuality: 100);
    if (img != null) {
      final compressedImage = await compressImage(img.path);
      final imageBytes = await compressedImage.readAsBytes();
      final imageSizeKB = imageBytes.lengthInBytes / 1024;
      if (imageSizeKB <= 50) {
        setState(() {
          image = img;
        });
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Image Size Exceeded'),
              content: Text('Please choose an image below 400KB in size.'),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }
  Future<File> compressImage(String imagePath) async {
    final imageFile = File(imagePath);
    final tempDir = await getTemporaryDirectory();
    final tempPath = tempDir.path;
    final compressedImageFile = await FlutterImageCompress.compressAndGetFile(
      imageFile.path,
      '$tempPath/img_${DateTime.now().millisecondsSinceEpoch}.jpg',
      quality: 85,
      minHeight: 300,
      minWidth: 300,
    );
    return compressedImageFile ?? imageFile;
  }
  void getImage() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            title: Text('Please choose media to select'),
            content: Container(
              height: MediaQuery
                  .of(context)
                  .size
                  .height / 6,
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      final ImagePicker picker = ImagePicker();
                      PickedFile? image = await picker.getImage(source: ImageSource.gallery);
                      if (image != null) {
                        String savedImagePath = await saveImageToStorage(image as String);
                        Image.file(File(savedImagePath));
                      }
                      _Image(ImageSource.gallery);
                    },
                    child: Row(
                      children: [
                        Icon(Icons.image),
                        Text('From Gallery'),

                      ],
                    ),
                  ),
                  // ElevatedButton(
                  //   //if user click this button. user can upload image from camera
                  //   onPressed: () {
                  //     Navigator.pop(context);
                  //     _Image(ImageSource.camera);
                  //   },
                  //   child: Row(
                  //     children: [
                  //       Icon(Icons.camera),
                  //       Text('From Camera'),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
            ),
          );
        });
  }
  Future<String> saveImageToStorage(String imagePath) async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String directoryPath = '${appDir.path}/images';
    final Directory imageDir = Directory(directoryPath);
    if (!imageDir.existsSync()) {
      imageDir.createSync();
    }
    final String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final String filePath = '$directoryPath/$fileName';
    final File imageFile = File(imagePath);
    await imageFile.copy(filePath);
    return filePath;
  }
  void _refreshItemList() {
    databaseHelper.getItem().then((list) {
      setState(() {
        MT_PSL_ITEMS = list;
      });
    });
  }
  late bool ISACTIVE;
  late String ITEMNAME, CREATEDBY;
  String _buttonText = "SAVE";
  String? _selectedUOM,_selectedPKG,_selectedCATID;
  int? _ITEMIDFORUPDATE;
  final _ITEMNAME = TextEditingController();
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
    _ITEMNAME.dispose();
    super.dispose();
  }
  void _getcatList() async {
    databaseHelper.getCategory().then((list) {
      setState(() {
        MT_PSL_CATEGORY = list;
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
          title: Text('ITEM MASTER'),

        ),
        body:Column(
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
                    itemCount: MT_PSL_ITEMS.length,
                    itemBuilder: (context, index) {
                        return Slidable(
                          actionPane: SlidableDrawerActionPane(),
                          actionExtentRatio: 0.25,
                          child: ListTile(
                            title: Text(MT_PSL_ITEMS[index].ITEMNAME,style: TextStyle(fontSize: 18,color: Colors.white,fontWeight: FontWeight.bold)),
                            subtitle: Text(MT_PSL_ITEMS[index].ITEMID.toString(),style: TextStyle(fontSize: 18,color: Colors.white)),
                          ),
                          actions: <Widget>[
                            IconSlideAction(
                              caption: 'Edit',
                              color: Colors.blue,
                              icon: Icons.edit_outlined,
                              onTap: () {
                                _ITEMIDFORUPDATE=MT_PSL_ITEMS[index].ITEMID;
                                _ITEMNAME.text=MT_PSL_ITEMS[index].ITEMNAME.toString();
                                setState(() {
                                _selectedPKG=MT_PSL_ITEMS[index].PKGUNIT.toString();
                                _selectedUOM=MT_PSL_ITEMS[index].UOM.toString();
                                _selectedCATID=MT_PSL_ITEMS[index].CATID.toString();
                                //MT_PSL_ITEMS[index].image!=null? Image(image: MT_PSL_ITEMS[index].image.getImageProvider(), fit: BoxFit.cover):Text('No Image',style: TextStyle(fontSize: 18),),
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
                            databaseHelper.deleteItem(MT_PSL_ITEMS[index].ITEMID!);
                            Navigator.of(context).pop();
                            _refreshItemList();
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
              padding: EdgeInsets.only(left: 15, right: 15,top:10),
              child: TextField(
                controller: _ITEMNAME,
                //set password controller
                style: TextStyle(color: Colors.indigo[700], fontSize: 20),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.villa),
                  border: OutlineInputBorder(),
                  labelText: "Item Name",
                ),
                onChanged: (value) {
                  // change password text
                  ITEMNAME = value;
                },
              ),
            ),

            Container(
              padding: EdgeInsets.only(left: 15, right: 15, top: 2),
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
                        child: DropdownButton<String>(
                          hint: Text('--Select PKGUNIT--'),
                          value: _selectedPKG,
                          onChanged: (newValue) {
                            setState(() {
                              _selectedPKG = newValue!;
                            });
                          },
                          items: itemsPKG.map((location) {
                            return DropdownMenuItem(
                              child: new Text(location),
                              value: location,
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

            Container(
              padding: EdgeInsets.only(left: 15, right: 15, top: 2),
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
                child: DropdownButton<String>(
                            hint:Text('--Select UOM--'),
                          value: _selectedUOM,
                          onChanged: (value) {
                            setState(() {
                              _selectedUOM = value;
                            });
                          },
                          items: itemsUOM.map((item) {
                            return DropdownMenuItem(
                              child: new Text(item),
                              value: item,
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
            Container(
              padding: EdgeInsets.only(left: 15, right: 15, top: 2,bottom:10),
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
                          hint:Text('--Select Category--'),
                          value:  _selectedCATID != null ? int.parse(_selectedCATID!) : null,
                          onChanged: (value) {
                            setState(() {
                              _selectedCATID = value.toString();
                            });
                          },
                          items: MT_PSL_CATEGORY.map((item) {
                            return DropdownMenuItem<int>(
                              child: new Text(item.CATNAME),
                              value: item.CATID,
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
            Container(
              color: Colors.white,
              width: double.infinity,
              padding: EdgeInsets.all(5),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      getImage();
                    },
                    child: Text('Upload Image'),
                  ),
                  SizedBox(height: 10),
                  if (image != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(image!.path),
                          fit: BoxFit.cover,
                          width: MediaQuery.of(context).size.width,
                          height: 200,
                        ),
                      ),
                    )
                  else
                    Text(
                      "No Image",
                      style: TextStyle(fontSize: 20),
                    ),
                ],
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
                      if(_ITEMNAME.text.isNotEmpty&&_selectedCATID!=null&&_selectedUOM!=null&&_selectedPKG!=null) {
                        var dbHelper = DatabaseHelper();
                        //ITEMID INTEGER PRIMARY KEY,CATID INTEGER, ITEMNAME VARCHAR(100),PKGUNIT VARCHAR(50)
                        // ,ISACTIVE BIT,CRDATE DATETIME,CREATEDBY VARCHAR(50) NULL,UOM VARCHAR(50) NULL)');
                        if(_buttonText=="UPDATE")
                          {
                            var UPDATEitem = ItemModel(ITEMID: _ITEMIDFORUPDATE,ITEMNAME: _ITEMNAME.text,
                                CATID: int.parse(_selectedCATID!.toString()),
                                PKGUNIT: _selectedPKG.toString(),
                                ISACTIVE: 1,
                                CRDATE: DateFormat("yyyy-MM-dd HH:mm:ss").format(
                                    DateTime.now()),
                                CREATEDBY: "ADMIN",
                                UOM: _selectedUOM.toString(),
                              image: image != null ? await image.readAsBytes() : null,);
                            await dbHelper.updateItem(UPDATEitem);
                          }
                        else{
                          var INSERTitem = ItemModel(ITEMNAME: _ITEMNAME.text,
                              CATID: int.parse(_selectedCATID!.toString()),
                              PKGUNIT: _selectedPKG.toString(),
                              ISACTIVE: 1,
                              CRDATE: DateFormat("yyyy-MM-dd HH:mm:ss").format(
                                  DateTime.now()),
                              CREATEDBY: "ADMIN",
                              UOM: _selectedUOM.toString(),
                            image: image != null ? await image.readAsBytes() : null,);
                          await dbHelper.insertItem(INSERTitem);
                        }
                        _refreshItemList();
                        _ITEMNAME.text = "";
                        _selectedCATID=null;
                        _selectedPKG=null;
                        _selectedUOM=null;
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
        ),
    );
  }
}
