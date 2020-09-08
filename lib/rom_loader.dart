import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;

class RomLoader {

  Future<ByteData> loadAsset() async {
    return await rootBundle.load('assets/res/Space_Invaders_David_Winter.ch8');
  }
}
