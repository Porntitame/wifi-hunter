import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:test_a/model/signal.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:wifi_hunter/wifi_hunter.dart';
import 'package:wifi_hunter/wifi_hunter_result.dart';

import 'package:http/http.dart' as http;

class FormScreen extends StatefulWidget {
  late final Function addTx;

  @override
  _FormScreenState createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  WiFiHunterResult wiFiHunterResults = WiFiHunterResult();
  List wiFiHunterResult = [];
  List<Map> dataset = [];
  Color huntButtonColor = Colors.lightBlueAccent.shade100;
  final _locationController = TextEditingController();
  late String enteredLocation;

  // final formKey = GlobalKey<FormState>();
  // Signal mySignal = Signal();

  // @override
  // void initState() {
  //   huntWiFis();
  //   super.initState();
  // }

  Future<void> huntWiFis() async {
    setState(() => huntButtonColor = Colors.amber.shade300);

    try {
      wiFiHunterResults = (await WiFiHunter.huntWiFiNetworks)!;
      wiFiHunterResult = [];
      dataset = [];

      for (int index = 0; index < wiFiHunterResults.results.length; index++) {
        if (['Device_1', 'Device_2']
            .contains(wiFiHunterResults.results[index].SSID)) {
          wiFiHunterResult.add(wiFiHunterResults.results[index]);
          dataset.add({
            'SSID': wiFiHunterResults.results[index].SSID,
            'RSSI': wiFiHunterResults.results[index].level
          });
        }
      }
    } on PlatformException catch (exception) {
      print(exception.toString());
    }

    if (!mounted) return;

    setState(() => huntButtonColor = Colors.lightBlueAccent.shade100);
  }

  Future<void> _submitLocation() async {
    setState(() {
      enteredLocation = _locationController.text;
    });
    print(enteredLocation);
  }

  Future<void> _submitData() async {
    Map<String, dynamic> playload = {
      "case": enteredLocation,
      "dataset": dataset
    };

    try {
      var url = Uri.parse('http://192.168.137.17:8000/rssi-to-csv');
      var response = await http.post(
        url,
        body: json.encode(playload),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      Fluttertoast.showToast(
        msg: 'saved!',
        gravity: ToastGravity.CENTER,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'something error!',
        gravity: ToastGravity.CENTER,
      );
    }
    //print(playload);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        title: Text(
          "Scan Wi-Fi",
          style: TextStyle(color: Colors.grey.shade900),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: Form(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 20.0),
                  child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              huntButtonColor)),
                      onPressed: () => huntWiFis(),
                      child: Text(
                        'Scan Wi-Fi',
                        style: TextStyle(color: Colors.grey.shade800),
                      )),
                ),
                wiFiHunterResult.isNotEmpty
                    ? Column(
                        children: [
                          Container(
                            child: Column(
                              children: List.generate(
                                wiFiHunterResult.length,
                                (index) => Column(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 10.0),
                                      child: ListTile(
                                        leading: Text(wiFiHunterResult[index]
                                                .level
                                                .toString() +
                                            ' dbm'),
                                        title:
                                            Text(wiFiHunterResult[index].SSID),
                                        subtitle: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text('BSSID : ' +
                                                wiFiHunterResult[index].BSSID),
                                            Text('Capabilities : ' +
                                                wiFiHunterResult[index]
                                                    .capabilities),
                                            Text('Frequency : ' +
                                                wiFiHunterResult[index]
                                                    .frequency
                                                    .toString()),
                                            Text('Channel Width : ' +
                                                wiFiHunterResult[index]
                                                    .channelWidth
                                                    .toString()),
                                            Text('Timestamp : ' +
                                                wiFiHunterResult[index]
                                                    .timestamp
                                                    .toString())
                                          ],
                                        ),
                                      ),
                                    ),
                                    Divider(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Container(),
                TextField(
                  decoration: InputDecoration(labelText: 'Location'),
                  controller: _locationController,
                  onSubmitted: (_) => _submitLocation(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 100,
                      child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                Colors.amber.shade300)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(right: 8),
                              child: Icon(
                                Icons.save_alt_outlined,
                                color: Colors.blueAccent,
                              ),
                            ),
                            Text(
                              "save",
                              style: TextStyle(color: Colors.grey.shade800),
                            ),
                          ],
                        ),
                        onPressed: () async {
                          await _submitData();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
