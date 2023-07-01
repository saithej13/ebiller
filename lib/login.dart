import 'package:ebiller2/models/usersmodel.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:ebiller2/Home.dart';
import 'DatabaseHelper.dart';
import 'package:dio/dio.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';



class MyLogin extends StatefulWidget {
  const MyLogin({Key? key}) : super(key: key);

  @override
  _MyLoginState createState() => _MyLoginState();
}

class _MyLoginState extends State<MyLogin> {
  final _USERNAME = TextEditingController();
  final _PASSWORD = TextEditingController();
  String version="";
  final spreadsheetId = '1lHu--ATEXvmUt-Ae3YmY-Uxpp1QSoD4eAwVhdtX6dQs';
  final range = 'BRANCHES!A1:E2';

  Future<void> retrieveAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = packageInfo.version;
    });
  }
  void checkforupdate() async{
    String cloudversion = "1.0.1";
    if(version!=cloudversion){
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Update'),
            content: Text('Update Available, We Recommend you to Update the App'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                  downloadFile("https://priyamilk.com/dairyapp/dairyapp.apk",context);
                },
              ),
            ],
          );
        },
      );

    }
    // final url = 'https://sheets.googleapis.com/v4/spreadsheets/$spreadsheetId/values/$range';
    // try {
    //   final response = await Dio().get(url);
    //   if (response.statusCode == 200) {
    //     final data = response.data;
    //     final values = data['values'];
    //     for (var row in values) {
    //       print(row);
    //     }
    //   } else {
    //     print('Error: ${response.statusCode}');
    //   }
    // } catch (e) {
    //   print('Error: $e');
    // }
    /*if(version!=cloudversion){
    downloadFile(url);

    }*/

  }
  void downloadFile(String url, BuildContext context) async {
    try {
      Dio dio = Dio();
      var dir = await getApplicationDocumentsDirectory();
      String savePath = '${dir.path}/ebiller.apk';

      int _progress = 0; // Initialize progress to 0

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Downloading File'),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LinearProgressIndicator(
                      value: _progress / 100,
                    ),
                    SizedBox(height: 16),
                    Text('Downloading...'),
                    SizedBox(height: 8),
                    Text('$_progress%'),
                  ],
                );
              },
            ),
          );
        },
      );

      await dio.download(
        url,
        savePath,
        onReceiveProgress: (receivedBytes, totalBytes) {
          if (totalBytes != -1) {
            double progress = (receivedBytes / totalBytes) * 100;
            setState(() {
              _progress = progress.round();
            });
            if (progress == 100) {
              try {
                Navigator.of(context, rootNavigator: true).pop();
              } catch (e) {
                print('Error closing dialog: $e');
              }
            }
          }
        },
      );

      print('File downloaded to: $savePath');
      await OpenFile.open(savePath);
    } catch (e) {
      print('Error downloading file: $e');
    }
  }




  @override
  void initState() {
    super.initState();
    retrieveAppVersion();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Colors.blue,
            Colors.white,
            Colors.white,
            Colors.blue,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Login'),
        ),
        body: Stack(
          children: [
            Container(),
            SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.only(left: 35, top: 30),
                      child: Text(
                        'Welcome\nBack',
                        style: TextStyle(
                            color: Colors.indigo[700],
                            fontSize: 40,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 35),
                      margin: EdgeInsets.only(top: 10),
                      child: Text(
                        "Sign in to Continue...",
                        style: TextStyle(color: Colors.indigo[700], fontSize: 20),
                      ), //subtitle text
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 35, right: 35,top: 20),
                      child: Column(
                        children: [
                          TextField(
                            style: TextStyle(color: Colors.black),
                            controller: _USERNAME,
                            decoration: InputDecoration(
                                prefixIcon: Icon(Icons.person),
                                fillColor: Colors.grey.shade100,
                                filled: true,
                                hintText: "UserId",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                )),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          TextField(
                            style: TextStyle(),
                            controller: _PASSWORD,
                            obscureText: true,
                            decoration: InputDecoration(
                                prefixIcon: Icon(Icons.lock),
                                fillColor: Colors.grey.shade100,
                                filled: true,
                                hintText: "Password",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                )),
                          ),
                          SizedBox(
                            height: 40,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Sign in',
                                style: TextStyle(
                                    fontSize: 27, fontWeight: FontWeight.w700),
                              ),
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: Color(0xff4c505b),
                                child: IconButton(
                                    color: Colors.white,
                                    onPressed: () async {
                                      var dbHelper = DatabaseHelper();
                                      String loggedInUser = await dbHelper.getuser(_USERNAME.text.toLowerCase(),_PASSWORD.text);
                                      if (loggedInUser.isNotEmpty) {
                                        // User exists, perform login
                                        String LICENCE = await dbHelper.isvalidlicence();
                                        if(LICENCE.isNotEmpty){
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(builder: (context) => Home()),
                                          );
                                        }else if(_USERNAME.text=="ADMIN"){
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(builder: (context) => Home()),
                                          );
                                        }
                                        else{
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text("Licence Expired, Please Update"),
                                                content: Text("Contact 9705966305"),
                                                actions: [
                                                  TextButton(
                                                    child: Text("OK"),
                                                    onPressed: () {
                                                      Navigator.of(context).pop();
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        }
                                        _USERNAME.text = "";
                                        _PASSWORD.text = "";
                                      } else {
                                        // User does not exist, show error or handle accordingly
                                        // For example, display an error message or clear the text fields
                                        _USERNAME.text = "";
                                        _PASSWORD.text = "";
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text("Invalid Credentials"),
                                              content: Text("Username or password is incorrect."),
                                              actions: [
                                                TextButton(
                                                  child: Text("OK"),
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
                                    icon: Icon(
                                      Icons.arrow_forward,
                                    )),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 40,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, 'register');
                                },
                                child: Text(
                                  'Sign Up',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      color: Color(0xff4c505b),
                                      fontSize: 18),
                                ),
                                style: ButtonStyle(),
                              ),
                              TextButton(
                                  onPressed: () {
                                    checkforupdate();
                                  },
                                  child: Text(
                                    'Forgot Password',
                                    style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      color: Color(0xff4c505b),
                                      fontSize: 18,
                                    ),
                                  )),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Version : $version'),
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}