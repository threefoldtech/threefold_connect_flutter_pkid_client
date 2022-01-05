import 'dart:async';
import 'package:flutter/services.dart';
import 'package:hex/hex.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart';

import 'helpers/helpers.dart';

class FlutterPkid {
  String pKidUrl = '';
  dynamic keyPair;

  FlutterPkid(String pKidUrl, dynamic keyPair) {
    this.pKidUrl = pKidUrl;
    this.keyPair = keyPair;
  }

  Future<dynamic> getPKidDoc(String key, Map<String, dynamic> keyPair) async {
    Map<String, String> requestHeaders = {'Content-type': 'application/json'};

    Response res;
    try {
      print('$pKidUrl/documents/${HEX.encode(keyPair['publicKey'])}/$key');

      res = await http.get(Uri.parse('$pKidUrl/documents/${HEX.encode(keyPair['publicKey'])}/$key'),
          headers: requestHeaders);
    } catch (e) {
      String status = 'No Status';
      return {'status': status, 'error': e};
    }

    Uint8List verified;
    try {
      Map<String, dynamic> data = jsonDecode(res.body);
      verified = await verifyData(data['data'], keyPair['publicKey']);
    } catch (e) {
      return {'error': 'Could not verify the data with the given keypair', 'verified': false};
    }

    Map<String, dynamic> decodedData = jsonDecode(utf8.decode(verified));

    if (decodedData['is_encrypted'] == 0) {
      return {'success': true, 'data': decodedData['payload'], 'verified': true, 'data_version': decodedData['data_version']};
    }

    String decryptedData;

    try {
      decryptedData = await decryptPKid(decodedData['payload'], keyPair['publicKey'], keyPair['privateKey']);
    } catch (e) {
      return {
        'error': 'could not decrypt data',
        verified: true,
        'decrypted': false,
        'data_version': decodedData['data_version']
      };
    }

    return {
      'success': true,
      'data': decryptedData,
      'verified': true,
      'decrypted': true,
      'data_version': decodedData['data_version']
    };
  }

  Future<Response> setPKidDoc(String key, String payload, Map<String, dynamic> keyPair) async {
    int timestamp = new DateTime.now().millisecondsSinceEpoch;
    Map<String, dynamic> requestHeaders = {'intent': 'pkid.store', 'timestamp': timestamp};
    String handledPayload = await encryptPKid(payload, keyPair['publicKey']);

    Map<String, dynamic> payloadContainer = {'is_encrypted': 1, 'payload': handledPayload, 'data_version': 1};

    try {
      print('$pKidUrl/documents/${HEX.encode(keyPair['publicKey'])}/$key');
      return await http.put(Uri.parse('$pKidUrl/documents/${HEX.encode(keyPair['publicKey'])}/$key'),
          body: json.encode(await signEncode(jsonEncode(payloadContainer), keyPair['privateKey'])),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': await signEncode(jsonEncode(requestHeaders), keyPair['privateKey'])
          });
    } catch (e) {
      print(e);
      return http.Response('Error in setPKidDoc', 500);
    }
  }

  static const MethodChannel _channel = const MethodChannel('flutter_pkid');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
