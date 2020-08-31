import 'dart:typed_data';

import 'package:flutter/services.dart';

class OpCode {
  Uint16List _opCodeStore;

  OpCode(int code) {
    _opCodeStore = Uint16List(7);
    value = code;
  }

  get value {
    return _opCodeStore[0];
  }

  set value(int val) {
    _opCodeStore[0] = val;

    //nnn get the 12 less significant bits, big endian (right most bits);
    _opCodeStore[1] = value & 0x0FFF;

    //kk get the 8 less significant bits
    _opCodeStore[2] = value & 0xFF;

    // we are wasting 16 bits but don want to define another Uint8List for this ...
    //n get the 4 less significant bits
    _opCodeStore[3] = value & 0xF;

    //x is the 4bits less significant from the first byte
    _opCodeStore[4] = (value >> 8) & 0xF;

    //y is the 4bits more significant from the second byte
    _opCodeStore[5] = (value >> 4) & 0xF;

    //p is the 4bits more significant (left most)
    _opCodeStore[6] = value >> 12;
  }

  int get nnn {
    return _opCodeStore[1];
  }

  int get kk {
    return _opCodeStore[2];
  }

  int get n {
    return _opCodeStore[3];
  }

  int get x {
    return _opCodeStore[4];
  }

  int get y {
    return _opCodeStore[5];
  }

  int get p {
    return _opCodeStore[6];
  }
}

class Machine {
  Uint8List mem; // cpu available memory

  // 16 bit registers
  Uint16List _pc_sp_i;

  // 16bit program counter
  get pc {
    return _pc_sp_i[0];
  }

  set pc(int val) {
    _pc_sp_i[0] = val;
  }

  Uint16List stack; // stack. 16 registries, 16 bits
  // stack pointer
  get sp {
    return _pc_sp_i[1];
  }

  set sp(int val) {
    _pc_sp_i[1] = val;
  }

  Uint8List v; // 16 registries for general purpose
  // special directional registry
  get i {
    return _pc_sp_i[1];
  }

  set i(int val) {
    _pc_sp_i[1] = val;
  }

  // 8 bit registers
  Uint8List _dt_st; // timers
  get dt {
    return _dt_st[0];
  }

  set dt(int val) {
    _dt_st[0] = val;
  }

  get st {
    return _dt_st[1];
  }

  set st(int val) {
    _dt_st[1] = val;
  }

  Machine() {
    _init();
  }

  _init() {
    mem = Uint8List(4096);
    v = Uint8List(16);
    stack = Uint16List(16);
    _pc_sp_i = Uint16List(2); //0 pc, 1 sp
    pc = 0x200;
    sp = 0;
    i = 0;
    _dt_st = Uint8List(2);
    dt = 0;
    st = 0;
  }

  process(ByteData rom, List<String> debugText, Function setState) {
    debugText.clear();
    setState();
    // load rom in memory, first 512 positions are reserved
    for (var i = 0; i < rom.lengthInBytes; i++) {
      mem[i + 0x200] = rom.getUint8(i);
    }
    // program loaded into machine mem debug text
    debugText.add('rom loaded ');

    debugText.add("reading ...");
    String opcodes = "";
    // start processing
    var op = OpCode(0);
    while (pc < mem.length - 1) {
      // opcodes are made of 16 bits, memory is made of 8,
      // so two mem entries = 1 opcode
      op.value = mem[pc] << 8 | mem[++pc];
      opcodes += op.value.toRadixString(16);
      pc++;

      switch (op.p) {
        case 0:
          if (op.value == 0x00E0) {
            debugText.add("CLS");
          } else if (op.value == 0x00EE) {
            debugText.add("RET");
          }
          break;
        case 1:
          debugText.add("JP ${op.nnn.toRadixString(16)}");
          break;
        case 2:
          debugText.add("CALL ${op.nnn.toRadixString(16)}");
          break;
        case 3:
          debugText.add("SE ${op.x.toRadixString(16)}, ${op.kk.toRadixString(16)}");
          break;
        case 4:
          debugText.add("SNE ${op.x.toRadixString(16)}, ${op.kk.toRadixString(16)}");
          break;
        case 5:
          debugText.add("SE ${op.x.toRadixString(16)}, ${op.y.toRadixString(16)}");
          break;
        case 6:
          debugText.add("LD ${op.x.toRadixString(16)}, ${op.kk.toRadixString(16)}");
          break;
        case 7:
          debugText.add("ADD ${op.x.toRadixString(16)}, ${op.kk.toRadixString(16)}");
          break;
        case 8:
          // dirty hack
          switch (op.n) {
            case 0:
              debugText.add("LD ${op.x.toRadixString(16)}, ${op.y.toRadixString(16)}");
              break;
            case 1:
              debugText.add("OR ${op.x.toRadixString(16)}, ${op.y.toRadixString(16)}");
              break;
            case 2:
              debugText.add("AND ${op.x.toRadixString(16)}, ${op.y.toRadixString(16)}");
              break;
            case 3:
              debugText.add("XOR ${op.x.toRadixString(16)}, ${op.y.toRadixString(16)}");
              break;
            case 4:
              debugText.add("ADD ${op.x.toRadixString(16)}, ${op.y.toRadixString(16)}");
              break;
            case 5:
              debugText.add("SUB ${op.x.toRadixString(16)}, ${op.y.toRadixString(16)}");
              break;
            case 6:
              debugText.add("SHR ${op.x.toRadixString(16)}");
              break;
            case 7:
              debugText.add("SUBN ${op.x.toRadixString(16)}, ${op.y.toRadixString(16)}");
              break;
            case 0xE:
              debugText.add("SHL ${op.x.toRadixString(16)}");
              break;
          }
          break;
        case 9:
          debugText.add("SNE ${op.x.toRadixString(16)}, ${op.y.toRadixString(16)}");
          break;
        case 0xA:
          debugText.add("LD I, ${op.nnn.toRadixString(16)}");
          break;
        case 0xB:
          debugText.add("JP V0, ${op.nnn.toRadixString(16)}");
          break;
        case 0xC:
          debugText.add("RND ${op.x.toRadixString(16)}, ${op.kk.toRadixString(16)}");
          break;
        case 0xD:
          debugText.add("DRW ${op.x.toRadixString(16)}, ${op.y.toRadixString(16)}, ${op.n.toRadixString(16)}");
          break;
        case 0xE:
          if (op.kk == 0x9E) {
            debugText.add("SKP ${op.x.toRadixString(16)}");
          } else if (op.kk == 0xA1) {
            debugText.add("SKNP ${op.x.toRadixString(16)}");
          }
          break;
        case 0xF:
          switch (op.kk) {
            case 0x07:
              debugText.add("LD ${op.x.toRadixString(16)}, DT");
              break;
            case 0x0A:
              debugText.add("LD ${op.x.toRadixString(16)}, K");
              break;
            case 0x15:
              debugText.add("LD DT, ${op.x.toRadixString(16)}");
              break;
            case 0x18:
              debugText.add("LD ST, ${op.x.toRadixString(16)}");
              break;
            case 0x1E:
              debugText.add("ADD I, ${op.x.toRadixString(16)}");
              break;
            case 0x29:
              debugText.add("LD F, ${op.x.toRadixString(16)}");
              break;
            case 0x33:
              debugText.add("LD B, ${op.x.toRadixString(16)}");
              break;
            case 0x55:
              debugText.add("LD [I], ${op.x.toRadixString(16)}");
              break;
            case 0x65:
              debugText.add("LD ${op.x.toRadixString(16)}, [I]");
              break;
          }
          break;
        default:
      }
    }

    debugText.add(opcodes);
    setState();
    //debugText.removeLast();
  }
}
