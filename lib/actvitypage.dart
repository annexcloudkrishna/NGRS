import 'dart:async';
import 'dart:convert';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:veryfi_example/login.dart';
import 'callingapi.dart';
import 'activitydetails.dart';
import 'package:intl/intl.dart';
import 'main.dart';

void main() {
  runApp(const MyActivityApp());
}

refreshActivityApp() {
  runApp(const MyActivityApp());
}

class MyActivityApp extends StatelessWidget {
  const MyActivityApp({key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(useMaterial3: true),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Page'),
      ),
      body: const MyStatefulWidget(),
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
                refreshActivityApp();
              },
            ),
            ListTile(
              title: const Text('Log Out'),
              onTap: () async {
                final Future<SharedPreferences> _prefs =
                    SharedPreferences.getInstance();
                final SharedPreferences prefs = await _prefs;
                await prefs.remove('userEmail');
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const MyEmailValidation()));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({key});

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  // _MyStatefulWidgetState(email);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ActivityDetails>>(
      future: fetchData(),
      builder: (context, snapshot) {
        // print("snapshot");
        //print(snapshot);
        if (snapshot.hasData) {
          return SingleChildScrollView(
            child: DataTable(
              border: TableBorder.all(width: 0),
              columnSpacing: 30,
              columns: const [
                DataColumn(label: Text('DATE')),
                DataColumn(label: Text('ACTION')),
                DataColumn(label: Text('POINTS')),
              ],
              rows: List.generate(
                snapshot.data!.length,
                (index) {
                  var data = snapshot.data![index];
                  var points = 0;
                  return DataRow(cells: [
                    DataCell(
                      Text(convert(data.createDate)),
                    ),
                    DataCell(
                      Text(data.displayText != 'null'
                          ? checkActivity(data.displayText).toString()
                          : data.reason.toString()),
                    ),
                    DataCell(
                      Text(data.activity == 'Activity.CREDIT'
                          ? data.credit.toString()
                          : '-' + data.debit.toString()),
                    ),
                  ]);
                },
              ).toList(),
              showBottomBorder: true,
            ),
          );
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }
        // By default show a loading spinner.
        return const CircularProgressIndicator();
      },
    );
  }

  String convert(createDate) {
    DateTime now = DateTime.parse(createDate);
    String formattedDate = DateFormat.yMMMd().format(now);
    return formattedDate;
  }

  String checkActivity(activity) {
    //print(activity);
    if (activity == 'DisplayText.PURCHASE') {
      return 'Purchase';
    }
    return '';
  }

  String checkPoints(activity, points) {
    if (points == 'credit') {
      return 'Credit';
    } else {
      return 'Debit';
    }
  }
}

Future<List<ActivityDetails>> fetchData() async {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final SharedPreferences prefs = await _prefs;
  String email = prefs.getString('userEmail')!;
  //String email = 'qatesting0045@gmail.com';
  //var url = Uri.parse('https://jsonplaceholder.typicode.com/albums');
  //final response = await http.get(url);
  //print('Activity page email $email');
  final baseUrl = dotenv.env['BASE_URL'];
  final key = dotenv.env['SECRECT'];
  final sitename = dotenv.env['SITE_NAME'];
  final siteid = dotenv.env['SITE_ID'];
  var payload1 = '"$email"';
  var thmac = createHmac(key!, payload1);

  print(payload1);

  final expiration = (DateTime.now().microsecondsSinceEpoch) + 3600000;
  // print("expiration time => $expiration");

  final jwt = JWT(
      {"sub": sitename, "exp": expiration, "site_id": siteid, "hmac": thmac});

  final jwtheader = <String, String>{'alg': 'HS256', 'typ': 'JWT'};
  JWT(jwtheader);
  final token = jwt.sign(SecretKey(key));

  var url = '$baseUrl/users/$email/activity';

  final response = await http.get(
    Uri.parse(url),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'X-AnnexCloud-Site': '$siteid'
    },
    //body: jsonEncode(payload2.toString()), // Encode the payload as JSON
  );
  print(response.body);
  if (response.statusCode == 200) {
    print('activity data received');
    print(response.body);
    var tmp = json.decode(response.body);
    List jsonResponse = tmp["activityDetail"];
    print('activity data received');
    print(tmp["activityDetail"]);

    // return jsonResponse.map((data) => Data.fromJson(data)).toList();
    return jsonResponse.map((data) => ActivityDetails.fromJson(data)).toList();
  } else {
    throw Exception('Unexpected error occured!');
  }
}
