import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter_pkid/flutter_pkid.dart';
import 'package:sodium_libs/sodium_libs.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:convert/convert.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:flutter_pkid/helpers/encoding.dart';

const seed =
    'eyebrow humble spread token sphere option hero element pause burden injury acid opinion flight intact genre mixture false apart cradle candy remind multiply found';
String pkidUrl = 'https://pkid.staging.jimber.org/v1';

Future<KeyPair> generateKeyPairFromSeedPhrase(seedPhrase) async {
  final sodium = await SodiumInit.init();
  print('Using sodium version ' + sodium.version.toString());

  String entropy = bip39.mnemonicToEntropy(seedPhrase);
  return sodium.crypto.sign
      .seedKeyPair(sodium.secureCopy(Encoding.toHex(entropy)));
}

void main() {
  test('Check if HEX encoding is correct', () async {
    const encodedPublicKey = 'GXH+Q6ey+nlpAMbRlkL10f5EtgQYA7IcvrwR9d7eT08=';
    Uint8List decodedPublicKey = base64Decode(encodedPublicKey);

    expect(hex.encode(decodedPublicKey),
        '1971fe43a7b2fa796900c6d19642f5d1fe44b6041803b21cbebc11f5dede4f4f');
  });

  test('Write and read document of same KP', () async {
    KeyPair kp = await generateKeyPairFromSeedPhrase(seed);
    var client = FlutterPkid(pkidUrl, kp);

    int randomNumber = new Random().nextInt(100);

    await client.setPKidDoc('TESTING', randomNumber.toString());
    Map<String, dynamic> result = await client.getPKidDoc('TESTING');

    expect(int.parse(result['data']), randomNumber);
  });
}
