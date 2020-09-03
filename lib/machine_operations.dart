import 'machine.dart';

typedef OpCall = void Function(Machine mac, OpCode code);

/// The only element publicly exposed is this function that run the op code
/// The time cost of executing an operation is O(1)
runOperation(Machine mac, OpCode op) {
  if (op != null && op.value != 0) {
    var opFunction = _operations[op.p];
    // opFunction will be null if operation is not found
    // so an exception will be raise when trying to run it
    opFunction(mac, op);
  }
}

Map<int, OpCall> _operations = {
  0: (Machine mac, OpCode code) => {
        // super chip extension
        if (code.y == 0xC)
          _missing(mac, code)
        else
          _kk_SubOperation[code.kk](mac, code)
      },
  1: _jp,
  2: _call,
  3: _se_xkk,
  4: _sne_xkk,
  5: _se_xy,
  6: _ld_xkk,
  7: _add_xkk,
  8: (Machine mac, OpCode code) => _n_SubOperation[code.n](mac, code),
  9: _sne_xy,
  0xA: _ld_innn,
  0xB: _jp_v0nnn,
  0xC: _rnd_xkk,
  0xD: _drw_xyn,
  0xE: (Machine mac, OpCode code) => _kk_SubOperation[code.kk](mac, code),
  0xF: (Machine mac, OpCode code) => _kk_SubOperation[code.kk](mac, code),
};

Map<int, OpCall> _n_SubOperation = {
  0: _ld_xy,
  1: _or_xy,
  2: _and_xy,
  3: _xor_xy,
  4: _add_xy,
  5: _sub_xy,
  6: _shr_x,
  7: _subn_xy,
  0xE: _shl_x,
};

Map<int, OpCall> _kk_SubOperation = {
  0x9E: _skp_x,
  0xA1: _sknp_x,
  0x07: _ld_xdt,
  0x0A: _ld_xk,
  0x15: _ld_dtx,
  0x18: _ld_stx,
  0x1E: _add_ix,
  0x29: _ld_fx,
  0x33: _ld_bx,
  0x55: _ld_ix,
  0x65: _ld_xi,
  0xE0: _cls,
  0xEE: _ret,
  // super chip extension 0x0
  0xFB: _missing,
  0xFC: _missing,
  0xFD: _missing,
  0xFE: _missing,
  0xFF: _missing,
  // super chip extension 0xF
  0x30: _missing,
  0x75: _missing,
  0x85: _missing,
};

_debugPrint(String str) {
  assert(() {
    print(str);
    return true;
  }());
}

_missing(Machine mac, OpCode op) {
  throw Exception('Unimplemented operation ${op.value.toRadixString(16)}');
}

_cls(Machine mac, OpCode op) {
  _debugPrint("CLS");
}

_ret(Machine mac, OpCode op) {
  _debugPrint("RET");
}

/// jump to nnn
_jp(Machine mac, OpCode op) {
  mac.pc = op.nnn;
  _debugPrint("JP ${op.nnn.toRadixString(16)}");
}

_call(Machine mac, OpCode op) {
  _debugPrint("CALL ${op.nnn.toRadixString(16)}");
}

/// (skip equal) SE x, kk if v[x] == KK then pc+=2;
_se_xkk(Machine mac, OpCode op) {
  if (mac.V[op.x] == op.kk) mac.pc = (mac.pc + 2) /*& 0xFFF*/;
  _debugPrint("SE ${op.x.toRadixString(16)}, ${op.kk.toRadixString(16)}");
}

/// (skip if not equal) SE x, kk if v[x] != KK then pc+=2;
_sne_xkk(Machine mac, OpCode op) {
  if (mac.V[op.x] != op.kk) mac.pc = (mac.pc + 2) /*& 0xFFF*/;
  _debugPrint("SNE ${op.x.toRadixString(16)}, ${op.kk.toRadixString(16)}");
}

/// (skip equal) SE x, kk if v[x] == v[x] then pc+=2;
_se_xy(Machine mac, OpCode op) {
  if (mac.V[op.x] == mac.V[op.y]) mac.pc = (mac.pc + 2) /* & 0xFFF*/;
  _debugPrint("SN ${op.x.toRadixString(16)}, ${op.y.toRadixString(16)}");
}

/// load kk on V[x]
_ld_xkk(Machine mac, OpCode op) {
  mac.V[op.x] = op.kk;
  _debugPrint("LD ${op.x.toRadixString(16)}, ${op.kk.toRadixString(16)}");
}

/// add x kk no need to take carry into account but max 8bit
_add_xkk(Machine mac, OpCode op) {
  mac.V[op.x] = (mac.V[op.x] + op.kk) /* & 0xFF*/;
  _debugPrint("ADD ${op.x.toRadixString(16)}, ${op.kk.toRadixString(16)}");
}

/// load V[x] = V[y]
_ld_xy(Machine mac, OpCode op) {
  mac.V[op.x] = mac.V[op.y];
  _debugPrint("LD ${op.x.toRadixString(16)}, ${op.y.toRadixString(16)}");
}

/// or V[x] = V[x] | V[y]
_or_xy(Machine mac, OpCode op) {
  mac.V[op.x] = mac.V[op.x] | mac.V[op.y];
  _debugPrint("OR ${op.x.toRadixString(16)}, ${op.y.toRadixString(16)}");
}

/// and V[x] = V[x] & V[y]
_and_xy(Machine mac, OpCode op) {
  mac.V[op.x] = mac.V[op.x] & mac.V[op.y];
  _debugPrint("AND ${op.x.toRadixString(16)}, ${op.y.toRadixString(16)}");
}

/// xor V[x] = V[x] ^ V[y]
_xor_xy(Machine mac, OpCode op) {
  mac.V[op.x] = mac.V[op.x] ^ mac.V[op.y];
  _debugPrint("XOR ${op.x.toRadixString(16)}, ${op.y.toRadixString(16)}");
}

/// add V[x] = V[x] + V[y] with carry
_add_xy(Machine mac, OpCode op) {
  // flutter int is 64 we need 16 bit
  int r = (mac.V[op.x] + mac.V[op.y]) & 0xFF;
  // set carry
  mac.V[0xF] = mac.V[op.x] > r ? 1 : 0;
  mac.V[op.x] = r;
  _debugPrint("ADD ${op.x.toRadixString(16)}, ${op.y.toRadixString(16)}");
}

/// sub V[x] = V[x] - V[y] with carry
_sub_xy(Machine mac, OpCode op) {
  mac.V[0xF] = mac.V[op.x] > mac.V[op.y] ? 1 : 0;
  mac.V[op.x] = mac.V[op.x] - mac.V[op.y];
  _debugPrint("SUB ${op.x.toRadixString(16)}, ${op.y.toRadixString(16)}");
}

/// shr V[x] = V[x] >> 1 (this is sames as v[x] /=2) with carry
_shr_x(Machine mac, OpCode op) {
  mac.V[0xF] = (mac.V[op.x] & 0x01) != 0 ? 1 : 0;
  mac.V[op.x] = mac.V[op.x] >> 1;
  _debugPrint("SHR ${op.x.toRadixString(16)}, 1");
}

/// subn x y => sub V[x] = V[y] - V[x] with carry
_subn_xy(Machine mac, OpCode op) {
  mac.V[0xF] = mac.V[op.y] > mac.V[op.x] ? 1 : 0;
  mac.V[op.x] = mac.V[op.y] - mac.V[op.x];
  _debugPrint("SUBN ${op.x.toRadixString(16)}, ${op.y.toRadixString(16)}");
}

/// shl V[x] = V[x] << 1 (this is sames as v[x] *=2) with carry
_shl_x(Machine mac, OpCode op) {
  mac.V[0xF] = (mac.V[op.x] & 0x80) != 0 ? 1 : 0;
  mac.V[op.x] = mac.V[op.x] << 1;
  _debugPrint("SHL ${op.x.toRadixString(16)}, 1");
}

/// sne x, y -> v[x] != v[y] -> pc+=2
_sne_xy(Machine mac, OpCode op) {
  if (mac.V[op.x] != mac.V[op.y]) mac.pc = (mac.pc + 2) /*& 0xFFF*/;
  _debugPrint("SNE ${op.x.toRadixString(16)}, ${op.y.toRadixString(16)}");
}

/// LD I, nnn -> I = nnn
_ld_innn(Machine mac, OpCode op) {
  mac.i = op.nnn;
  _debugPrint("LD I, ${op.nnn.toRadixString(16)}");
}

_jp_v0nnn(Machine mac, OpCode op) {
  mac.pc = (mac.V[0] + op.nnn) /*& 0xFFF*/;
  _debugPrint("JP V[0], ${op.nnn.toRadixString(16)}");
}

_rnd_xkk(Machine mac, OpCode op) {
  print("RND ${op.x.toRadixString(16)}, ${op.kk.toRadixString(16)}");
  _debugPrint("RND ${op.x.toRadixString(16)}, ${op.kk.toRadixString(16)}");
}

_drw_xyn(Machine mac, OpCode op) {
  // super chip extension
  if (op.n == 0) {
    _missing(mac, op);
  } else {
    _debugPrint(
        "DRW ${op.x.toRadixString(16)}, ${op.y.toRadixString(16)}, ${op.n.toRadixString(16)}");
  }
}

_skp_x(Machine mac, OpCode op) {
  _debugPrint("SKP ${op.x.toRadixString(16)}");
}

_sknp_x(Machine mac, OpCode op) {
  _debugPrint("SKNP ${op.x.toRadixString(16)}");
}

/// LD -> v[x] = DT
_ld_xdt(Machine mac, OpCode op) {
  mac.V[op.x] = mac.dt;
  _debugPrint("LD x=${op.x.toRadixString(16)}, dt=${mac.dt.toRadixString(16)}");
}

_ld_xk(Machine mac, OpCode op) {
  _debugPrint("LD ${op.x.toRadixString(16)}, K");
}

/// LD -> DT = v[x]
_ld_dtx(Machine mac, OpCode op) {
  mac.dt = mac.V[op.x];
  _debugPrint("LD dt=${mac.dt.toRadixString(16)}, x=${op.x.toRadixString(16)}");
}

/// LD -> ST = v[x]
_ld_stx(Machine mac, OpCode op) {
  mac.st = mac.V[op.x];
  _debugPrint("LD st=${mac.st.toRadixString(16)}, x=${op.x.toRadixString(16)}");
}

/// add I, v[x]
_add_ix(Machine mac, OpCode op) {
  mac.i += mac.V[op.x];
  _debugPrint("ADD I=${mac.i.toRadixString(16)}, x=${op.x.toRadixString(16)}");
}

_ld_fx(Machine mac, OpCode op) {
  _debugPrint("LD F, ${op.x.toRadixString(16)}");
}

_ld_bx(Machine mac, OpCode op) {
  _debugPrint("LD B, ${op.x.toRadixString(16)}");
}

_ld_ix(Machine mac, OpCode op) {
  _debugPrint("LD [I], ${op.x.toRadixString(16)}");
}

_ld_xi(Machine mac, OpCode op) {
  _debugPrint("LD ${op.x.toRadixString(16)}, [I]");
}
