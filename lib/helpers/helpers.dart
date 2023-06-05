import 'dart:convert';
import 'dart:typed_data';

import 'package:sodium_libs/sodium_libs.dart';

Future<String> encryptPKid(String json, Uint8List bobPublicKey) async {
  Sodium sodium = await SodiumInit.init();

  Uint8List message = utf8.encode(json) as Uint8List;

  Uint8List encryptedData =
      sodium.crypto.box.seal(message: message, publicKey: bobPublicKey);
  return base64.encode(encryptedData);
}

Future<String> decryptPKid(
    String cipherText, Uint8List bobPublicKey, Uint8List bobSecretKey) async {
  Sodium sodium = await SodiumInit.init();
  Uint8List cipherEncodedText = base64.decode(cipherText);

  Uint8List decrypted = sodium.crypto.box.sealOpen(
      cipherText: cipherEncodedText,
      publicKey: bobPublicKey,
      secretKey: sodium.secureCopy(bobSecretKey));

  String base64DecryptedMessage = new String.fromCharCodes(decrypted);
  return base64DecryptedMessage;
}

Future<Uint8List> sign(String message, Uint8List privateKey) async {
  Sodium sodium = await SodiumInit.init();
  return sodium.crypto.sign.call(
      message: Uint8List.fromList(message.codeUnits),
      secretKey: sodium.secureCopy(privateKey));
}

Future<String> signEncode(String payload, Uint8List secretKey) async {
  return base64Encode(await sign(payload, secretKey));
}

Future<Uint8List> verifyData(String message, Uint8List encodedPublicKey) async {
  Sodium sodium = await SodiumInit.init();
  Uint8List signedMessage = base64Decode(message);
  return sodium.crypto.sign
      .open(signedMessage: signedMessage, publicKey: encodedPublicKey);
}
