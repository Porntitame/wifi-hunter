import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:test_a/model/signal.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import 'package:wifi_hunter/wifi_hunter.dart';
import 'package:wifi_hunter/wifi_hunter_result.dart';

class FormScreen extends StatefulWidget {
  const FormScreen({Key? key}) : super(key: key);

  @override
  _FormScreenState createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  WiFiHunterResult wiFiHunterResults = WiFiHunterResult();
  List wiFiHunterResult = [];
  Color huntButtonColor = Colors.lightBlue;

  @override
  void initState() {
    huntWiFis();
    super.initState();
  }

  double findFag(number) {
    return number * (number - 1);
  }

  Future<void> huntWiFis() async {
    setState(() => huntButtonColor = Colors.grey.shade200);

    try {
      wiFiHunterResults = (await WiFiHunter.huntWiFiNetworks)!;
      wiFiHunterResult = [];
      for (int index = 0; index < wiFiHunterResults.results.length; index++) {
        if (['Noon', 'BB Court C_FL1-1']
            .contains(wiFiHunterResults.results[index].SSID)) {
          wiFiHunterResult.add(wiFiHunterResults.results[index]);
        }
      }

      huntWiFis();
    } on PlatformException catch (exception) {
      print(exception.toString());
    }

    if (!mounted) return;

    setState(() => huntButtonColor = Colors.grey.shade200);
  }

  /*final formKey = GlobalKey<FormState>();
  signal myData = signal();
  //เตรียม Firebase
  final Future<FirebaseApp> firebase = Firebase.initializeApp();
  CollectionReference _dataCollection =
      FirebaseFirestore.instance.collection("signals");*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Scan Signal"),
      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: Form(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 20.0),
                  child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              huntButtonColor)),
                      onPressed: () => huntWiFis(),
                      child: const Text('Hunt Networks')),
                ),
                wiFiHunterResult.isNotEmpty
                    ? Container(
                        margin: const EdgeInsets.only(
                            bottom: 20.0, left: 30.0, right: 30.0),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(
                                wiFiHunterResult.length,
                                (index) => Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 10.0),
                                      child: ListTile(
                                          leading: Text(wiFiHunterResult[index]
                                                  .level
                                                  .toString() +
                                              ' dbm'),
                                          title: Text(
                                              wiFiHunterResult[index].SSID),
                                          subtitle: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text('BSSID : ' +
                                                    wiFiHunterResult[index]
                                                        .BSSID),
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
                                              ])),
                                    ))),
                      )
                    : Container()
              ],
            ),
          ),
        ),
      ),
    );
    /*return FutureBuilder(
        future: firebase,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Scaffold(
              appBar: AppBar(
                title: Text("Error"),
              ),
              body: Center(
                child: Text("${snapshot.error}"),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
              appBar: AppBar(
                title: Text("แบบฟอร์มบันทึกคะแนนสอบ"),
              ),
              body: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 20.0),
                      child: ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  huntButtonColor)),
                          onPressed: () => huntWiFis(),
                          child: const Text('Hunt Networks')),
                    ),
                    wiFiHunterResult.results.isNotEmpty
                        ? Container(
                            margin: const EdgeInsets.only(
                                bottom: 20.0, left: 30.0, right: 30.0),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: List.generate(
                                    wiFiHunterResult.results.length,
                                    (index) => Container(
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 10.0),
                                          child: ListTile(
                                              leading: Text(wiFiHunterResult
                                                      .results[index].level
                                                      .toString() +
                                                  ' dbm'),
                                              title: Text(wiFiHunterResult
                                                  .results[index].SSID),
                                              subtitle: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text('BSSID : ' +
                                                        wiFiHunterResult
                                                            .results[index]
                                                            .BSSID),
                                                    Text('Capabilities : ' +
                                                        wiFiHunterResult
                                                            .results[index]
                                                            .capabilities),
                                                    Text('Frequency : ' +
                                                        wiFiHunterResult
                                                            .results[index]
                                                            .frequency
                                                            .toString()),
                                                    Text('Channel Width : ' +
                                                        wiFiHunterResult
                                                            .results[index]
                                                            .channelWidth
                                                            .toString()),
                                                    Text('Timestamp : ' +
                                                        wiFiHunterResult
                                                            .results[index]
                                                            .timestamp
                                                            .toString())
                                                  ])),
                                        ))),
                          )
                        : Container()
                  ],
                ),
                /*SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            child: Text(
                              "บันทึกข้อมูล",
                              style: TextStyle(fontSize: 20),
                            ),
                            onPressed: () async {
                              await _dataCollection.add(
                                  {"SSID": myData.SSID, "RSSI": myData.level});
                            },
                          ),
                        )*/
              ),
            );
          }
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        });*/
  }
}
