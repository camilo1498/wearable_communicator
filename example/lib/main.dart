import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wearable_communicator/wearable_communicator.dart';
import 'package:wearable_communicator_example/wear_response.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  TextEditingController? _controller;
  String value = '';
  String message = '';
  String key = '';
  WearResponse wearResponse = WearResponse();
  late SharedPreferences prefs;


  @override
  void initState() {
    super.initState();
    _getConnection();
    _init();
    _controller = TextEditingController();

    WearableListener.listenForMessage((msg) {
      debugPrint('message $msg');
      WearableCommunicator.sendMessage({
        "text": msg
      });
      setState(() => message = msg);
    });
    WearableListener.listenForDataLayer((msg) {
      debugPrint('Data layer flutter: $msg');
    });
  }

  _init() async{
    prefs = await SharedPreferences.getInstance();
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  _getConnection()async{
    final map = await WearableCommunicator.getNode();
    setState(() {
      wearResponse = WearResponse.fromJson(Map<String, dynamic>.from(map));
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
          actions: [
            IconButton(
              onPressed: () {
                _getConnection();
              },
              icon: const Icon(Icons.refresh),
            )
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30,),
              Text(
                wearResponse.connected ? 'Wear connected' : 'Wear disconnected',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: wearResponse.connected ? Colors.green : Colors.red

                ),
              ),
              const SizedBox(height: 30,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _wearInfo(title: 'Device id', subTitle: wearResponse.id != null ? wearResponse.id! : ''),
                  _wearInfo(title: 'Device name', subTitle: wearResponse.name != null ? wearResponse.name! : ''),
                ],
              ),
              const SizedBox(height: 30,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: TextField(
                  onChanged: (text) => setState(() => key = text),
                  decoration: const InputDecoration(
                      hintText: 'Saved key',
                      border: InputBorder.none
                  ),
                ),
              ),
              MaterialButton(
                child: const Text('Save Key'),
                onPressed: () async{
                  if(key != ''){
                    //debugPrint(key);
                    /// save in shared preferences
                    await prefs.setString('wear', key);

                    debugPrint('Saved Key: ${prefs.getString('wear')}');
                  }
                },
              ),
              const SizedBox(height: 30,),
              MaterialButton(
                child: const Text('Send token'),
                onPressed: () {
                  primaryFocus!.unfocus(disposition: UnfocusDisposition.scope);
                  if(wearResponse.connected){
                    WearableCommunicator.sendMessage({
                      "text": Random.secure().nextDouble().toString()
                    });
                  }
                },
              ),

              const SizedBox(height: 30,),
              Container(
                  alignment: Alignment.center,
                  child: Text(
                    message,
                    style: const TextStyle(
                        color: Colors.black
                    ),
                  )
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _wearInfo({required String title, required String subTitle}){
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green
          ),
        ),
        const SizedBox(height: 5,),
        Text(
          subTitle,
          style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12
          ),
        ),
      ],
    );
  }
}