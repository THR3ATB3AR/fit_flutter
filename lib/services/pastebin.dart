// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:pointycastle/export.dart';
// import 'package:archive/archive.dart';
// import 'package:convert/convert.dart';

// Future<String> decipher(String key, String password, dynamic data) async {
//   String adataString;
//   List<dynamic> spec;
//   String cipherMessage;
//   Uint8List plaintext;

//   cipherMessage='zRIGBIB+/SGxzGJRzcxTxF04Mb3Xnh3eR2tx9ZrXmY3+/zHXVSVPENK+7FLC70jqzgIXZCLZ/isN/TA02Ls2c2peTfOJcx/dXR6j0q3TjVSJsHkiFYoLe/3W7a4xatzshwu9mTbGZM7KzPvybqkUcwAOxB0uSxuoIqbPgFLl4KgUDOJG4uIEU8CCTUBUPLgEEZb9YMIsDbwMnKpscj0EfDpJoDNmJ+CcEZTw34y+gRm0UDj+jYYav9bgy8EZqw/TZpam7naea0e5XZ8GqZn7tr8A';

//   final object = jsonDecode(data);
//     adataString = utf8.decode(base64Decode(object['adata'][0][0]));
//     spec = [
//       object['iv'],
//       object['salt'],
//       object['iter'],
//       object['ks'],
//       object['ts'],
//       object['cipher'],
//       object['mode'],
//       'rawdeflate'
//     ];
//     cipherMessage = object['ct'];

//   spec = [
//       "9sSvR2vHnAHPaLE0sTXnbQ==",
//       "cSENCckogyI=",
//       100000,
//       256,
//       128,
//       "aes",
//       "gcm",
//       "zlib"
//     ];

//   spec[0] = base64Decode(spec[0]);
//   spec[1] = base64Decode(spec[1]);

//   adataString='"9sSvR2vHnAHPaLE0sTXnbQ==","cSENCckogyI=",100000,256,128,"aes","gcm","zlib"';

//   try {
//     plaintext =
//         await decryptData(adataString, spec, key, password, cipherMessage);
//   } catch (err) {
//     print(err);
//     return '';
//   }

//   try {
//     return await decompressData(plaintext, spec[7]);
//   } catch (err) {
//     print(err);
//     return err.toString();
//   }
// }

// Future<Uint8List> decryptData(String adataString, List<dynamic> spec,
//     String key, String password, String cipherMessage) async {
//   final cipher = GCMBlockCipher(AESEngine())
//     ..init(
//       false,
//       AEADParameters(
//         KeyParameter(await deriveKey(key, password, spec)),
//         128,
//         spec[0],
//         utf8.encode(adataString),
//       ),
//     );

//   final input = base64Decode(cipherMessage);
//   final output = Uint8List(input.length);
//   var offset = 0;
//   while (offset < input.length) {
//     offset += cipher.processBlock(input, offset, output, offset);
//   }
//   return output;
// }

// Future<Uint8List> deriveKey(
//     String key, String password, List<dynamic> spec) async {
//   final pbkdf2 = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64))
//     ..init(Pbkdf2Parameters(spec[1], spec[2], spec[3] ~/ 8));
//   return pbkdf2.process(utf8.encode(key + password));
// }

// Future<String> decompressData(Uint8List data, String compressionType) async {
//   if (compressionType == 'zlib') {
//     final decompressed = ZLibDecoder().decodeBytes(data);
//     return utf8.decode(decompressed);
//   } else {
//     throw 'Unsupported compression type';
//   }
// }

// void main() async {
//   try {
//     String key = '7SvUmV4ZScCEuJLm6j2Jnu';
//     String password = 'EqWxLrQ1t9hqrMrmHbDGQKUkDwquzQB63aATGLnJfnF';
//     dynamic data = '{"status": 0,"id": "45b75862769a06d2","url": "/?45b75862769a06d2","adata": [  [    "9sSvR2vHnAHPaLE0sTXnbQ==",    "cSENCckogyI=",    100000,    256,    128,    "aes",    "gcm",    "zlib"  ],  "markdown",  0,  0],"v": 2,"ct": "zRIGBIB+/SGxzGJRzcxTxF04Mb3Xnh3eR2tx9ZrXmY3+/zHXVSVPENK+7FLC70jqzgIXZCLZ/isN/TA02Ls2c2peTfOJcx/dXR6j0q3TjVSJsHkiFYoLe/3W7a4xatzshwu9mTbGZM7KzPvybqkUcwAOxB0uSxuoIqbPgFLl4KgUDOJG4uIEU8CCTUBUPLgEEZb9YMIsDbwMnKpscj0EfDpJoDNmJ+CcEZTw34y+gRm0UDj+jYYav9bgy8EZqw/TZpam7naea0e5XZ8GqZn7tr8A","meta": {  "created": 1727510897},"comments": [],"comment_count": 0,"comment_offset": 0,"@context": "?jsonld=paste"}';
//     String result = await decipher(key, password, data);
//     print('Decrypted data: $result');
//   } catch (e) {
//     print('Error: $e');
//   }
// }
