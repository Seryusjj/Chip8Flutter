import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter/services.dart';

import 'machine_operations.dart';

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

enum Operations { UpdateScreen, Stop, Stopped, Running, Communication }

const _hexCodes = [
  0xF0, 0x90, 0x90, 0x90, 0xF0, // 0
  0x20, 0x60, 0x20, 0x20, 0x70, // 1
  0xF0, 0x10, 0xF0, 0x80, 0xF0, // 2
  0xF0, 0x10, 0xF0, 0x10, 0xF0, // 3
  0x90, 0x90, 0xF0, 0x10, 0x10, // 4
  0xF0, 0x80, 0xF0, 0x10, 0xF0, // 5
  0xF0, 0x80, 0xF0, 0x90, 0xF0, // 6
  0xF0, 0x10, 0x20, 0x40, 0x40, // 7
  0xF0, 0x90, 0xF0, 0x90, 0xF0, // 8
  0xF0, 0x90, 0xF0, 0x10, 0xF0, // 9
  0xF0, 0x90, 0xF0, 0x90, 0x90, // A
  0xE0, 0x90, 0xE0, 0x90, 0xE0, // B
  0xF0, 0x80, 0x80, 0x80, 0xF0, // C
  0xE0, 0x90, 0x90, 0x90, 0xE0, // D
  0xF0, 0x80, 0xF0, 0x80, 0xF0, // E
  0xF0, 0x80, 0xF0, 0x80, 0x80, // F
];

class Machine {
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

  Uint8List V; // 16 registries for general purpose
  // special directional registry
  int get I {
    return _pc_sp_i[2];
  }

  set I(int val) {
    _pc_sp_i[2] = val;
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

  Uint8List screen;

  _init() {
    screen = Uint8List(64 * 32);
    mem = Uint8List(4096);
    for (int i = 0; i < _hexCodes.length; i++) {
      mem[i + 0x50] = _hexCodes[i];
    }
    V = Uint8List(16);
    stack = Uint16List(16);
    _pc_sp_i = Uint16List(3); //0 pc, 1 sp, 2 I
    pc = 0x200;
    sp = 0;
    I = 0;
    _dt_st = Uint8List(2);
    dt = 0;
    st = 0;
  }

  _handleMessage(dynamic data) {
    switch (data[0]) {
      case Operations.Stop:
        stop = true;
        break;
    }
  }

  SendPort port;

  run(ByteData rom, SendPort sport, ReceivePort recv) async {
    StreamIterator<dynamic> inbox = new StreamIterator<dynamic>(recv);
    Future<bool> hasNext = inbox.moveNext();
    port = sport;
    final op = OpCode(0);

    // load rom in memory, first 512 positions are reserved
    for (var i = 0; i < rom.lengthInBytes; i++) {
      mem[i + 0x200] = rom.getUint8(i);
    }

    // rom loaded into machine mem debug text
    port.send([Operations.Running]);

    // start processing, run 60 instructions per second
    const duration = Duration(microseconds: 1);
    Stopwatch watch = Stopwatch();
    watch.start();
    while (!this.stop) {
      // message polling (kind of) cant find better way to communicate
      // with flutter isolates
      while (await hasNext.timeout(duration, onTimeout: () => false)) {
        _handleMessage(inbox.current);
        hasNext = inbox.moveNext();
      }

      if (pc >= mem.length - 1) {
        pc = 0x200;
      }
      // opcodes are made of 16 bits, memory is made of 8,
      // so two mem entries = 1 opcode
      op.value = mem[pc] << 8 | mem[pc + 1];
      // opcodes += op.value.toRadixString(16);
      pc += 2;

      runOperation(this, op);

      //update screen 30fps assuming the frame was painted (we will never know)
      if (watch.elapsedMilliseconds >= 16) {
        sport.send([Operations.UpdateScreen, genImageUI(screen)]);
        if (dt > 0) dt--;
        if (st > 0) st--;
        watch.reset();
      }
    }

    //port.send(opcodes);
    port.send([Operations.Stopped]);
  }

  Uint8List genImageUI(Uint8List screen) {
    const dataLength = 32 * 64 * 4;
    //use this.screen to gen the picture
    var imageData = Uint8List(dataLength);
    var c = 0;
    for (int i = 0; i < screen.length; i++) {
      if (screen[i] == 1) {
        imageData[c] = 255; //r
        imageData[c + 1] = 255; //g
        imageData[c + 2] = 255; //b
        imageData[c + 3] = 255; //a
      } else {
        imageData[c] = 0; //r
        imageData[c + 1] = 0; //g
        imageData[c + 2] = 0; //b
        imageData[c + 3] = 255; //a
      }

      c += 4;
    }

    return imageData;
  }
}
