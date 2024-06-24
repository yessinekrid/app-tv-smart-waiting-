import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SMART WAITING',
      theme: ThemeData(
        textTheme: TextTheme(
          headlineSmall: TextStyle(
            fontSize: 32, // Increase font size for better visibility
            fontWeight: FontWeight.bold, // Adjust font weight
            color: Color.fromRGBO(220, 224, 221, 1), // Text color
            shadows: [
              Shadow(
                blurRadius: 2,
                color: Colors.grey, // Shadow color for better contrast
                offset: Offset(1, 1), // Offset of the shadow
              ),
            ],
          ),
        ),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final StreamController<DataModel1> _streamController = StreamController();
  final StreamController<DataModel2> _streamController2 = StreamController();
  final StreamController<DataModel3> _streamController3 = StreamController();

  @override
  void dispose() {
    _streamController.close();
    _streamController2.close();
    _streamController3.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // A Timer method that runs every 3 seconds
    Timer.periodic(Duration(seconds: 3), (timer) {
      getQueueData1();
      getQueueData2();
      getQueueData3();
    });
  }

  Future<void> getQueueData1() async {
    try {
      var url = Uri.parse('http://192.168.1.16:8080/api/Queue1/service1');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final databody = json.decode(response.body);
        DataModel1 dataModel = DataModel1.fromJson(databody);
        _streamController.sink.add(dataModel);
      } else {
        _streamController.sink.addError('Failed to load data');
      }
    } catch (e) {
      _streamController.sink.addError('Error: $e');
    }
  }

  Future<void> getQueueData2() async {
    try {
      var url = Uri.parse('http://192.168.1.16:8080/api/Queue1/service2');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final databody = json.decode(response.body);
        DataModel2 dataModel2 = DataModel2.fromJson(databody);
        _streamController2.sink.add(dataModel2);
      } else {
        _streamController2.sink.addError('Failed to load data');
      }
    } catch (e) {
      _streamController2.sink.addError('Error: $e');
    }
  }

  Future<void> getQueueData3() async {
    try {
      var url = Uri.parse('http://192.168.1.16:8080/api/Queue1/service3');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final databody = json.decode(response.body);
        DataModel3 dataModel3 = DataModel3.fromJson(databody);
        _streamController3.sink.add(dataModel3);
      } else {
        _streamController3.sink.addError('Failed to load data');
      }
    } catch (e) {
      _streamController3.sink.addError('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SMART WAITING',
          style: TextStyle(color: Colors.white), // Ensuring the title is white
        ),
        backgroundColor: Color.fromRGBO(0, 46, 61, 1),
      ),
      backgroundColor: Color.fromRGBO(
          220, 224, 221, 1), // Set background color for the whole page
      body: Container(
        color: Color.fromRGBO(220, 224, 221, 1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _buildStreamWidget<DataModel1>(
                stream: _streamController.stream,
                title: 'RADIO',
                onData: (dataModel) =>
                    dataModel != null ? dataModel.ticket1Number.toString() : '',
              ),
            ),
            Expanded(
              child: _buildStreamWidget<DataModel2>(
                stream: _streamController2.stream,
                title: 'MEDECIN',
                onData: (dataModel2) => dataModel2 != null
                    ? dataModel2.ticket2Number.toString()
                    : '',
              ),
            ),
            Expanded(
              child: _buildStreamWidget<DataModel3>(
                stream: _streamController3.stream,
                title: 'LABO',
                onData: (dataModel3) => dataModel3 != null
                    ? dataModel3.ticket3Number.toString()
                    : '',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreamWidget<T>({
    required Stream<T> stream,
    required String title,
    required String Function(T?) onData,
  }) {
    return StreamBuilder<T>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          print('Stream Error: ${snapshot.error}');
          return Center(child: Text('Failed to load data'));
        } else if (snapshot.hasData) {
          final dataModel = snapshot.data;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: Color.fromRGBO(0, 46, 61, 1),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    color: Color.fromRGBO(220, 224, 221, 1),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          onData(dataModel),
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return Center(child: Text('No data available'));
        }
      },
    );
  }
}

class DataModel1 {
  int queue1Position;
  int ticket1Number;

  DataModel1({required this.queue1Position, required this.ticket1Number});

  DataModel1.fromJson(Map<String, dynamic> json)
      : queue1Position = json['queue1_Position'] ?? 0,
        ticket1Number = json['ticket1_Number'] ?? 0;

  Map<String, dynamic> toJson() => {
        'queue1_Position': queue1Position,
        'ticket1_Number': ticket1Number,
      };
}

class DataModel2 {
  int queue2Position;
  int ticket2Number;

  DataModel2({required this.queue2Position, required this.ticket2Number});

  DataModel2.fromJson(Map<String, dynamic> json)
      : queue2Position = json['queue1_Position'] ?? 0,
        ticket2Number = json['ticket1_Number'] ?? 0;

  Map<String, dynamic> toJson() => {
        'queue1_Position': queue2Position,
        'ticket1_Number': ticket2Number,
      };
}

class DataModel3 {
  int queue3Position;
  int ticket3Number;

  DataModel3({required this.queue3Position, required this.ticket3Number});

  DataModel3.fromJson(Map<String, dynamic> json)
      : queue3Position = json['queue1_Position'] ?? 0,
        ticket3Number = json['ticket1_Number'] ?? 0;

  Map<String, dynamic> toJson() => {
        'queue1_Position': queue3Position,
        'ticket1_Number': ticket3Number,
      };
}
