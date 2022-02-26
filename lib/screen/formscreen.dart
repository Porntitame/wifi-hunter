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
  var submit;
  int saveCount = 0;
  bool isStoped = false;

  @override
  void initState() {
    submit = () async {
      await _submitData();
    };
    super.initState();
  }

  Future<void> huntWiFis() async {
    if (!isStoped) {
      setState(() => huntButtonColor = Colors.amber.shade300);

      try {
        wiFiHunterResults = (await WiFiHunter.huntWiFiNetworks)!;
        wiFiHunterResult = [];
        dataset = [];

        for (int index = 0; index < wiFiHunterResults.results.length; index++) {
          // if ([
          //   'cc:2d:21:91:6c:61',
          //   '74:22:bb:8a:02:5c',
          //   '00:2e:c7:8f:f1:68',
          //   '00:2e:c7:8f:f2:67',
          //   '78:44:76:ec:26:48',
          //   'cc:2d:21:91:81:c1',
          //   '00:2e:c7:8f:f1:c6',
          //   '00:2e:c7:8f:f1:61',
          //   '00:2e:c7:8f:f1:63',
          //   '00:2e:c7:8f:f1:69'
          // ].contains(wiFiHunterResults.results[index].BSSID))
          {
            wiFiHunterResult.add(wiFiHunterResults.results[index]);
            dataset.add({
              'BSSID': wiFiHunterResults.results[index].BSSID,
              'RSSI': wiFiHunterResults.results[index].level,
            });
          }
        }
        Future.delayed(Duration(seconds: 2), () {
          huntWiFis();
        });
      } on PlatformException catch (exception) {
        print(exception.toString());
      }

      if (!mounted) return;

      setState(() => huntButtonColor = Colors.lightBlueAccent.shade100);
    }
  }

  Future<void> _submitLocation() async {
    setState(() {
      saveCount = 0;
      enteredLocation = _locationController.text;
    });
    print(enteredLocation);
  }

  Future<void> clickHuntWifi() async {
    isStoped = false;
    await huntWiFis();
  }

  Future<void> _submitData() async {
    setState(() => submit = null);

    Map<String, dynamic> playload = {
      "case": enteredLocation,
      "dataset": dataset
    };

    try {
      var url = Uri.parse('http://161.246.18.222:80/rssi-to-coordinate');
      var response = await http.post(
        url,
        body: json.encode(playload),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      setState(() {
        submit = () async {
          await _submitData();
        };
      });

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      setState(() {
        saveCount++;
      });
      Fluttertoast.showToast(
        msg: 'saved!(${saveCount})',
        gravity: ToastGravity.CENTER,
      );
    } catch (e) {
      setState(() {
        submit = () async {
          await _submitData();
        };
      });
      Fluttertoast.showToast(
        msg: 'something error!',
        gravity: ToastGravity.CENTER,
      );
    }
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
                      onPressed: () => clickHuntWifi(),
                      child: Text(
                        'Scan Wi-Fi',
                        style: TextStyle(color: Colors.grey.shade800),
                      )),
                ),
                Container(
                  child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.grey.shade300)),
                      onPressed: () => isStoped = true,
                      child: Text(
                        'Stop',
                        style: TextStyle(color: Colors.grey.shade800),
                      )),
                ),
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
                        onPressed: submit,
                      ),
                    ),
                  ],
                ),
                wiFiHunterResult.isNotEmpty
                    ? Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.wifi,
                                color: Colors.amber,
                              ),
                              Text(
                                '  Number of transmitter : ${wiFiHunterResult.length}',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
