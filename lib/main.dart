import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(DianaAPP());
}

class DianaAPP extends StatelessWidget {
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
   String _respuesta2 = '';
  int? distance, passengers, miscellaneousfees, tripduration;
  TextEditingController _urlController = TextEditingController();
  TextEditingController _shaController = TextEditingController();

  Future<void> _consultarModelo() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final url = Uri.parse(
          'https://modelotaxi-service-dianabeja.cloud.okteto.net/predict');
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
        double? price = jsonResponse['fare'];
        setState(() {
          _respuesta =
              '$price'; // Convertimos el número a String con dos decimales
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
      'Authorization': 'Bearer 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',
      'Accept': 'application/vnd.github.v3+json',
      'Content-type': 'application/json',
    };

    final response = await http.post(url, body: body, headers: headers);

    if (response.statusCode == 204) {
      setState(() {
        _respuesta2 = 'Llamado a API exitoso';
      });
    } else {
      setState(() {
        _respuesta2 = 'Error al reentrenar modelo';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Taxi"),
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
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: 'Dataset'),
                    items: [
                      DropdownMenuItem(
                          value:
                              'https://firebasestorage.googleapis.com/v0/b/heartmodel-caedd.appspot.com/o/train.csv?alt=media&token=f2930a67-ab0b-4944-bed4-bbfd90d208d1',
                          child: Text("100")),
                      DropdownMenuItem(
                          value:
                              'https://firebasestorage.googleapis.com/v0/b/heartmodel-caedd.appspot.com/o/train50.csv?alt=media&token=0e7cd827-8c59-4a30-8c37-c93a11661002',
                          child: Text("50")),
                      DropdownMenuItem(
                          value:
                              'https://firebasestorage.googleapis.com/v0/b/heartmodel-caedd.appspot.com/o/train25.csv?alt=media&token=9e7d3e02-5d15-4e8b-9350-a2ca205599c1',
                          child: Text("25")),
                    ],
                    onChanged: (value) {
                      _urlController.text = value!;
                      print('hola');
                      print(value);

                    },
                    onSaved: (value) {
                      _urlController.text = value!;
                      print('adios');
                      print(value);
                    },
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
                Text(_respuesta2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
