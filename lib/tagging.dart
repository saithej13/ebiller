import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import 'Home.dart';
enum Buff_Cow{Buffalo,Cow}
enum Breedtype{HF,Jersey}
enum local_graded{Local,Graded}
enum animal_status{Milking,Pregnent}
class CattleEntry extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cattle Entry',
      theme: ThemeData(
        backgroundColor: Colors.deepPurple,
        primarySwatch: Colors.deepPurple,
      ),
      home: MyCattleentry(),
    );
  }
}
class MyCattleentry extends StatefulWidget {

  const MyCattleentry({Key? key}) : super(key: key);

  @override
  _Cattleentry createState() => _Cattleentry();

}
class _Cattleentry extends State<MyCattleentry> {
  DateTime date = DateTime(2022,12,30);
  String dropdownvalue = '--select--';
  late bool error, showprogress=false;
  late String datetime, farmercode, farmername, fathername, contactno,
      aadharno, bankacno, bankname, branch, _selected;
  Buff_Cow? _Buff_Cow;
  Breedtype?_breedtype;
  local_graded? _local_graded;
  animal_status? _animal_status;
  TextEditingController _datetime = TextEditingController();
  TextEditingController _farmercode = TextEditingController();
  TextEditingController _farmername = TextEditingController();
  TextEditingController _fathername = TextEditingController();
  TextEditingController _contactno = TextEditingController();
  TextEditingController _aadharno = TextEditingController();
  TextEditingController _bankacno = TextEditingController();
  var image1,image2;
  final picker = ImagePicker();
  List<String> items = [
    'Farmer1',
    'Farmer2',
    'Farmer3',
  ];
  Future<void> gotohome() async {
    Navigator.push(context, MaterialPageRoute(builder: (_) => Home()));
  }
  void pickdate() async{
    DateTime? newDate=await showDatePicker(context: context, initialDate: date, firstDate:DateTime(1990), lastDate: DateTime(2100));
    if(newDate==null) return;
    setState(() =>date=newDate);
  }

  Future _image1(ImageSource media) async {
    var img = await picker.getImage(source: media);
    setState(() {
      image1 = img;
    });
  }
  Future _image2(ImageSource media) async {
    var img = await picker.getImage(source: media);
    setState(() {
      image2 = img;
    });
  }

  //show popup dialog
  void getimage1() {
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
                    //if user click this button, user can upload image from gallery
                    onPressed: () {
                      Navigator.pop(context);
                      _image1(ImageSource.gallery);
                    },
                    child: Row(
                      children: [
                        Icon(Icons.image),
                        Text('From Gallery'),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    //if user click this button. user can upload image from camera
                    onPressed: () {
                      Navigator.pop(context);
                      _image1(ImageSource.camera);
                    },
                    child: Row(
                      children: [
                        Icon(Icons.camera),
                        Text('From Camera'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
  void getimage2() {
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
                    //if user click this button, user can upload image from gallery
                    onPressed: () {
                      Navigator.pop(context);
                      _image2(ImageSource.gallery);
                    },
                    child: Row(
                      children: [
                        Icon(Icons.image),
                        Text('From Gallery'),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    //if user click this button. user can upload image from camera
                    onPressed: () {
                      Navigator.pop(context);
                      _image2(ImageSource.camera);
                    },
                    child: Row(
                      children: [
                        Icon(Icons.camera),
                        Text('From Camera'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      appBar: AppBar(
        title: Text('Cattle Entry (Tagging)'),

      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            //========================================================

            Container(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5),
              color: Colors.white,

              child:  Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Select Date',style:TextStyle(fontWeight:FontWeight.bold)),
                  ElevatedButton.icon(
                onPressed: () {
                  pickdate();
                },

                icon: Icon(Icons.date_range_sharp),
                    label: Text(
                  '${date.day}/${date.month}/${date.year}',

              ),
    ),
              ],
              ),
              ),
            Container(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: ButtonTheme(
                        alignedDropdown: true,
                        child: DropdownButton<String>(
                          hint: Text('--Select Farmer--'),
                          //value: _selected,
                          onChanged: (newValue) {
                            setState(() {
                              _selected = newValue!;
                            });
                          },
                          items: items.map((location) {
                            return DropdownMenuItem(
                              child: new Text(location),
                              value: location,
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Container(
              color: Colors.white,
              padding: EdgeInsets.all(10),
              child: TextField(
                controller: _farmercode,
                //set password controller
                style: TextStyle(color: Colors.indigo[700], fontSize: 20),
                decoration: InputDecoration(
                  //prefixIcon: Icon(Icons.person_pin_rounded),
                  border: OutlineInputBorder(),
                  labelText: 'Milk Yield',
                ),
                onChanged: (value) {
                  // change password text
                  farmercode = value;
                },
              ),
            ),
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(10),
              child: TextField(
                controller: _farmername,
                //set password controller
                style: TextStyle(color: Colors.indigo[700], fontSize: 20),
                decoration: InputDecoration(
                  //prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                  labelText: "Tag No.",
                ),
                onChanged: (value) {
                  // change password text
                  farmername = value;
                },
              ),
            ),
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(10),
              child: TextField(
                controller: _fathername,
                //set password controller
                style: TextStyle(color: Colors.indigo[700], fontSize: 20),
                decoration: InputDecoration(
                  //prefixIcon: Icon(Icons.featured_play_list_outlined),
                  border: OutlineInputBorder(),
                  labelText: "Rct No.",
                ),
                onChanged: (value) {
                  // change password text
                  fathername = value;
                },
              ),
            ),
            Container(
                padding: EdgeInsets.only(left: 15, right: 15, top: 5),
                color: Colors.white,
                child:  Row(
                  children: [
                    Text('Buff_Cow  ',style:TextStyle(fontWeight:FontWeight.bold)),
                    Expanded(child: RadioListTile<Buff_Cow>(
                    contentPadding: EdgeInsets.all(0.0),
                    value: Buff_Cow.Buffalo,
                    groupValue: _Buff_Cow,
                    title: Text('Buffalo'),
                    onChanged: (val){
                      setState(() {
                        _Buff_Cow=val;
                      });
                    },
                  )

                    ),
                    Expanded(child: RadioListTile<Buff_Cow>(
                      contentPadding: EdgeInsets.all(0.0),
                      value: Buff_Cow.Cow,
                      groupValue: _Buff_Cow,
                      title: Text('Cow'),
                      onChanged: (val){
                        setState(() {
                          _Buff_Cow=val;
                        });
                      },
                    )),
                  ],
              )
            ),
            Container(
                padding: EdgeInsets.only(left: 15, right: 15, top: 5),
                color: Colors.white,
                child:  Row(
                  children: [
                    Text('BreedType',style:TextStyle(fontWeight:FontWeight.bold)),
                    Expanded(child: RadioListTile<Breedtype>(
                      contentPadding: EdgeInsets.all(0.0),
                      value: Breedtype.HF,
                      groupValue: _breedtype,
                      title: Text('HF'),
                      onChanged: (val){
                        setState(() {
                          _breedtype=val;
                        });
                      },
                    )),
                    Expanded(child: RadioListTile<Breedtype>(
                      contentPadding: EdgeInsets.all(0.0),
                      value: Breedtype.Jersey,
                      groupValue: _breedtype,
                      title: Text('Jersey'),
                      onChanged: (val){
                        setState(() {
                          _breedtype=val;
                        });
                      },
                    )),
                  ],
                )
            ),
            Container(
                padding: EdgeInsets.only(left: 15, right: 15, top: 5),
                color: Colors.white,
                child:  Row(
                  children: [
                    Text('Local/       \nGraded',style:TextStyle(fontWeight:FontWeight.bold)),
                    Expanded(child: RadioListTile<local_graded>(
                      contentPadding: EdgeInsets.all(0.0),
                      value: local_graded.Local,
                      groupValue: _local_graded,
                      title: Text('Local'),
                      onChanged: (val){
                        setState(() {
                          _local_graded=val;
                        });
                      },
                    )),
                    Expanded(child: RadioListTile<local_graded>(
                      contentPadding: EdgeInsets.all(0.0),
                      value: local_graded.Graded,
                      groupValue: _local_graded,
                      title: Text('Graded'),
                      onChanged: (val){
                        setState(() {
                          _local_graded=val;
                        });
                      },
                    )),
                  ],
                )
            ),
            Container(
                padding: EdgeInsets.only(left: 15, right: 5, top: 5),
                color: Colors.white,
                child:  Row(
                  children: [
                    Text('Animal    \nStatus',style:TextStyle(fontWeight:FontWeight.bold)),
                    Expanded(child: RadioListTile<animal_status>(
                      contentPadding: EdgeInsets.all(0.0),
                      value: animal_status.Milking,
                      groupValue: _animal_status,
                      title: Text('Milking'),
                      onChanged: (val){
                        setState(() {
                          _animal_status=val;
                        });
                      },
                    )),
                    Expanded(child: RadioListTile<animal_status>(
                      contentPadding: EdgeInsets.all(0.0),
                      value: animal_status.Pregnent,
                      groupValue: _animal_status,
                      title: Text('Pregnent'),
                      onChanged: (val){
                        setState(() {
                          _animal_status=val;
                        });
                      },
                    )),
                  ],
                )
            ),
            ElevatedButton(
              onPressed: () {
                getimage1();
              },
              child: Text('Upload Image1'),
            ),
            SizedBox(
              height: 10,
            ),
            //if image not null show the image
            //if image null show text
            image1 != null
                ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  //to show image, you type like this.
                  File(image1!.path),
                  fit: BoxFit.cover,
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  height: 300,
                ),
              ),
            )
                : Text(
              "No Image",
              style: TextStyle(fontSize: 20),
            ),
            ElevatedButton(
              onPressed: () {
                getimage2();
              },
              child: Text('Upload Image2'),
            ),
            SizedBox(
              height: 10,
            ),
            //if image not null show the image
            //if image null show text
            image2 != null
                ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  //to show image, you type like this.
                  File(image2!.path),
                  fit: BoxFit.cover,
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  height: 300,
                ),
              ),
            )
                : Text(
              "No Image",
              style: TextStyle(fontSize: 20),
            ),
            Container(
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.only(top: 20),
              child: SizedBox(
                height: 60,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showprogress = true;
                    });
                    gotohome();
                  },
                  child: showprogress
                      ? SizedBox(
                    height: 30,
                    width: 30,
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.white,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.lightBlueAccent),
                    ),
                  )
                      : Text(
                    "Save",
                    style: TextStyle(fontSize: 20,color: Colors.indigo),
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
    );
  }
}
