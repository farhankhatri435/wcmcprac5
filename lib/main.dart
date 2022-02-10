// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Api {
  final Uri currencyURL = Uri.https(
    "free.currconv.com",
    "/api/v7/currencies",
    {"apiKey": "03a8b4cd699ac26a39b5"},
  );
  Future<List<String>> getCurrencies() async {
    http.Response res = await http.get(currencyURL);
    if (res.statusCode == 200) {
      var body = jsonDecode(res.body);
      var list = body["results"];
      List<String> currencies = (list.keys).toList();
      print(currencies);
      currencies.sort();
      return currencies;
    } else {
      throw Exception("Failed to connect to API");
    }
  }

// Getting Exchange Rate
  Future<double> getRate(String from, String to) async {
    final Uri rateUrl = Uri.https("free.currconv.com", "/api/v7/convert", {
      "apiKey": "0bacfa326dc9457b7349",
      "q": "${from}_$to",
      "compact": "ultra"
    });
    http.Response res = await http.get(rateUrl);
    if (res.statusCode == 200) {
      var body = jsonDecode(res.body);
      return body["${from}_$to"];
    } else {
      throw Exception("Failed to connect to API");
    }
  }
}

Widget currencyOption(
  List<String> items,
  String value,
  void onChange(val),
) {
  return Container(
    padding: EdgeInsets.symmetric(vertical: 7.0, horizontal: 30.0),
    decoration: BoxDecoration(
      color: Colors.green,
      borderRadius: BorderRadius.circular(8.0),
    ),
    child: DropdownButton<String>(
      value: value,
      onChanged: (String? val) {
        onChange(val);
      },
      items: items.map<DropdownMenuItem<String>>((String val) {
        return DropdownMenuItem(
          child: Text(val),
          value: val,
        );
      }).toList(),
    ),
  );
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
// Instance of API Client
  Api client = Api();
// Function to call API
  @override
  void initState() {
    super.initState();
    (() async {
      List<String> list = await client.getCurrencies();
      setState(() {
        currencies = list;
      });
    })();
  }

// Setting main colors
  Color kMainColor = Colors.blue;
  Color kSecondaryColor = Colors.green;
//Setting the variables
  List<String> currencies = [
    "INR",
    "GBP",
    "AUD",
    "EUR",
    "JPY",
    "CHF",
    "AFN",
    "ALL",
    "DZD",
    "AOA",
    "ARS",
    "USD"
  ];
  String from = "INR";
  String to = "USD";
//variables for exchange rate
  double rate = 1;
  String result = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kMainColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 18.0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextField(
                      onChanged: (value) async {
                        rate = await client.getRate(from, to);
                        setState(() {
                          result =
                              (rate * double.parse(value)).toStringAsFixed(3);
                        });
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: "Enter Amount",
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 18.0,
                          color: Colors.black,
                        ),
                      ),
                      style: TextStyle(
                        color: kMainColor,
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        currencyOption(currencies, from, (val) {
                          setState(() {
                            from = val;
                          });
                        }),
                        FloatingActionButton(
                          onPressed: () {
                            setState(() {
                              String temp = from;
                              from = to;
                              to = temp;
                            });
                          },
                          child: Icon(
                            Icons.swipe_rounded,
                            color: Colors.black,
                            size: 30,
                          ),
                          elevation: 10.0,
                          backgroundColor: kSecondaryColor,
                        ),
                        currencyOption(currencies, to, (val) {
                          setState(() {
                            to = val;
                          });
                        }),
                      ],
                    ),
                    SizedBox(height: 50.0),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Column(
                        children: [
                          Text(
                            result,
                            style: TextStyle(
                              color: kMainColor,
                              fontSize: 36.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
