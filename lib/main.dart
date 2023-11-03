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
  final _formKey = GlobalKey<FormState>();
  String _respuesta = '';
  int? distance, passengers, miscellaneousfees, tripduration;
  TextEditingController _urlController = TextEditingController();
  TextEditingController _shaController = TextEditingController();

  Future<void> _consultarModelo() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final url =
          Uri.parse('https://modelotaxi-service-dianabeja.cloud.okteto.net/');
      final response = await http.post(url,
          body: json.encode({
            "distance_traveled": distance,
            "num_of_passengers": passengers,
            "miscellaneous_fees": miscellaneousfees,
            "trip_duration": tripduration
          }),
          headers: {"Content-Type": "application/json"});

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        double? price = jsonResponse['premiumPrice'];
        setState(() {
          _respuesta =
              ' ${price?.toStringAsFixed(2)}'; // Convertimos el número a String con dos decimales
        });
      } else {
        setState(() {
          _respuesta =
              'Error al obtener respuesta, revisa que todos los campos sean validos';
        });
      }
    }
  }

  Future<void> _llamadoAPI() async {
    final url = Uri.parse(
        'https://api.github.com/repos/dianabeja/ModeloTaxi/dispatches');

    final body = json.encode({
      "event_type": "ml_ci_cd",
      "client_payload": {
        "dataseturl":
            _urlController.text, // Obtén el valor desde el controlador
        "sha": _shaController.text, // Obtén el valor desde el controlador
      }
    });

    final headers = {
      'Authorization': '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',
      'Accept': 'application/vnd.github.v3+json',
      'Content-type': 'application/json',
    };

    final response = await http.post(url, body: body, headers: headers);

    if (response.statusCode == 204) {
      setState(() {
        _respuesta = 'Llamado a API exitoso';
      });
    } else {
      setState(() {
        _respuesta = 'Error al hacer el llamado a la API';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Axolot Machine Learning"),
        backgroundColor: Color.fromARGB(255, 164, 136, 255),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextFormField(
                    decoration: InputDecoration(labelText: 'Distancia'),
                    keyboardType: TextInputType.number,
                    onSaved: (value) => distance = int.tryParse(value ?? ''),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextFormField(
                    decoration: InputDecoration(labelText: 'Pasajeros'),
                    keyboardType: TextInputType.number,
                    onSaved: (value) => passengers = int.tryParse(value ?? ''),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextFormField(
                    decoration: InputDecoration(labelText: 'Gastos'),
                    keyboardType: TextInputType.number,
                    onSaved: (value) =>
                        miscellaneousfees = int.tryParse(value ?? ''),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextFormField(
                    decoration:
                        InputDecoration(labelText: 'Duración del viaje'),
                    keyboardType: TextInputType.number,
                    onSaved: (value) =>
                        tripduration = int.tryParse(value ?? ''),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _consultarModelo,
                  child: const Text('Consultar Modelo'),
                  style: ElevatedButton.styleFrom(
                    primary: Color.fromARGB(255, 164, 136, 255),
                    padding:
                        EdgeInsets.symmetric(horizontal: 125, vertical: 22),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 16.0),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 164, 136, 255),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    'Predicción: $_respuesta',
                    style: TextStyle(
                      color:
                          Colors.white, // Texto en blanco para mejor contraste
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextFormField(
                    controller:
                        _shaController, // Asociar el controlador al campo
                    decoration: InputDecoration(labelText: 'Nombre'),
                    onSaved: (value) {},
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextFormField(
                    controller:
                        _urlController, // Asociar el controlador al campo
                    decoration: InputDecoration(labelText: 'URL'),
                    // No establecer el keyboardType, ya que es un campo de URL
                    onSaved: (value) {},
                  ),
                ),
                ElevatedButton(
                  onPressed: _llamadoAPI,
                  child: const Text('Reentrenar Modelo'),
                  style: ElevatedButton.styleFrom(
                    primary: Color.fromARGB(255, 164, 136, 255),
                    padding:
                        EdgeInsets.symmetric(horizontal: 125, vertical: 22),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(_respuesta),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
