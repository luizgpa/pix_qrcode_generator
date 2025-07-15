import 'package:decimal/decimal.dart';
import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'pix.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gerador de QR Code Pix',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: AppHome(),
    );
  }
}

class AppHome extends StatefulWidget {
  const AppHome({super.key});

  @override
  State<AppHome> createState() => _AppHomeState();
}

extension on String {
  String fix() {
    return removeDiacritics(trim());
  }
}

class _AppHomeState extends State<AppHome> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _keyController = TextEditingController(text: '');
  final _nameController = TextEditingController(text: '');
  final _cityController = TextEditingController(text: '');
  final _valueController = TextEditingController();
  String? _data;

  void _resetData() {
    setState(() {
      _data = null;
    });
  }

  Widget _table() {
    const width = 120.0;
    const padding = EdgeInsets.only(left: 35);
    return Column(
      children: [
        Text(
          'Tipos de chave',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        Divider(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: width,
              child: Text(
                'Email',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('codificado no seguinte formato:'),
                Padding(
                  padding: padding,
                  child: Text('fulano_da_silva.recebedor@example.com'),
                ),
              ],
            ),
          ],
        ),
        Divider(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: width,
              child: Text(
                'CPF ou CNPJ',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('codificados nos seguintes formatos:'),
                Padding(
                  padding: padding,
                  child: Text('CPF: 12345678900\nCNPJ: 00038166000105'),
                ),
              ],
            ),
          ],
        ),
        Divider(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: width,
              child: Text(
                'Número de telefone celular',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('codificado seguindo o formato internacional:'),
                Padding(padding: padding, child: Text('+5561912345678')),
                Text('em que:'),
                Padding(padding: padding, child: Text('+55: código do país')),
                Padding(
                  padding: padding,
                  child: Text('61: código do território ou estado,'),
                ),
                Padding(
                  padding: padding,
                  child: Text('912345678: número do telefone celular'),
                ),
              ],
            ),
          ],
        ),
        Divider(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: width,
              child: Text(
                'Chave aleatória',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('codificada juntamente com a pontuação, como segue:'),
                Padding(
                  padding: padding,
                  child: Text('123e4567-e12b-12d1-a456-426655440000'),
                ),
              ],
            ),
          ],
        ),
        Divider(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Gerador de QR Code'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(10),
          children: [
            Center(
              child: SizedBox(
                width: 500,
                child: Column(
                  children: [
                    _table(),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _keyController,
                      decoration: InputDecoration(
                        hintText: 'Entre sua chave',
                        border: OutlineInputBorder(),
                        label: Text('Chave'),
                      ),
                      onChanged: (value) => _resetData(),
                    ),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'Opcional',
                        label: Text('Nome'),
                      ),
                      onChanged: (value) => _resetData(),
                    ),
                    TextFormField(
                      controller: _valueController,
                      keyboardType: TextInputType.numberWithOptions(),
                      onSaved: null,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp('[0-9\\.,]')),
                      ],
                      decoration: InputDecoration(
                        prefix: Text('R\$'),
                        hintText: 'Opcional',
                        label: Text('Valor'),
                      ),
                      onChanged: (value) => _resetData(),
                    ),
                    TextFormField(
                      controller: _cityController,
                      decoration: InputDecoration(
                        hintText: 'Opcional',
                        label: Text('Cidade'),
                      ),
                      onChanged: (value) => _resetData(),
                    ),
                    Padding(
                      padding: EdgeInsetsGeometry.all(10),
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            var value = Decimal.tryParse(_valueController.text);
                            setState(() {
                              _data = getPixCode(
                                key: _keyController.text.fix(),
                                merchantName: _nameController.text.fix(),
                                merchantCity: _cityController.text.fix(),
                                value: value,
                              );
                            });
                          }
                        },
                        child: Text('Gerar'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Divider(),
            if (_data != null) ...[
              SizedBox(height: 10),
              Center(
                child: SizedBox(
                  width: 500,
                  child: Column(
                    children: [
                      Text('Pix copia e cola', style: textTheme.headlineMedium),
                      SelectableText(_data!, textAlign: TextAlign.center),
                      PrettyQrView.data(
                        data: _data!,
                        decoration: const PrettyQrDecoration(
                          quietZone: PrettyQrQuietZone.pixels(20),
                          shape: PrettyQrSmoothSymbol(roundFactor: 0),
                        ),
                      ),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: 'CHAVE PIX: '),
                            TextSpan(text: _keyController.text.fix()),
                          ],
                        ),
                        textAlign: TextAlign.center,
                        style: textTheme.headlineSmall,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
