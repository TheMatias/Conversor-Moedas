import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

const url = 'https://api.hgbrasil.com/finance?format=json-cors&key=6b36d3f8';

void main() async {
  print(await getData());
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(hintColor: Colors.amber, primaryColor: Colors.white),
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(url);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolaController = TextEditingController();
  final euroController = TextEditingController();

  double dolar;
  double euro;

  void _clearAll(){
    realController.text = '';
    dolaController.text = '';
    euroController.text = '';
  }

  void _isEmpty(String text){
    if (text.isEmpty){
      _clearAll();
    }
  }

  void _realChanged(String text) {
    _isEmpty(text);
    double real = double.parse(text);
    dolaController.text = (real/dolar).toStringAsFixed(2);
    euroController.text = (real/euro).toStringAsFixed(2); 
  }

  void _dolaChanged(String text) {
    _isEmpty(text);
    double dolar = double.parse(text);
    realController.text = (this.dolar * dolar).toStringAsFixed(2);
    euroController.text = (this.dolar * dolar/euro).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    _isEmpty(text);
    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolaController.text = (euro * this.euro/dolar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text('\$ Conversor \$'),
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text(
                  'Carregando dados ..',
                  style: TextStyle(color: Colors.amber, fontSize: 25.0),
                  textAlign: TextAlign.center,
                ),
              );
            default:
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error ..',
                    style: TextStyle(color: Colors.amber, fontSize: 25.0),
                    textAlign: TextAlign.center,
                  ),
                );
              } else {
                dolar = snapshot.data['results']['currencies']['USD']['buy'];
                euro = snapshot.data['results']['currencies']['EUR']['buy'];

                return SingleChildScrollView(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Icon(Icons.monetization_on,
                          size: 150.0, color: Colors.amber),
                      buildTextField(
                          'Reais', 'R\$ ', realController, _realChanged),
                      Divider(),
                      buildTextField(
                          'Dólares', 'US\$ ', dolaController, _dolaChanged),
                      Divider(),
                      buildTextField(
                          'Euros', '€ ', euroController, _euroChanged)
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }

  Widget buildTextField(
      String label, String prefix, TextEditingController ctrl, Function f) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        prefixText: prefix,
        labelStyle: TextStyle(color: Colors.amber),
      ),
      style: TextStyle(color: Colors.amber, fontSize: 25.0),
      onChanged: f,
      keyboardType: TextInputType.number,
    );
  }
}
