/// [dart-packages]
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:azblob/azblob.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

/// [flutter-packages]
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:mime/mime.dart';

/// [third-party-packages]
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// [veryfi-packages]
import 'package:veryfi/lens.dart';
import 'package:veryfi_example/userdetails.dart';

import 'actvitypage.dart';
import 'callingapi.dart';
import 'login.dart';
import 'steps.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loading_indicator/loading_indicator.dart';

import 'toggle.dart';

//import 'test.dart';

void main() async {
  await dotenv.load();
  // runApp(MyApp(email));
  // runApp( MaterialApp(home: MyApp()));
}

refreshDashboard() async {
  await dotenv.load();
  runApp(MyApp());
}

const List<Widget> Validation = <Widget>[
  Text('On'),
  Text('Off'),
];

class MyApp extends StatefulWidget {
  const MyApp({key});
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  var widgetsList = <Widget>[];
  var uploadid = 0;
  String email = '';
  String userStatus = 'ACTIVE';
  var availablePoints;
  var pointsToNextTier;
  var siteId;
  var id;
  bool isChecked = false;
  bool isValidate = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    userPointsData();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // final SharedPreferences prefs = await _prefs;
    // email = prefs.getString('userEmail')!;
    //userStatus = prefs.getString('userStatus')!;

    Map<String, dynamic> credentials = {
      'clientId':
          dotenv.env['VERYFI_CLIENT_ID'] ?? 'XXXX', //Replace with your clientId
      'userName':
          dotenv.env['VERYFI_USERNAME'] ?? 'XXXX', //Replace with your username
      'apiKey':
          dotenv.env['VERYFI_API_KEY'] ?? 'XXXX', //Replace with your apiKey
      'url': dotenv.env['VERYFI_URL'] ?? 'XXXX' //Replace with your url
    };

    Map<String, dynamic> settings = {
      'blurDetectionIsOn': true,
      'showDocumentTypes': true,
    };

    try {
      Veryfi.initLens(credentials, settings);
    } on PlatformException catch (e) {
      setState(() {
        var errorText = 'There was an error trying to initialize Lens:\n\n';
        errorText += '${e.code}\n\n';
        widgetsList.add(Text(errorText));
      });
    }
  }

  final Widget svg = new SvgPicture.asset(
    "assets/image.svg",
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      darkTheme: ThemeData(useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Welcome'),
        ),
        body: Center(
          child: FutureBuilder(
            future: userPointsData(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Container(
                  //height: Autocomplete,
                  margin: const EdgeInsets.all(10),
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      NameCard(nameValue: email),
                      StatusCard(statusValue: userStatus.toString()),
                      TierCard(tierValue: pointsToNextTier.toString()),
                      PointsCard(pointsValue: availablePoints.toString()),
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[200],
                            ),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const MyActivityApp()));
                            },
                            child: const Text('Activity Page'),
                          ),
                        ),
                      ),
                      Container(
                          alignment: Alignment.bottomCenter,
                          child: StatefulBuilder(builder: (context, setState) {
                            return CheckboxListTile(
                              value: isValidate,
                              controlAffinity: ListTileControlAffinity.leading,
                              onChanged: (bool? value) {
                                setState(() {
                                  isValidate = value!;
                                  print('checkbox value -> $value');
                                  //value = isChecked;
                                });
                              },
                              title: const Text(
                                  'Do you want to Validate receipt ?'),
                            );
                          })),
                    ],
                  ),
                );
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }
              // By default, show a loading spinner.
              return const CircularProgressIndicator();
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: onShowCameraPressed,
          child: Icon(Icons.camera_alt),
        ),
        drawer: Drawer(
          // Add a ListView to the drawer. This ensures the user can scroll
          // through the options in the drawer if there isn't enough vertical
          // space to fit everything.
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: (BoxDecoration(
                  color: Colors.blueAccent,
                  image: DecorationImage(
                      image: AssetImage('assets/images/logo.png'),
                      fit: BoxFit.scaleDown),
                )),
                //SvgPicture.asset('assets/images/logo.svg'),
                child: Text(''),
              ),
              ListTile(
                title: const Text('Home'),
                onTap: () {
                  refreshDashboard();
                },
              ),
              ListTile(
                title: const Text('Activity'),
                onTap: () {
                  ActivityPage();
                },
              ),
              ListTile(
                title: const Text('Log Out'),
                onTap: () {
                  logOut();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  userPointsData() async {
    final SharedPreferences prefs = await _prefs;
    email = prefs.getString('userEmail')!;
    var response = await userPointsDataAPI(email);
    //userStatus = prefs.getString('userStatus')!;
    //  print(response);
    availablePoints = response['availablePoints'];
    pointsToNextTier = response['pointsToNextTier'];
    print(' Available Points -> $availablePoints');
    print(' pointsToNextTier -> $pointsToNextTier');
    return response;
  }

  void startListeningEvents() {
    Veryfi.setDelegate(handleVeryfiEvent);
  }

  void onShowCameraPressed() async {
    Veryfi.setDelegate(handleVeryfiEvent);
    await Veryfi.showCamera();
  }

  Future<void> handleVeryfiEvent(
      LensEvent eventType, Map<String, dynamic> response) async {
    //LinearProgressIndicator();
    //var uploadid=0;

    setState(() {
      // const CircularProgressIndicator();
      //CircularProgressIndicator();
      //  var veryfiResult = '${eventType.toString()}\n\n';

      widgetsList.add(const CircularProgressIndicator());
      /*  veryfiResult = '${response.toString()}\n\n';
      widgetsList.add(Text(veryfiResult));*/
    });

    if (eventType == LensEvent.close) {
      ActivityPage();
    }

    if (eventType.index == 3) {
      if (response["msg"] != null &&
          response["msg"].toString().contains("img_original_path")) {
        print('response   ->' + response["data"].toString());
        print('Event occured ->' + eventType.index.toString());
        print('Event name ->' + eventType.name);
        print('user name ->' + email);

        var imagePath = response["data"].toString();
        print('file local path  ->' + imagePath);
        // send image to Azure
        uploadid = await uploadImage(imagePath, email);

        //  var data = resp);
        print("Image upload successful with ID -> $uploadid");
      }
    }

    if (eventType.index == 3) {
      if (response["data"] != null &&
          response["data"].toString().contains(".jpg")) {
        var imagePath = response["data"].toString();

/*
        if (imagePath.contains("thumbnail")) {
          widgetsList.add(Text(
            "Thumbnail",
            style: TextStyle(fontWeight: FontWeight.normal),
          ));
          widgetsList.add(
            Center(
              child: SizedBox(
                height: 100,
                width: 100,
                child: Image.file(
                  File(imagePath),
                ),
              ),
            ),
          );
        } else {
          widgetsList.add(Text(
            "Original",
            style: TextStyle(fontWeight: FontWeight.normal),
          ));
          widgetsList.add(
            Image.file(
              File(imagePath),
            ),
          );
        }*/
      }
    }

    if (eventType == LensEvent.success) {
      //debugPrint("[success] data: ${response}");
      var docId = response['data']['id'];
      //print('Document Details -> ' +resData.toString());
      print('Send Upload ID & Document ID to AC API ');
      print('Upload ID after success event -> $uploadid');
      if (uploadid != 0) {
        print('Send Upload ID & Document ID to AC API success');
        await ACpostRequestAPI(docId, uploadid, email, isValidate);
        refreshActivityApp();
      }
    }

    widgetsList.add(SizedBox(
        //height: 0,
        ));
  }

  Future<int> uploadImage(imagepath, String email) async {
    File file = File(imagepath);
    var filePath = file.path;
    print("upload image Name to Azure path -> " + filePath);
    String fileName = file.path.split('/').last;
    print("upload image Name to Azure -> " + fileName);
    String timenow = DateTime.now().millisecondsSinceEpoch.toString();
    String datenow = (DateTime.now().toIso8601String()).toString();
    String fname = '71493361_' + datenow + '_' + timenow + '_' + fileName;
    print("upload image Name to Azure -> " + fname);
    // read file as Uint8List

    Uint8List? content = await file.readAsBytes();
    var storage = AzureStorage.parse(
        'DefaultEndpointsProtocol=https;AccountName=socialannexuat;AccountKey=bRUxHvBQb06eioU+V18irvjz2GLB1U6JNn7ilCAr0LAD2g5DCnygfA80nBLayO9IJuB++VQUI6Rj+ASt/pVzKQ==');
    String container = "ocr";
    // get the mine type of the file
    String? contentType = lookupMimeType(filePath);
    await storage.putBlob('/$container/$fname',
        bodyBytes: content, contentType: contentType, type: BlobType.blockBlob);

    print("image upload to Azure done ");
    print('Filename   -> $fname');
    print('URL -> https://socialannexuat.blob.core.windows.net/ocr/$fname');
    String url = 'https://socialannexuat.blob.core.windows.net/ocr/$fname';
    int uploadid = await postImageToACAPI(url, email);
    return uploadid;
  }

  ActivityPage() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => MyActivityApp()));
  }

  logOut() async {
    final SharedPreferences prefs = await _prefs;
    await prefs.remove('userEmail');
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => const MyEmailValidation()));
  }
}
