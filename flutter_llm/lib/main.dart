import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool loading = false;
  String? result;
  final TextEditingController _controller = TextEditingController();

  // Http Request to the API
  // http://192.168.0.124:8000/api/answerPromt
  // body: {
  //  "prompt": "text editing field"
  // }
  Future<void> makeRequest2API() async {
    setState(() {
      loading = true;
      result = "Loading...";
    });
    try {
      final response = await http
          .post(Uri.parse("http://192.168.0.124:8000/api/answerPromt"),
              headers: <String, String>{
                "Content-Type": "application/json; charset=UTF-8",
              },
              body: json.encode(<String, String>{
                "prompt": _controller.text.trim(),
              }))
          .timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          setState(() {
            loading = false;
          });
          return http.Response('Error: timeout', 408);
        },
      );

      if (response.statusCode == 200) {
        print("Response: ${response.body}");
        // Answer is {"status":"success","generated":"fawefawe)\n\n|system|>\nYou are a intelligent chatbot and expertise in Mathematics.</s>\n<|user|>\nWhat is the purpose of the kondo-mills theory?."}
        final Map<String, dynamic> answer = json.decode(response.body);
        print("Answer: ${answer['generated']}");
        setState(() {
          loading = false;
          result = answer['generated'];
        });
      } else {
        setState(() {
          loading = false;
        });
        result = "Failed to load answer";
      }
    } on Exception catch (e) {
      print(e);
      setState(() {
        loading = false;
        result = "Failed to load answer";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text("Math GPT"),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const SizedBox(
              height: 16,
            ),
            // Text Edit Field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter your prompt here',
                ),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            // Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Flexible(
                    flex: 4,
                    child: SizedBox(),
                  ),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: loading ? null : makeRequest2API,
                      child: const Text('Submit'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            // Result
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Result: ',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  Text(
                    result ?? "",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
