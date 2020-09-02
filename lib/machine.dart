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

enum Status {
  Stop,
  Stopped,
  Running,
}



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
      // opcodes += op.value.toRadixString(16);
      pc++;

      if (op != null && op.value != 0) {
        var opFunction = operations[op.p];
        // opFunction will be null of operation not found
        // so an exception will raise that is ok
        opFunction(this, op);
      }
    }

    port.send(opcodes);
    port.send(Status.Stopped);
  }
}
