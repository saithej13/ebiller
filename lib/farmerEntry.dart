import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import 'Home.dart';
class FarmerEntry extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Farmer Entry',
      theme: ThemeData(
        backgroundColor: Colors.deepPurple,
        primarySwatch: Colors.deepPurple,
      ),
      home: MyFarmerentry(),
    );
  }
}
class MyFarmerentry extends StatefulWidget {

  const MyFarmerentry({Key? key}) : super(key: key);

  @override
  _Farmerentry createState() => _Farmerentry();

}
class _Farmerentry extends State<MyFarmerentry> {
  String dropdownvalue = '--select--';
  late bool error, showprogress=false;
  late String villagename, farmercode, farmername, fathername, contactno,
      aadharno, bankacno, bankname, branch, _selected;
  TextEditingController _Villagename = TextEditingController();
  TextEditingController _farmercode = TextEditingController();
  TextEditingController _farmername = TextEditingController();
  TextEditingController _fathername = TextEditingController();
  TextEditingController _contactno = TextEditingController();
  TextEditingController _aadharno = TextEditingController();
  TextEditingController _bankacno = TextEditingController();
  var aadhar,bankpassbook;
  final picker = ImagePicker();
  List<String> items = [
    'Kaimnagar',
    'Hyderabad',
    'Warangal',
  ];
  Future<void> gotohome() async {
    Navigator.push(context, MaterialPageRoute(builder: (_) => Home()));
  }

  Future Aadhar(ImageSource media) async {
    var img = await picker.getImage(source: media);

    setState(() {
      aadhar = img;
    });
  }
  Future _bankpassbook(ImageSource media) async {
    var img = await picker.getImage(source: media);

    setState(() {
      bankpassbook = img;
    });
  }

  //show popup dialog
  void getAadhar() {
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
                      Aadhar(ImageSource.gallery);
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
                      Aadhar(ImageSource.camera);
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
  void getbankpassbook() {
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
                      _bankpassbook(ImageSource.gallery);
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
                      _bankpassbook(ImageSource.camera);
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
        title: Text('Farmer Entry'),

      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            //======================================================== State
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
                          hint: Text('--Select Mandal--'),
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
                controller: _Villagename,
                //set password controller
                style: TextStyle(color: Colors.indigo[700], fontSize: 20),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.villa),
                  border: OutlineInputBorder(),
                  labelText: "Village Name",
                ),
                onChanged: (value) {
                  // change password text
                  villagename = value;
                },
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
                  prefixIcon: Icon(Icons.person_pin_rounded),
                  border: OutlineInputBorder(),
                  labelText: 'Farmer Code',
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
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                  labelText: "Farmer Name",
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
                  prefixIcon: Icon(Icons.featured_play_list_outlined),
                  border: OutlineInputBorder(),
                  labelText: "Father Name",
                ),
                onChanged: (value) {
                  // change password text
                  fathername = value;
                },
              ),
            ),
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(10),
              child: TextField(
                controller: _contactno,
                //set password controller
                style: TextStyle(color: Colors.indigo[700], fontSize: 20),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.contact_phone_outlined),
                  border: OutlineInputBorder(),
                  labelText: "Contact No.",
                ),
                onChanged: (value) {
                  // change password text
                  contactno = value;
                },
              ),
            ),
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(10),
              child: TextField(
                controller: _aadharno,
                //set password controller
                style: TextStyle(color: Colors.indigo[700], fontSize: 20),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.credit_card),
                  border: OutlineInputBorder(),
                  labelText: "Aadhar Card No.",
                ),
                onChanged: (value) {
                  // change password text
                  aadharno = value;
                },
              ),
            ),
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(10),
              child: TextField(
                controller: _bankacno,
                //set password controller
                style: TextStyle(color: Colors.indigo[700], fontSize: 20),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.account_balance),
                  border: OutlineInputBorder(),
                  labelText: "Bank A/C No.",
                ),
                onChanged: (value) {
                  // change password text
                  bankacno = value;
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                getAadhar();
              },
              child: Text('Upload Aadhar'),
            ),
            SizedBox(
              height: 10,
            ),
            aadhar != null
                ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  //to show image, you type like this.
                  File(aadhar!.path),
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
                getbankpassbook();
              },
              child: Text('Upload Bank Passbook'),
            ),
            SizedBox(
              height: 10,
            ),
            //if image not null show the image
            //if image null show text
            bankpassbook != null
                ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  //to show image, you type like this.
                  File(bankpassbook!.path),
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
