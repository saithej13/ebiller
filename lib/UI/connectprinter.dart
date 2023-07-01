import 'dart:async';

import 'package:flutter/material.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/services.dart';

class ConnectPrinter extends StatefulWidget {
  _ConnectPrinterState createState() => _ConnectPrinterState();
}

class _ConnectPrinterState extends State<ConnectPrinter> {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _device;
  bool _connected = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    bool? isConnected = await bluetooth.isConnected;
    List<BluetoothDevice> devices = [];
    try {
      devices = await bluetooth.getBondedDevices();
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Error getting bonded devices: $e'),
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

    bluetooth.onStateChanged().listen((state) {
      if (mounted) {
        setState(() {
          switch (state) {
            case BlueThermalPrinter.CONNECTED:
              _connected = true;
              print("Bluetooth device state: connected");
              break;
            case BlueThermalPrinter.DISCONNECTED:
              _connected = false;
              print("Bluetooth device state: disconnected");
              break;
            case BlueThermalPrinter.DISCONNECT_REQUESTED:
              _connected = false;
              print("Bluetooth device state: disconnect requested");
              break;
            case BlueThermalPrinter.STATE_TURNING_OFF:
              _connected = false;
              print("Bluetooth device state: bluetooth turning off");
              break;
            case BlueThermalPrinter.STATE_OFF:
              _connected = false;
              print("Bluetooth device state: bluetooth off");
              break;
            case BlueThermalPrinter.STATE_ON:
              _connected = false;
              print("Bluetooth device state: bluetooth on");
              break;
            case BlueThermalPrinter.STATE_TURNING_ON:
              _connected = false;
              print("Bluetooth device state: bluetooth turning on");
              break;
            case BlueThermalPrinter.ERROR:
              _connected = false;
              print("Bluetooth device state: error");
              break;
            default:
              print(state);
              break;
          }
        });
      }
    });

    if (!mounted) return;
    setState(() {
      _devices = devices;
    });

    if (isConnected == true) {
      setState(() {
        _connected = true;
      });
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Printer'),
      ),
      body: Container(
        child: ListView.builder(
          itemCount: _devices.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: Text(_devices[index].name ?? ''),
              subtitle: Text(_devices[index].address.toString()),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: _connected ? Colors.red : Colors.green),
                    onPressed:(){
                      setState(() {
                          _device=_devices[index];
                          _connected ? _disconnect() :  _connect();
                        });
                     // _disconnect();
                    },
                    child: Text(
                      _connected ? 'Disconnect' : 'Connect',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  Icon(Icons.bluetooth),
                ],
              ),
              onTap: () async{
                // setState(() {
                //   _device=_devices[index];
                //   savesettings(
                //     _devices[index].name ?? '',
                //     _devices[index].address.toString(),
                //   );
                // });
              },
            );
          },
        ),
      ),
    );
  }

  void savesettings(String devicename, String deviceaddress) async {
      _connect();
     bluetooth.isConnected.then((isConnected) {
       if (isConnected == true) {
         bluetooth.printCustom("Connected!"+devicename,10,1);
         bluetooth.printNewLine();
       }
       else{
         print('disconnecting..,');
         _disconnect();
       }
     });
  }

  void _connect() {
    try {
      if (_device != null) {
        bluetooth.isConnected.then((isConnected) {
          if (isConnected == false) {
            try {
              bluetooth.connect(_device!).catchError((error) {
                setState(() => _connected = false);
                print('Connection error: $error');
              });
              setState(() => _connected = true);
            } catch (error) {
              print('Connection error: $error');
            }
          }
        });
      } else {
        // Handle the case when no device is selected
      }
    }
    catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Error getting bonded devices: $e'),
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
  }


  void _disconnect() {
    try{
      bluetooth.disconnect();
      setState(() => _connected = false);
    }
    catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Error getting bonded devices: $e'),
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
  }
}
