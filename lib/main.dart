import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diana App',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();
  String _respuesta = '';

  Future<void> _consultarModelo() async {
    try {
      final body = json.decode(_controller.text);

     final url = Uri.parse('https://heart-ml-service-dianabeja.cloud.okteto.net/score');
      final response = await http.post(url, body: json.encode(body), headers: {"Content-Type": "application/json"});

      if (response.statusCode == 200) {
        setState(() {
          _respuesta = response.body;
        });
      } else {
        setState(() {
          _respuesta = 'Error al obtener respuesta';
        });
      }
    } catch (error) {
      
      setState(() {
        _respuesta = 'Error al formatear el JSON';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Diana App"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(10.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Ingresa tu JSON aquí',
                border: OutlineInputBorder(),
              ),
              maxLines: 10,
            ),
          ),
          ElevatedButton(
            child: Text('Consultar Modelo'),
            onPressed: _consultarModelo,
          ),
          SizedBox(height: 20),
          Text(_respuesta),
        ],
      ),
    );
  }
}
