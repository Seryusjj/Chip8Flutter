import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;

class RomLoader {
  void loadTestRom(Function(ByteData) callback) {
    loadAsset().then((value) => callback(value));
  }

  Future<ByteData> loadAsset() async {
    return await rootBundle.load('assets/res/Pong_Paul_Vervalin_1990.ch8');
  }
}
