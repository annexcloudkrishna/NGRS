import 'userdetails.dart';
import 'callingapi.dart';
import 'package:flutter/material.dart';

/// Flutter code sample for [Card].

void main() {
  runApp(const CardExamplesApp());
}

class CardExamplesApp extends StatefulWidget {
  const CardExamplesApp({key});
  @override
  State<CardExamplesApp> createState() => _CardExamplesAppState();
}

class _CardExamplesAppState extends State<CardExamplesApp> {
  var testemail = 'test347@test.com';
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          colorSchemeSeed: const Color(0xff6750a4), useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(title: Text('Welcome !')),
        body: Center(
          child: FutureBuilder(
            future: getPointsData(testemail),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var lifetimePoints;
                var pointsToNextTier;
                var siteId;
                var id;

                return Container(
                  height: 500,
                  margin: const EdgeInsets.all(10),
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      NameCard(nameValue: 'hi'),
                      StatusCard(statusValue: 'ji'),
                      TierCard(tierValue: 'hi'),
                      PointsCard(pointsValue: 'hi'),
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
      ),
    );
  }

  Future<UserDetails> getPointsData(String testemail) async {
    UserDetails response = await getRequestAPI(testemail);
    print(response);
    print(response.availablePoints);
    return response;
  }
}

/// An example of the elevated card type.
///
/// The default settings for [Card] will provide an elevated
/// card matching the spec:
///
/// https://m3.material.io/components/cards/specs#a012d40d-7a5c-4b07-8740-491dec79d58b
class ElevatedCardExample extends StatelessWidget {
  const ElevatedCardExample({key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Card(
        child: SizedBox(
          width: 300,
          height: 100,
          child: Center(child: Text('Status')),
        ),
      ),
    );
  }
}

// StatusCard
class StatusCard extends StatelessWidget {
  final String statusValue;
  const StatusCard({key, required this.statusValue});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: SizedBox(
          width: 300,
          height: 100,
          child: Center(
            child: Text('Current Status ' + statusValue),
          ),
        ),
      ),
    );
  }
}

// Tier Card
class TierCard extends StatelessWidget {
  final String tierValue;

  const TierCard({key, required this.tierValue});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: SizedBox(
          width: 300,
          height: 100,
          child: Center(child: Text('POINTS TO NEXT TIER ' + tierValue)),
        ),
      ),
    );
  }
}

// Point Card

class PointsCard extends StatelessWidget {
  final String pointsValue;

  const PointsCard({key, required this.pointsValue});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: SizedBox(
          width: 300,
          height: 100,
          child: Center(child: Text('POINTS BALANCE ' + pointsValue)),
        ),
      ),
    );
  }
}

class NameCard extends StatelessWidget {
  final String nameValue;
  const NameCard({key, required this.nameValue});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: SizedBox(
          width: 300,
          height: 100,
          child: Center(child: Text(nameValue)),
        ),
      ),
    );
  }
}
