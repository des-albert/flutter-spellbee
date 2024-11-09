import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SpellBee',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SpellForm(),
    );
  }
}

class SpellForm extends StatefulWidget {
  const SpellForm({super.key});

  @override
  State<SpellForm> createState() => _SpellFormState();
}

class _SpellFormState extends State<SpellForm> {
  TextEditingController outerLetters = TextEditingController();
  TextEditingController centerLetter = TextEditingController();

  LineSplitter ls = const LineSplitter();
  int wordLimit = 5;
  int outer = ~0;
  int common = 0;
  int score = 0;
  String base = "";
  String center = "";
  String loadedData = "";
  String versionText = "";
  late List<String> results = [];
  late List<int> count = [];

  bool _resultVisible = false;

  Future<void> _loadData() async {
    String loadedData = await rootBundle.loadString('assets/words.txt');
    List<String> words = ls.convert(loadedData);
    versionText = await rootBundle.loadString('assets/version.txt');

    score = 0;

    for (String word in words) {
      int mask = 0;
      int match = 0;
      int center = 0;
      int total, i;

      List<int> chars = word.codeUnits;
      for (int p in chars) {
        if (p < 97) {
          mask |= 1 << (p - 65);
        } else {
          mask |= 1 << (p - 97);
        }
      }
      match = mask & outer;
      center = mask & common;
      if (match == 0 && center != 0 && word.length >= wordLimit) {
        results.add(word);
        total = 0;
        for (i = 0; i < 26; i++) {
          if ((outer >> i) & 1 == 0 && (mask >> i) & 1 == 1) ++total;
        }
        count.add(total);
        if (total == 7) score += 7;
        if (word.length > 4) {
          score += word.length;
        } else {
          score += 1;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DB\'r SpellBee Solver'),
        backgroundColor: Colors.lightBlue.shade600,
        centerTitle: true,
      ),
      body: Container(
        color: Colors.blueGrey.shade200,
        child: Column(
          children: <Widget>[
            const Divider(
              height: 10,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                SizedBox(
                  width: 150,
                  height: 40,
                  child: TextField(
                    controller: outerLetters,
                    textAlign: TextAlign.center,
                    textAlignVertical: TextAlignVertical.center,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 25,
                      color: Colors.deepOrangeAccent,
                    ),
                    decoration: InputDecoration(
                        hintText: 'outer letters',
                        hintStyle:
                            const TextStyle(fontSize: 20, color: Colors.blue),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.indigoAccent, width: 2.0),
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0)),
                        contentPadding: const EdgeInsets.only(bottom: 15)),
                  ),
                ),
                SizedBox(
                  width: 75,
                  height: 40,
                  child: TextField(
                    controller: centerLetter,
                    textAlign: TextAlign.center,
                    textAlignVertical: TextAlignVertical.center,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 25,
                      color: Colors.green,
                    ),
                    decoration: InputDecoration(
                        hintText: 'center',
                        hintStyle:
                            const TextStyle(fontSize: 20, color: Colors.blue),
                        isDense: true,
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.indigoAccent, width: 2.0),
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0)),
                        contentPadding: const EdgeInsets.only(bottom: 15)),
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blueAccent,
                  ),
                  onPressed: () async {
                    base = outerLetters.text;
                    List<int> chars = base.codeUnits;
                    if (chars.length == 6) {
                      outer = ~0;
                      for (int p in chars) {
                        if (p < 97) {
                          outer ^= 1 << (p - 65);
                        } else {
                          outer ^= 1 << (p - 97);
                        }
                      }

                      common = 0;
                      center = centerLetter.text;
                      int c = center.codeUnitAt(0);
                      if (c < 97) {
                        common |= 1 << (c - 65);
                      } else {
                        common |= 1 << (c - 97);
                      }

                      outer ^= common;

                      results.clear();
                      count.clear();

                      await _loadData();

                      setState(() {
                        results.length;
                      });
                      _resultVisible = true;
                    }
                  },
                  child: const Text('Solve'),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blueGrey,
                  ),
                  onPressed: () async {
                    centerLetter.text = "";
                    outerLetters.text = "";
                    _resultVisible = false;
                    results.clear();
                    count.clear();
                    setState(() {});
                  },
                  child: const Text('Clear'),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text('Word Length'),
                Radio(
                  value: 4,
                  groupValue: wordLimit,
                  onChanged: (val) {
                    setState(() {
                      wordLimit = val!;
                    });
                  },
                ),
                const Text('4'),
                Radio(
                  value: 5,
                  groupValue: wordLimit,
                  onChanged: (val) {
                    setState(() {
                      wordLimit = val!;
                    });
                  },
                ),
                const Text('5')
              ],
            ),
            const Divider(
              height: 10,
            ),
            Visibility(
              visible: _resultVisible,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Text(
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.orange
                      ),
                      '${results.length} words score $score'),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Visibility(
                      visible: _resultVisible,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            width: 350,
                            padding: const EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              color: Colors.green[100],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.grey,
                              ),
                            ),
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 5.0,
                              ),
                              itemCount: results.length,
                              itemBuilder: (BuildContext context, int index) {
                                if (count[index] == 7) {
                                  return Text(
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.redAccent,
                                      ),
                                      results[index]);
                                } else {
                                  return Text(
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.blueAccent,
                                      ),
                                      results[index]);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Visibility(
              visible: _resultVisible,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.blue,
                      ),
                      versionText),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
