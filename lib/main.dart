/// Flutter code sample for CupertinoPageScaffold

// This example shows a [CupertinoPageScaffold] with a [ListView] as a [child].
// The [CupertinoButton] is connected to a callback that increments a counter.
// The [backgroundColor] can be changed.

// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const MyApp());

/// This is the main application widget.
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const String _title = 'House Price Prediction';

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      debugShowCheckedModeBanner: false,
      title: _title,
      home: MyStatefulWidget(),
    );
  }
}

/// This is the stateful widget that the main application instantiates.
class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key? key}) : super(key: key);

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

/// This is the private State class that goes with MyStatefulWidget.
class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  late Future<Album> futureAlbum;

  final myAverageController = TextEditingController();
  final myPupilController = TextEditingController();
  final myPorcentageController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myAverageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      // Uncomment to change the background color
      // backgroundColor: CupertinoColors.systemPink,
      navigationBar: const CupertinoNavigationBar(
        middle: Text(
          'House Price Prediction',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      child: Center(
        child: SafeArea(
            child: Container(
          padding: const EdgeInsets.all(16.0),
          alignment: Alignment.center,
          child: Column(
            children: [
              Image.asset('assets/images/Wavy_REst-01_Single-06.jpg'),

              CupertinoTextField(
                controller: myAverageController,
                padding: EdgeInsets.all(16.0),
                placeholder: 'Average number of rooms per dwelling',
                style: TextStyle(fontWeight: FontWeight.bold),
                cursorColor: Colors.black,
              ),

              const SizedBox(height: 10.0), // give it width

              CupertinoTextField(
                controller: myPupilController,
                padding: EdgeInsets.all(16.0),
                placeholder: 'Pupil-teacher ratio by town',
                style: TextStyle(fontWeight: FontWeight.bold),
                cursorColor: Colors.black,
              ),
              const SizedBox(height: 10.0), // give it width
              CupertinoTextField(
                controller: myPorcentageController,
                padding: EdgeInsets.all(16.0),
                placeholder: '% lower status of the population',
                style: TextStyle(fontWeight: FontWeight.bold),
                cursorColor: Colors.black,
              ),
              const SizedBox(height: 30.0),

              SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  color: Colors.black,
                  child: Text(
                    'Predict',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  disabledColor: CupertinoColors.black,
                  onPressed: () {
                    var average_number = myAverageController.text;
                    var pupil_number = myPupilController.text;
                    var porcentage_number = myPorcentageController.text;

                    setState(() {
                      futureAlbum = fetchAlbum(
                          average_number, pupil_number, porcentage_number);
                    });

                    showCupertinoModalPopup(
                        context: context,
                        builder: (BuildContext context) =>
                            CupertinoPopupSurface(
                                child: Container(
                                    alignment: Alignment.center,
                                    width: 400,
                                    height: 300,
                                    child: Center(
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            height: 50.0,
                                          ),
                                          Text(
                                            "The predicted price  is:",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Center(
                                            child: FutureBuilder<Album>(
                                              future: futureAlbum,
                                              builder: (context, snapshot) {
                                                if (snapshot.hasData) {
                                                  return Text(
                                                    snapshot.data!.price +
                                                        ' \$',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  );
                                                } else if (snapshot.hasError) {
                                                  return Text(
                                                      '${snapshot.error}');
                                                }

                                                // By default, show a loading spinner.
                                                return const CircularProgressIndicator();
                                              },
                                            ),
                                          )
                                        ],
                                      ),
                                    ))));
                  },
                ),
              ),
            ],
          ),
        )),
      ),
    );
  }
}

Future<Album> fetchAlbum(
    average_number, pupil_number, porcentage_number) async {
  var url = 'http://127.0.0.1:5000/?rm=' +
      average_number.toString() +
      '&ptratio=' +
      pupil_number.toString() +
      '&lstat=' +
      porcentage_number.toString();

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.

    return Album.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

class Album {
  final String price;

  Album({
    required this.price,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      price: json['price'],
    );
  }
}
