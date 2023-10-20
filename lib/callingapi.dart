import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'userdetails.dart';

createHmac(String secreteKey, String jsonPayloadObj) {
  List<int> key = utf8.encode(secreteKey);
  List<int> jsonPayload = utf8.encode(jsonPayloadObj);
  var enjsonPayload = utf8.encode(base64Encode(jsonPayload));
  var hmacSha256 = new Hmac(sha256, key);
  var digest = hmacSha256.convert(enjsonPayload);
  var enhmc = base64.encode(digest.bytes);
  return enhmc;
}

Future<String> ACpostRequestAPI(
    doc_id, upload_id, String email, bool isValidate) async {
  print('POST request call');
  final baseUrl = dotenv.env['BASE_URL'];
  final key = dotenv.env['SECRECT'];
  final sitename = dotenv.env['SITE_NAME'];
  final siteid = dotenv.env['SITE_ID'];
  final Map<String, dynamic> data;
  if (isValidate) {
    data = {'email': '$email', 'doc_id': doc_id, 'upload_id': upload_id};
  } else {
    data = {
      'email': '$email',
      'doc_id': doc_id,
      'upload_id': upload_id,
      'skip_validation': 1
    };
  }

  final String jsonpayload3 = jsonEncode(data);
  print('payload to API');
  print(jsonpayload3);
  var thmac2 = createHmac(key!, jsonpayload3);
  final expiration = (DateTime.now().microsecondsSinceEpoch) + 3600000;
  final jwt = JWT(
      {"sub": sitename, "exp": expiration, "site_id": siteid, "hmac": thmac2});
  final jwtheader = <String, String>{'alg': 'HS256', 'typ': 'JWT'};
  JWT(jwtheader);
  final token = jwt.sign(SecretKey(key));
  var url1 = '$baseUrl/flutterapi';
  print(" token " + token);

  final response1 = await http.post(
    Uri.parse(url1),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'X-AnnexCloud-Site': '$siteid',
    },
    body: jsonpayload3, // Encode the payload as JSON
  );
  print(response1.body.toString());
  if (response1.statusCode == 200) {
    print(response1.body.toString());
  } else {
    print('Document upload failed !');
  }
  return 'success';
}

Future<int> postImageToACAPI(imageUrl, String useremail) async {
  print('POST request call');
  final baseUrl = dotenv.env['BASE_URL'];
  final key = dotenv.env['SECRECT'];
  final sitename = dotenv.env['SITE_NAME'];
  final siteid = dotenv.env['SITE_ID'];
  var url = imageUrl;
  //String useremail=useremail;
  print('image to upload $imageUrl');
  final Map<String, dynamic> data = {
    'email': '$useremail',
    'image_url': base64.encode(utf8.encode(url)),
  };
  final String jsonpayload3 = jsonEncode(data);
  print('payload to API');
  print(jsonpayload3);
  var thmac2 = createHmac(key!, jsonpayload3);
  final expiration = (DateTime.now().microsecondsSinceEpoch) + 3600000;
  final jwt = JWT(
      {"sub": sitename, "exp": expiration, "site_id": siteid, "hmac": thmac2});
  final jwtheader = <String, String>{'alg': 'HS256', 'typ': 'JWT'};
  JWT(jwtheader);
  final token = jwt.sign(SecretKey(key));
  var url1 = '$baseUrl/generateuploadid';
  print(" token " + token);

  final response1 = await http.post(
    Uri.parse(url1),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'X-AnnexCloud-Site': '$siteid',
    },
    body: jsonpayload3, // Encode the payload as JSON
  );
  print(response1.body.toString());

  if (response1.statusCode == 200) {
    //print(response1.body.toString());
    var data = jsonDecode(response1.body);
    int id = int.parse(data['uploadid']);
    print('Image upload successful ->' + data['uploadid']);
    return id;
  } else {
    print('Image upload failed !');
    return 0;
  }
}

Future<int> postRequestAPI(imageUrl) async {
  print('POST request call');
  final baseUrl = dotenv.env['BASE_URL'];
  final key = dotenv.env['SECRECT'];
  final sitename = dotenv.env['SITE_NAME'];
  final siteid = dotenv.env['SITE_ID'];
  var url = imageUrl;
  print('image to upload $imageUrl');
  final Map<String, dynamic> data = {
    'email': 'test.uat.10001062@gmail.com',
    'image_url': base64.encode(utf8.encode(url)),
  };
  final String jsonpayload3 = jsonEncode(data);
  print('payload to API');
  print(jsonpayload3);
  var thmac2 = createHmac(key!, jsonpayload3);
  final expiration = (DateTime.now().microsecondsSinceEpoch) + 3600000;
  final jwt = JWT(
      {"sub": sitename, "exp": expiration, "site_id": siteid, "hmac": thmac2});
  final jwtheader = <String, String>{'alg': 'HS256', 'typ': 'JWT'};
  JWT(jwtheader);
  final token = jwt.sign(SecretKey(key));
  var url1 = '$baseUrl/generateuploadid';
  print(" token " + token);
  // var  payload4 = base64.encode(utf8.encode(jsonEncode(payload3)));
  // print("encoded payload " + payload4);
  final response1 = await http.post(
    Uri.parse(url1),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'X-AnnexCloud-Site': '$siteid',
    },
    body: jsonpayload3, // Encode the payload as JSON
  );
  print(response1.body.toString());

  if (response1.statusCode == 200) {
    //print(response1.body.toString());
    var data = jsonDecode(response1.body);
    int id = int.parse(data['uploadid']);
    print('Image upload successful ->' + data['uploadid']);
    return id;
  } else {
    print('Image upload failed !');
    return 0;
  }
}

getRequestAPI(String email) async {
  print('GET request call');
  final baseUrl = dotenv.env['BASE_URL'];
  final key = dotenv.env['SECRECT'];
  final sitename = dotenv.env['SITE_NAME'];
  final siteid = dotenv.env['SITE_ID'];

  var payload1 = '"$email"';
  var thmac = createHmac(key!, payload1);

  final expiration = (DateTime.now().microsecondsSinceEpoch) + 3600000;
  // print("expiration time => $expiration");

  final jwt = JWT(
      {"sub": sitename, "exp": expiration, "site_id": siteid, "hmac": thmac});

  final jwtheader = <String, String>{'alg': 'HS256', 'typ': 'JWT'};
  JWT(jwtheader);
  final token = jwt.sign(SecretKey(key));

  var url = '$baseUrl/points/$email';

  final response = await http.get(
    Uri.parse(url),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'X-AnnexCloud-Site': '$siteid'
    },
    //body: jsonEncode(payload2.toString()), // Encode the payload as JSON
  );
  if (response.statusCode == 200) {
    return UserDetails.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load album');
  }
}

// To get user points

userPointsDataAPI(String email) async {
  print('GET request call');
  final baseUrl = dotenv.env['BASE_URL'];
  final key = dotenv.env['SECRECT'];
  final sitename = dotenv.env['SITE_NAME'];
  final siteid = dotenv.env['SITE_ID'];

  var payload1 = '"$email"';
  var thmac = createHmac(key!, payload1);

  final expiration = (DateTime.now().microsecondsSinceEpoch) + 3600000;
  // print("expiration time => $expiration");

  final jwt = JWT(
      {"sub": sitename, "exp": expiration, "site_id": siteid, "hmac": thmac});

  final jwtheader = <String, String>{'alg': 'HS256', 'typ': 'JWT'};
  JWT(jwtheader);
  final token = jwt.sign(SecretKey(key));

  var url = '$baseUrl/points/$email';

  final response = await http.get(
    Uri.parse(url),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'X-AnnexCloud-Site': '$siteid'
    },
    //body: jsonEncode(payload2.toString()), // Encode the payload as JSON
  );
  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);
    print(data);
    return data;
  } else {
    throw Exception('Unable to fetch data');
  }
}

// For Name Call Start

activityAPI() async {
  print('GET request call');
  final baseUrl = dotenv.env['BASE_URL'];
  final key = dotenv.env['SECRECT'];
  final sitename = dotenv.env['SITE_NAME'];
  final siteid = dotenv.env['SITE_ID'];
  var payload1 = '"test.uat.10001062@gmail.com"';
  var thmac = createHmac(key!, payload1);
  print(payload1);

  final expiration = (DateTime.now().microsecondsSinceEpoch) + 3600000;
  // print("expiration time => $expiration");

  final jwt = JWT(
      {"sub": sitename, "exp": expiration, "site_id": siteid, "hmac": thmac});

  final jwtheader = <String, String>{'alg': 'HS256', 'typ': 'JWT'};
  JWT(jwtheader);
  final token = jwt.sign(SecretKey(key));

  var url = '$baseUrl/users/test.uat.10001062@gmail.com/activity';

  final response = await http.get(
    Uri.parse(url),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'X-AnnexCloud-Site': '$siteid'
    },
    //body: jsonEncode(payload2.toString()), // Encode the payload as JSON
  );
  if (response.statusCode == 200) {
    print(response.body.toString());
  } else {
    print(response.body.toString());
  }
  var data = jsonDecode(response.body);
  return data;
}

// For Name Call End

putRequestAPI() async {
  final key = dotenv.env['SECRECT'];
  final sitename = dotenv.env['SITE_NAME'];
  final siteid = dotenv.env['SITE_ID'];
  final baseUrl1 = dotenv.env['BASE_URL'];

  final expiration1 = (DateTime.now().microsecondsSinceEpoch) + 3600000;
  final Map<String, dynamic> payload2 = {
    'id': 'test.uat.10001062@gmail.com',
    'email': 'test.uat.10001062@gmail.com',
    'firstName': 'Jubaed',
    'lastName': 'Prince',
    'optInStatus': 'YES',
    'phone': '111111111'
  };

  var thmac1 = createHmac(key!, jsonEncode(payload2));

  final jwt1 = JWT(
      {"sub": sitename, "exp": expiration1, "site_id": siteid, "hmac": thmac1});

  final jwtheader1 = <String, String>{'alg': 'HS256', 'typ': 'JWT'};
  JWT(jwtheader1);
  final token1 = jwt1.sign(SecretKey(key));

  var url1 = '$baseUrl1/users/test.uat.10001062@gmail.com';

  final response1 = await http.put(
    Uri.parse(url1),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token1',
      'X-AnnexCloud-Site': '$siteid',
    },
    body: jsonEncode(payload2), // Encode the payload as JSON
  );
  print(response1.body.toString());
}

generatoken(String siteid, String sitename, String key) async {
  //getRequestAPI();
  //putRequestAPI();
}

class CallingApi extends StatefulWidget {
  const CallingApi({key});
  @override
  State<CallingApi> createState() => _CallingApiState();
}

class _CallingApiState extends State<CallingApi> {
  final url = "https://jsonplaceholder.typicode.com/todos";
  var data;
  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    var uri = await http.get(Uri.http('jsonplaceholder.typicode.com', 'todos'));

    final sname = dotenv.env['SITE_NAME'];
    final sid = dotenv.env['SITE_ID'];
    final secret = dotenv.env['SECRECT'];

    //generatoken(siteid, sitename, skey);
    generatoken(sid!, sname!, secret!);

    if (uri.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      data = jsonDecode(uri.body);
      // print(data);
      setState(() {});
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView.builder(itemBuilder: (BuildContext context, int index) {
      return Card(
        child: ListTile(title: Text(data[index]["title"])),
      );
    }));
  }
}
