
import 'machine.dart';

typedef OpCall = void Function(Machine mac, OpCode code);

/// The only element publicly exposed is this function that run the op code
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
      {_missing(mac, code)}
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


_missing(Machine mac, OpCode op) {
  throw Exception('Unimplemented operation ${op.value.toRadixString(16)}');
}

_cls(Machine mac, OpCode op) {
  mac.port.send("CLS");
}

_ret(Machine mac, OpCode op) {
  mac.port.send("RET");
}

_jp(Machine mac,OpCode op) {
  mac.port.send("JP ${op.nnn.toRadixString(16)}");
}

_call(Machine mac, OpCode op) {
  mac.port.send("CALL ${op.nnn.toRadixString(16)}");
}

_se_xkk(Machine mac, OpCode op) {
  mac.port.send("SE ${op.x.toRadixString(16)}, ${op.kk.toRadixString(16)}");
}

_sne_xkk(Machine mac, OpCode op) {
  mac.port.send("SNE ${op.x.toRadixString(16)}, ${op.kk.toRadixString(16)}");
}

_se_xy(Machine mac, OpCode op) {
  mac.port.send("SE ${op.x.toRadixString(16)}, ${op.y.toRadixString(16)}");
}

_ld_xkk(Machine mac, OpCode op) {
  mac.port.send("LD ${op.x.toRadixString(16)}, ${op.kk.toRadixString(16)}");
}

_add_xkk(Machine mac, OpCode op) {
  mac.port.send("ADD ${op.x.toRadixString(16)}, ${op.kk.toRadixString(16)}");
}

_ld_xy(Machine mac, OpCode op) {
  mac.port.send("LD ${op.x.toRadixString(16)}, ${op.y.toRadixString(16)}");
}

_or_xy(Machine mac, OpCode op) {
  mac.port.send("OR ${op.x.toRadixString(16)}, ${op.y.toRadixString(16)}");
}

_and_xy(Machine mac, OpCode op) {
  mac.port.send("AND ${op.x.toRadixString(16)}, ${op.y.toRadixString(16)}");
}

_xor_xy(Machine mac, OpCode op) {
  mac.port.send("XOR ${op.x.toRadixString(16)}, ${op.y.toRadixString(16)}");
}

_add_xy(Machine mac, OpCode op) {
  mac.port.send("ADD ${op.x.toRadixString(16)}, ${op.y.toRadixString(16)}");
}

_sub_xy(Machine mac, OpCode op) {
  mac.port.send("SUB ${op.x.toRadixString(16)}, ${op.y.toRadixString(16)}");
}

_shr_x(Machine mac, OpCode op) {
  mac.port.send("SHR ${op.x.toRadixString(16)}");
}

_subn_xy(Machine mac, OpCode op) {
  mac.port.send("SUBN ${op.x.toRadixString(16)}, ${op.y.toRadixString(16)}");
}

_shl_x(Machine mac, OpCode op) {
  mac.port.send("SHL ${op.x.toRadixString(16)}");
}

_sne_xy(Machine mac, OpCode op) {
  mac.port.send("SNE ${op.x.toRadixString(16)}, ${op.y.toRadixString(16)}");
}

_ld_innn(Machine mac, OpCode op) {
  mac.port.send("LD I, ${op.nnn.toRadixString(16)}");
}

_jp_v0nnn(Machine mac, OpCode op) {
  mac.port.send("JP V0, ${op.nnn.toRadixString(16)}");
}

_rnd_xkk(Machine mac, OpCode op) {
  mac.port.send("RND ${op.x.toRadixString(16)}, ${op.kk.toRadixString(16)}");
}

_drw_xyn(Machine mac, OpCode op) {
  // super chip extension
  if (op.n == 0) {
    mac.port.send("DRW ${op.x.toRadixString(16)}, ${op.y.toRadixString(16)}, 0");
  } else {
    mac.port.send(
        "DRW ${op.x.toRadixString(16)}, ${op.y.toRadixString(16)}, ${op.n.toRadixString(16)}");
  }
}

_skp_x(Machine mac, OpCode op) {
  mac.port.send("SKP ${op.x.toRadixString(16)}");
}

_sknp_x(Machine mac, OpCode op) {
  mac.port.send("SKNP ${op.x.toRadixString(16)}");
}

_ld_xdt(Machine mac, OpCode op) {
  mac.port.send("LD ${op.x.toRadixString(16)}, DT");
}

_ld_xk(Machine mac, OpCode op) {
  mac.port.send("LD ${op.x.toRadixString(16)}, K");
}

_ld_dtx(Machine mac, OpCode op) {
  mac.port.send("LD DT, ${op.x.toRadixString(16)}");
}

_ld_stx(Machine mac, OpCode op) {
  mac.port.send("LD ST, ${op.x.toRadixString(16)}");
}

_add_ix(Machine mac, OpCode op) {
  mac.port.send("ADD I, ${op.x.toRadixString(16)}");
}

_ld_fx(Machine mac, OpCode op) {
  mac.port.send("LD F, ${op.x.toRadixString(16)}");
}

_ld_bx(Machine mac, OpCode op) {
  mac.port.send("LD B, ${op.x.toRadixString(16)}");
}

_ld_ix(Machine mac, OpCode op) {
  mac.port.send("LD [I], ${op.x.toRadixString(16)}");
}

_ld_xi(Machine mac, OpCode op) {
  mac.port.send("LD ${op.x.toRadixString(16)}, [I]");
}