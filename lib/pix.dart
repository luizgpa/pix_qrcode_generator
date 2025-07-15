import 'dart:typed_data' show Uint8List;
import 'package:crclib/catalog.dart';
import 'package:decimal/decimal.dart';

class Payload {
  final StringBuffer _buffer = StringBuffer();

  void addField(int id, String value) {
    assert(id >= 0 && id <= 99);
    final length = value.length;
    assert(length <= 99);
    _buffer.write(id.toString().padLeft(2, '0'));
    _buffer.write(length.toString().padLeft(2, '0'));
    _buffer.write(value);
  }

  void addPayload(int id, Payload value) {
    addField(id, value.toString());
  }

  void addCrc({int id = 63}) {
    _buffer.write(id.toString().padLeft(2, '0'));
    _buffer.write('04');
    final current = toString();
    final crc = Crc16CcittFalse().convert(
      Uint8List.fromList(current.codeUnits),
    );
    _buffer.write(crc.toRadixString(16).toUpperCase());
  }

  @override
  String toString() => _buffer.toString();
}

enum KeyType { email, cpfOrCnpj, cellphoneNumber, random }

String getPixCode({
  required String key,
  String merchantName = '',
  String merchantCity = '',
  Decimal? value,
}) {
  // Reference: https://www.bcb.gov.br/content/estabilidadefinanceira/pix/Regulamento_Pix/II_ManualdePadroesparaIniciacaodoPix.pdf
  // TODO: key validation?
  final payload = Payload();

  // Payload Format Indicator
  payload.addField(00, '01');

  // Merchant Account Information
  payload.addPayload(
    26,
    Payload()
      // GUI - Globally Unique Identifier
      ..addField(00, 'br.gov.bcb.pix')
      // Key / "chave"
      ..addField(01, key), // TODO: remove illegal characters
  );
  // Merchant Category Code
  payload.addField(52, '0000');
  // Transaction Currency
  payload.addField(53, '986');
  // Transaction Amount
  if (value != null) payload.addField(54, value.toString());
  // Country Code
  payload.addField(58, 'BR');
  // Merchant Name
  payload.addField(59, merchantName); // TODO: remove illegal characters
  // Merchant City
  payload.addField(60, merchantCity); // TODO: remove illegal characters
  // Additional Data Field Template
  payload.addPayload(
    62,
    Payload()
      //Reference Label
      ..addField(05, '***'),
  );

  payload.addCrc();

  return payload.toString();
}
