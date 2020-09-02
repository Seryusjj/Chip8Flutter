import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;

class RomLoader {

  Future<ByteData> loadAsset() async {
    return await rootBundle.load('assets/res/Pong_Paul_Vervalin_1990.ch8');
  }
}
