import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pkid/flutter_pkid.dart';
import 'package:hex/hex.dart';

void main() {
  const MethodChannel channel = MethodChannel('flutter_pkid');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await FlutterPkid.platformVersion, '42');
  });

  // Test to check if HEX.encode is the same as before
  const encodedPublicKey = 'GXH+Q6ey+nlpAMbRlkL10f5EtgQYA7IcvrwR9d7eT08=';
  Uint8List decodedPublicKey = base64Decode(encodedPublicKey);

  test('checkHexEncoding', () async {
    expect (HEX.encode(decodedPublicKey), '1971fe43a7b2fa796900c6d19642f5d1fe44b6041803b21cbebc11f5dede4f4f');
  });
}
