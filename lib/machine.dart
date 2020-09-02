import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter/services.dart';

class OpCode {
  Uint16List _opCodeStore;

  OpCode(int code) {
    _opCodeStore = Uint16List(7);
    value = code;
  }

  int get value {
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

enum Status {
  Stop,
  Stopped,
  Running,
}

typedef OpCall = void Function(Machine mac, OpCode code);

Map<int, OpCall> operations = {
  0: (Machine mac, OpCode code) => {
        if (code.y == 0xC)
          {
            // super chip extension
            mac.missing(code)
          }
        else
          kk_SubOperation[code.kk](mac, code)
      },
  1: (Machine mac, OpCode code) => mac.jp(code),
  2: (Machine mac, OpCode code) => mac.call(code),
  3: (Machine mac, OpCode code) => mac.se_xkk(code),
  4: (Machine mac, OpCode code) => mac.sne_xkk(code),
  5: (Machine mac, OpCode code) => mac.se_xy(code),
  6: (Machine mac, OpCode code) => mac.ld_xkk(code),
  7: (Machine mac, OpCode code) => mac.add_xkk(code),
  8: (Machine mac, OpCode code) => n_SubOperation[code.n](mac, code),
  9: (Machine mac, OpCode code) => mac.sne_xy(code),
  0xA: (Machine mac, OpCode code) => mac.ld_innn(code),
  0xB: (Machine mac, OpCode code) => mac.jp_v0nnn(code),
  0xC: (Machine mac, OpCode code) => mac.rnd_xkk(code),
  0xD: (Machine mac, OpCode code) => mac.drw_xyn(code),
  0xE: (Machine mac, OpCode code) => kk_SubOperation[code.kk](mac, code),
  0xF: (Machine mac, OpCode code) => kk_SubOperation[code.kk](mac, code),
};

Map<int, OpCall> n_SubOperation = {
  0: (Machine mac, OpCode code) => mac.ld_xy(code),
  1: (Machine mac, OpCode code) => mac.or_xy(code),
  2: (Machine mac, OpCode code) => mac.and_xy(code),
  3: (Machine mac, OpCode code) => mac.xor_xy(code),
  4: (Machine mac, OpCode code) => mac.add_xy(code),
  5: (Machine mac, OpCode code) => mac.sub_xy(code),
  6: (Machine mac, OpCode code) => mac.shr_x(code),
  7: (Machine mac, OpCode code) => mac.subn_xy(code),
  0xE: (Machine mac, OpCode code) => mac.shl_x(code),
};

Map<int, OpCall> kk_SubOperation = {
  0x9E: (Machine mac, OpCode code) => mac.skp_x(code),
  0xA1: (Machine mac, OpCode code) => mac.sknp_x(code),
  0x07: (Machine mac, OpCode code) => mac.ld_xdt(code),
  0x0A: (Machine mac, OpCode code) => mac.ld_xk(code),
  0x15: (Machine mac, OpCode code) => mac.ld_dtx(code),
  0x18: (Machine mac, OpCode code) => mac.ld_stx(code),
  0x1E: (Machine mac, OpCode code) => mac.add_ix(code),
  0x29: (Machine mac, OpCode code) => mac.ld_fx(code),
  0x33: (Machine mac, OpCode code) => mac.ld_bx(code),
  0x55: (Machine mac, OpCode code) => mac.ld_ix(code),
  0x65: (Machine mac, OpCode code) => mac.ld_xi(code),
  0xE0: (Machine mac, OpCode code) => mac.cls(code),
  0xEE: (Machine mac, OpCode code) => mac.ret(code),
  // super chip extension 0x0
  0xFB: (Machine mac, OpCode code) => mac.missing(code),
  0xFC: (Machine mac, OpCode code) => mac.missing(code),
  0xFD: (Machine mac, OpCode code) => mac.missing(code),
  0xFE: (Machine mac, OpCode code) => mac.missing(code),
  0xFF: (Machine mac, OpCode code) => mac.missing(code),
  // super chip extension 0xF
  0x30: (Machine mac, OpCode code) => mac.missing(code),
  0x75: (Machine mac, OpCode code) => mac.missing(code),
  0x85: (Machine mac, OpCode code) => mac.missing(code),
};

class Machine {
  missing(OpCode op) {
    port.send("not implemented op: ${op.value.toRadixString(16)}");
  }

  cls(OpCode op) {
    port.send("CLS");
  }

  ret(OpCode op) {
    port.send("RET");
  }

  jp(OpCode op) {
    port.send("JP ${op.nnn.toRadixString(16)}");
  }

  call(OpCode op) {
    port.send("CALL ${op.nnn.toRadixString(16)}");
  }

  se_xkk(OpCode op) {
    port.send("SE ${op.x.toRadixString(16)}, ${op.kk.toRadixString(16)}");
  }

  sne_xkk(OpCode op) {
    port.send("SNE ${op.x.toRadixString(16)}, ${op.kk.toRadixString(16)}");
  }

  se_xy(OpCode op) {
    port.send("SE ${op.x.toRadixString(16)}, ${op.y.toRadixString(16)}");
  }

  ld_xkk(OpCode op) {
    port.send("LD ${op.x.toRadixString(16)}, ${op.kk.toRadixString(16)}");
  }

  add_xkk(OpCode op) {
    port.send("ADD ${op.x.toRadixString(16)}, ${op.kk.toRadixString(16)}");
  }

  ld_xy(OpCode op) {
    port.send("LD ${op.x.toRadixString(16)}, ${op.y.toRadixString(16)}");
  }

  or_xy(OpCode op) {
    port.send("OR ${op.x.toRadixString(16)}, ${op.y.toRadixString(16)}");
  }

  and_xy(OpCode op) {
    port.send("AND ${op.x.toRadixString(16)}, ${op.y.toRadixString(16)}");
  }

  xor_xy(OpCode op) {
    port.send("XOR ${op.x.toRadixString(16)}, ${op.y.toRadixString(16)}");
  }

  add_xy(OpCode op) {
    port.send("ADD ${op.x.toRadixString(16)}, ${op.y.toRadixString(16)}");
  }

  sub_xy(OpCode op) {
    port.send("SUB ${op.x.toRadixString(16)}, ${op.y.toRadixString(16)}");
  }

  shr_x(OpCode op) {
    port.send("SHR ${op.x.toRadixString(16)}");
  }

  subn_xy(OpCode op) {
    port.send("SUBN ${op.x.toRadixString(16)}, ${op.y.toRadixString(16)}");
  }

  shl_x(OpCode op) {
    port.send("SHL ${op.x.toRadixString(16)}");
  }

  sne_xy(OpCode op) {
    port.send("SNE ${op.x.toRadixString(16)}, ${op.y.toRadixString(16)}");
  }

  ld_innn(OpCode op) {
    port.send("LD I, ${op.nnn.toRadixString(16)}");
  }

  jp_v0nnn(OpCode op) {
    port.send("JP V0, ${op.nnn.toRadixString(16)}");
  }

  rnd_xkk(OpCode op) {
    port.send("RND ${op.x.toRadixString(16)}, ${op.kk.toRadixString(16)}");
  }

  drw_xyn(OpCode op) {
    // super chip extension
    if (op.n == 0) {
      port.send("DRW ${op.x.toRadixString(16)}, ${op.y.toRadixString(16)}, 0");
    } else {
      port.send(
          "DRW ${op.x.toRadixString(16)}, ${op.y.toRadixString(16)}, ${op.n.toRadixString(16)}");
    }
  }

  skp_x(OpCode op) {
    port.send("SKP ${op.x.toRadixString(16)}");
  }

  sknp_x(OpCode op) {
    port.send("SKNP ${op.x.toRadixString(16)}");
  }

  ld_xdt(OpCode op) {
    port.send("LD ${op.x.toRadixString(16)}, DT");
  }

  ld_xk(OpCode op) {
    port.send("LD ${op.x.toRadixString(16)}, K");
  }

  ld_dtx(OpCode op) {
    port.send("LD DT, ${op.x.toRadixString(16)}");
  }

  ld_stx(OpCode op) {
    port.send("LD ST, ${op.x.toRadixString(16)}");
  }

  add_ix(OpCode op) {
    port.send("ADD I, ${op.x.toRadixString(16)}");
  }

  ld_fx(OpCode op) {
    port.send("LD F, ${op.x.toRadixString(16)}");
  }

  ld_bx(OpCode op) {
    port.send("LD B, ${op.x.toRadixString(16)}");
  }

  ld_ix(OpCode op) {
    port.send("LD [I], ${op.x.toRadixString(16)}");
  }

  ld_xi(OpCode op) {
    port.send("LD ${op.x.toRadixString(16)}, [I]");
  }

  Uint8List mem; // cpu available memory
  Uint16List _pc_sp_i;
  bool stop = false;

  // 16bit program counter
  int get pc {
    return _pc_sp_i[0];
  }

  set pc(int val) {
    _pc_sp_i[0] = val;
  }

  Uint16List stack; // stack. 16 registries, 16 bits
  // stack pointer
  int get sp {
    return _pc_sp_i[1];
  }

  set sp(int val) {
    _pc_sp_i[1] = val;
  }

  Uint8List v; // 16 registries for general purpose
  // special directional registry
  int get i {
    return _pc_sp_i[1];
  }

  set i(int val) {
    _pc_sp_i[1] = val;
  }

  // 8 bit registers
  Uint8List _dt_st; // timers
  int get dt {
    return _dt_st[0];
  }

  set dt(int val) {
    _dt_st[0] = val;
  }

  int get st {
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

  bool _handleMessage(dynamic data) {
    if (data == Status.Stop) {
      stop = true;
      return true;
    }
    return false;
  }

  SendPort port;

  process(ByteData rom, SendPort sport, ReceivePort recv) async {
    StreamIterator<dynamic> inbox = new StreamIterator<dynamic>(recv);
    port = sport;
    port.send(Status.Running);
    // load rom in memory, first 512 positions are reserved
    for (var i = 0; i < rom.lengthInBytes; i++) {
      mem[i + 0x200] = rom.getUint8(i);
    }
    // program loaded into machine mem debug text
    String opcodes = "";
    // start processing
    var op = OpCode(0);
    Future<bool> hasNext = inbox.moveNext();
    var duration = Duration(microseconds: 1);
    while (!this.stop) {
      // message polling (kind of) this might be heavy too much boilerplate ...
      // cant find better way to communicate with isolate process
      bool next = await hasNext.timeout(duration, onTimeout: () => false);
      while (next) {
        _handleMessage(inbox.current);
        hasNext = inbox.moveNext();
        next = await hasNext.timeout(duration, onTimeout: () => false);
      }

      if (pc >= mem.length - 1) {
        pc = 0x200;
      }
      // opcodes are made of 16 bits, memory is made of 8,
      // so two mem entries = 1 opcode
      op.value = mem[pc] << 8 | mem[++pc];
      opcodes += op.value.toRadixString(16);
      pc++;

      if (op != null && op.value != 0) {
        var opFunction = operations[op.p];
        if (opFunction != null) {
          opFunction(this, op);
        }
      }
      // search for the op and exec it

    }

    port.send(opcodes);
    port.send(Status.Stopped);
  }
}
