import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ffi';
import 'package:flutter_pkid/flutter_pkid.dart';
import 'package:flutter_sodium/flutter_sodium.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hex/hex.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:flutter_pkid/helpers/encoding.dart';

const seed = 'eyebrow humble spread token sphere option hero element pause burden injury acid opinion flight intact genre mixture false apart cradle candy remind multiply found';
String pkidUrl = 'https://pkid.staging.jimber.org/v1';

KeyPair generateKeyPairFromSeedPhrase(seedPhrase) {
  String entropy = bip39.mnemonicToEntropy(seedPhrase);
  return Sodium.cryptoSignSeedKeypair(Encoding.toHex(entropy));

}

void main() {
  Sodium.init();
  test('Check if HEX encoding is correct', () async {
    const encodedPublicKey = 'GXH+Q6ey+nlpAMbRlkL10f5EtgQYA7IcvrwR9d7eT08=';
    Uint8List decodedPublicKey = base64Decode(encodedPublicKey);

    expect (HEX.encode(decodedPublicKey), '1971fe43a7b2fa796900c6d19642f5d1fe44b6041803b21cbebc11f5dede4f4f');
  });

  test('Write and read document of same KP', () async {
    print('Using sodium version ' + Sodium.versionString);

    KeyPair kp = generateKeyPairFromSeedPhrase(seed);
    var client = FlutterPkid(pkidUrl, kp);

    int randomNumber = new Random().nextInt(100);

    await client.setPKidDoc('TESTING', randomNumber.toString());
    Map<String, dynamic> result = await client.getPKidDoc('TESTING');

    expect (int.parse(result['data']), randomNumber);
  });
}
