import 'dart:convert';

import 'package:ebiller2/models/usersmodel.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:ebiller2/UI/RatesView.dart';
import 'package:ebiller2/UI/categoryView.dart';
import 'package:ebiller2/UI/ItemView.dart';

import 'UI/SalesView.dart';
import 'UI/connectprinter.dart';
import 'UI/licenceView.dart';
class Home extends StatefulWidget{
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => MyHomePage();

}

class MyDrawer extends StatelessWidget {
  final VoidCallback onOpenDrawer;
  const MyDrawer({required this.onOpenDrawer});
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () {
              Navigator.pop(context);
              // navigate to home screen
            },
          ),
          ListTile(
            leading: Icon(Icons.date_range),
            title: Text('LICENCE'),
            onTap: ()
            {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LicenceMaster()),);
              // navigate to settings screen
            },
          ),
          ListTile(
            leading: Icon(Icons.print_outlined),
            title: Text('Connect Printer'),
            onTap: ()
            {
              //SystemNavigator.pop();
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ConnectPrinter()),);
              // navigate to settings screen
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Exit'),
            onTap: ()
            {
              SystemNavigator.pop();
            },
          ),
        ],
      ),
    );
  }
}
class MyHomePage extends State<Home> {

  bool _isDrawerOpen = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  void _toggleDrawer() {
    setState(() {
      _isDrawerOpen = !_isDrawerOpen;
    });
    if (_scaffoldKey.currentState!.isDrawerOpen==true) {
      _scaffoldKey.currentState!.openEndDrawer();
    } else {
      _scaffoldKey.currentState!.openDrawer();
    }
  }
  int _selectedIndex = 0;
  static const List<Widget> _widgetOptions = <Widget>[
    Text('Index 0: Home'),
    Text('Index 1: Search'),
    Text('Index 2: Profile'),
  ];
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
        home: Scaffold(
        appBar: AppBar(

    leading: Builder(
    builder: (BuildContext context) {
      return IconButton(
        icon: const Icon(Icons.menu),
        onPressed: _toggleDrawer,
      );
    },
    ),
        ),
      body:Builder(
        builder: (BuildContext context) {
          return Scaffold(
            key:_scaffoldKey,
            drawer: MyDrawer(onOpenDrawer: () => _scaffoldKey.currentState!.openDrawer(),),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(padding: const EdgeInsets.all(18.0),
                child: Text("Welcome ",style: TextStyle(color: Colors.black,fontSize: 28.0,fontWeight: FontWeight.bold),textAlign: TextAlign.start,),
              ),
              Padding(padding: const EdgeInsets.all(12.0),
                child: Center(
                  child: Wrap(
                    spacing: 20.0,
                    runSpacing: 20.0,
                    children: [
                      SizedBox(
                        width: 130.0,
                        height: 150.0,
                        child: Card(
                          color: Colors.indigo[800],
                          elevation: 2.0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0)
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => CategoryMaster()),);
                            },
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Image.asset("assets/category.png"),
                                    SizedBox(height: 8.0),
                                    Text("Category",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 20.0)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 130.0,
                        height: 150.0,
                        child: Card(
                          color: Colors.indigo[800],
                          elevation: 2.0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0)
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ItemMaster()),);
                            },
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Image.asset("assets/items.png"),
                                    SizedBox(height: 8.0),
                                    Text("Item",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 20.0)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 130.0,
                        height: 150.0,
                        child: Card(
                          color: Colors.indigo[800],
                          elevation: 2.0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0)
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => RateMaster()),);
                            },
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Image.asset("assets/rupee.png"),
                                    SizedBox(height: 8.0),
                                    Text("Rates",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 20.0)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 130.0,
                        height: 150.0,
                        child: Card(
                          color: Colors.indigo[800],
                          elevation: 2.0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0)
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => Sales()),);
                            },
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Image.asset("assets/cart.png"),
                                    SizedBox(height: 8.0),
                                    Text("Sale",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 20.0)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
          );
        },
      ),
     // bottomNavigationBar: BottomNavigationBar(
     //   currentIndex: _selectedIndex,
     //   onTap: _onItemTapped,
     //   items: const <BottomNavigationBarItem>[
     //     BottomNavigationBarItem(
     //       icon: Icon(Icons.home),
     //       label: 'Home',
     //     ),
     //     BottomNavigationBarItem(
     //       icon: Icon(Icons.menu_book_sharp),
     //       label: 'Search',
     //     ),
     //     BottomNavigationBarItem(
     //       icon: Icon(Icons.person),
     //       label: 'Profile',
     //     ),
     //   ],
     // ),
    ),
    );
}
}