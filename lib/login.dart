import 'dart:convert';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
//import 'package:veryfi_example/userdetails.dart';
import 'callingapi.dart';
//import 'steps.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter_svg/svg.dart';
import 'main.dart';
import 'package:shared_preferences/shared_preferences.dart';

// main method that run the runApp.
Future<void> main() async {
  await dotenv.load();
  runApp(const MaterialApp(home: MyEmailValidation()));
}

class MyEmailValidation extends StatefulWidget {
  const MyEmailValidation({Key? key}) : super(key: key);

  @override
  State<MyEmailValidation> createState() => _MyEmailValidationState();
}

validateUser(String email) async {
  print('GET request call');
  final baseUrl = dotenv.env['BASE_URL'];
  final key = dotenv.env['SECRECT'];
  final sitename = dotenv.env['SITE_NAME'];
  final siteid = dotenv.env['SITE_ID'];

  var payload1 = '"$email"';
  var thmac = createHmac(key!, payload1);

  final expiration = (DateTime.now().microsecondsSinceEpoch) + 3600000;
  print("expiration time => $expiration");

  final jwt = JWT(
      {"sub": sitename, "exp": expiration, "site_id": siteid, "hmac": thmac});

  final jwtheader = <String, String>{'alg': 'HS256', 'typ': 'JWT'};
  JWT(jwtheader);
  final token = jwt.sign(SecretKey(key));

  var url = '$baseUrl/users/$email';
  print("URL => $url");
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
    var data = jsonDecode(response.body);
    print(data);
    return data['status'];
    // return true;
  } else {
    print('Login Failed !');
    return false;
  }
}

class _MyEmailValidationState extends State<MyEmailValidation> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  // text editing controller
  TextEditingController inputcontroller = TextEditingController();
  // Method to validate the email the take
  // the user email as an input and
  // print the bool value in the console.
  Future<void> validateemail(String email) async {
    final SharedPreferences prefs = await _prefs;
    bool isvalid = EmailValidator.validate(email);
    print(isvalid);
    if (isvalid) {
      String validUser = await validateUser(email);
      // await Future.delayed(const Duration(seconds: 0));
      //print('USer status is ->'+validUser);
      prefs.setString('userEmail', email);
      //prefs.setString('userstatus', validUser);
      if (validUser == 'ACTIVE') {
        Navigator.push(context, MaterialPageRoute(builder: (_) => MyApp()));
      } else {
        print("Invalid User");
      }
    } else {
      print("Invalid Email");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Login Page'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(110.0),
              ),
              SvgPicture.asset('assets/images/logo.svg'),
              const Padding(
                padding: EdgeInsets.all(10.0),
              ),
              TextFormField(
                controller: inputcontroller,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                style: const TextStyle(
                  fontSize: 18,
                ),
                decoration: const InputDecoration(
                  hintText: "Enter Email",
                  border: OutlineInputBorder(),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(10.0),
              ),
              ElevatedButton(
                onPressed: (() => validateemail(inputcontroller.text)),
                child: const Text('Submit',
                    style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
