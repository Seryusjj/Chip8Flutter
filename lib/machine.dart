
import 'package:binary/binary.dart';
import 'dart:typed_data';


class Machine {
  Uint8List mem; // cpu available memory
  int pc;    // program counter

  Uint16List stack; // stack. 16 registries, 16 bits
  Uint16 sp; // stack pointer

  Uint8List v; // 16 registries for general purpose
  Uint16 i; // special directional registry
  Uint8 dt, st; // timers

  Machine() {
    _init();
  }


  _init() {
    mem = Uint8List(4096);
    v = Uint8List(16);
    stack = Uint16List(16);
    pc = 0x200;
    dt = Uint8(0);
    st = Uint8(0);
    i = Uint16(0);
    sp = Uint16(0);
  }

  process(ByteData rom, List<String> debugText, Function setState) {
    debugText.clear();
    setState();
    // load rom in memory, first 512 positions are reserved
    for (var i = 0; i < rom.lengthInBytes; i++) {
      mem[i+0x200] = rom.getUint8(i);
    }
    // program loaded into machine mem debug text
    debugText.add('rom loaded ');

    debugText.add("reading ...");
    String opcodes = "";
    // start processing
    while (pc < mem.length-1) {
      // opcodes are made of 16 bits, memory is made of 8,
      // so two mem entries = 1 opcode
      Uint16 opCode = Uint16(mem[pc] << 8 | mem[++pc]);
      opcodes  +=  (opCode.value).toRadixString(16);


    }

    debugText.add(opcodes);
    setState();
    //debugText.removeLast();

  }



}
