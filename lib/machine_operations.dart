import 'dart:math';
import 'dart:typed_data';

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

_zeroOpSelector(Machine mac, OpCode code) {
  // super chip extension
  if (code.y == 0xC)
    return _missing(mac, code);
  else
    return _kk_SubOperation[code.kk](mac, code);
}

_kkSubCall(Machine mac, OpCode code) {
  return _kk_SubOperation[code.kk](mac, code);
}

_nSubCall(Machine mac, OpCode code) {
  return _n_SubOperation[code.n](mac, code);
}

final _rand = Random(DateTime.now().millisecond);

const Map<int, OpCall> _operations = {
  0: _zeroOpSelector,
  1: _jp,
  2: _call,
  3: _se_xkk,
  4: _sne_xkk,
  5: _se_xy,
  6: _ld_xkk,
  7: _add_xkk,
  8: _nSubCall,
  9: _sne_xy,
  0xA: _ld_innn,
  0xB: _jp_v0nnn,
  0xC: _rnd_xkk,
  0xD: _drw_xyn,
  0xE: _kkSubCall,
  0xF: _kkSubCall,
};

const Map<int, OpCall> _n_SubOperation = {
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

const Map<int, OpCall> _kk_SubOperation = {
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
  mac.screen = Uint8List(64 * 32);
}

/// oposite to call
_ret(Machine mac, OpCode op) {
  mac.pc = mac.stack[mac.sp];
  mac.sp--;
}

/// jump to nnn
_jp(Machine mac, OpCode op) {
  mac.pc = op.nnn;
}

/// call nnn: tack[sp++] = pc, pc = nnn
_call(Machine mac, OpCode op) {
  mac.sp++;
  mac.stack[mac.sp] = mac.pc;
  mac.pc = op.nnn;
}

/// (skip equal) SE x, kk if v[x] == KK then pc+=2;
_se_xkk(Machine mac, OpCode op) {
  if (mac.V[op.x] == op.kk) mac.pc = (mac.pc + 2) /*& 0xFFF*/;
}

/// (skip if not equal) SE x, kk if v[x] != KK then pc+=2;
_sne_xkk(Machine mac, OpCode op) {
  if (mac.V[op.x] != op.kk) mac.pc = (mac.pc + 2) /*& 0xFFF*/;
}

/// (skip equal) SE x, kk if v[x] == v[x] then pc+=2;
_se_xy(Machine mac, OpCode op) {
  if (mac.V[op.x] == mac.V[op.y]) mac.pc = (mac.pc + 2) /* & 0xFFF*/;
}

/// load kk on V[x]
_ld_xkk(Machine mac, OpCode op) {
  mac.V[op.x] = op.kk;
}

/// add x kk no need to take carry into account but max 8bit
_add_xkk(Machine mac, OpCode op) {
  mac.V[op.x] = (mac.V[op.x] + op.kk) /* & 0xFF*/;
}

/// load V[x] = V[y]
_ld_xy(Machine mac, OpCode op) {
  mac.V[op.x] = mac.V[op.y];
}

/// or V[x] = V[x] | V[y]
_or_xy(Machine mac, OpCode op) {
  mac.V[op.x] = mac.V[op.x] | mac.V[op.y];
}

/// and V[x] = V[x] & V[y]
_and_xy(Machine mac, OpCode op) {
  mac.V[op.x] = mac.V[op.x] & mac.V[op.y];
}

/// xor V[x] = V[x] ^ V[y]
_xor_xy(Machine mac, OpCode op) {
  mac.V[op.x] = mac.V[op.x] ^ mac.V[op.y];
}

/// add V[x] = V[x] + V[y] with carry
_add_xy(Machine mac, OpCode op) {
  // flutter int is 64 we need 8 bit
  int r = (mac.V[op.x] + mac.V[op.y]) & 0xFF;
  // set carry
  mac.V[0xF] = mac.V[op.x] > r ? 1 : 0;
  mac.V[op.x] = r;
}

/// sub V[x] = V[x] - V[y] with carry
_sub_xy(Machine mac, OpCode op) {
  mac.V[0xF] = mac.V[op.x] > mac.V[op.y] ? 1 : 0;
  mac.V[op.x] = mac.V[op.x] - mac.V[op.y];
}

/// shr V[x] = V[x] >> 1 (this is sames as v[x] /=2) with carry
_shr_x(Machine mac, OpCode op) {
  mac.V[0xF] = (mac.V[op.x] & 0x01) != 0 ? 1 : 0;
  mac.V[op.x] = mac.V[op.x] >> 1;
}

/// subn x y => sub V[x] = V[y] - V[x] with carry
_subn_xy(Machine mac, OpCode op) {
  mac.V[0xF] = mac.V[op.y] > mac.V[op.x] ? 1 : 0;
  mac.V[op.x] = mac.V[op.y] - mac.V[op.x];
}

/// shl V[x] = V[x] << 1 (this is sames as v[x] *=2) with carry
_shl_x(Machine mac, OpCode op) {
  mac.V[0xF] = (mac.V[op.x] & 0x80) != 0 ? 1 : 0;
  mac.V[op.x] = mac.V[op.x] << 1;
}

/// sne x, y -> v[x] != v[y] -> pc+=2
_sne_xy(Machine mac, OpCode op) {
  if (mac.V[op.x] != mac.V[op.y]) mac.pc = (mac.pc + 2) /*& 0xFFF*/;
}

/// LD I, nnn -> I = nnn
_ld_innn(Machine mac, OpCode op) {
  mac.I = op.nnn;
}

_jp_v0nnn(Machine mac, OpCode op) {
  mac.pc = (mac.V[0] + op.nnn) & 0xFFF;
}

/// RND x, kk -> V[x] = random() % kk
_rnd_xkk(Machine mac, OpCode op) {
  mac.V[op.x] = _rand.nextInt(op.kk + 1);
}

/// print sprite from [I] on screen at v[x] v[y] position
_drw_xyn(Machine mac, OpCode op) {
  // super chip extension
  if (op.n == 0) {
    _missing(mac, op);
  } else {
    //clean carry
    mac.V[0xF] = 0;
    // rows
    for (int i = 0; i < op.n; i++) {
      int sprite = mac.mem[mac.I + i];
      // columns
      for (int j = 0; j < 8; j++) {
        int px = (mac.V[op.x] + j) & 63; // same as % 64
        int py = (mac.V[op.y] + i) & 31; // same as % 32
        // turn on off the pixel in the sprite
        int pos = 64 * py + px;
        int pixel = (sprite & (1 << (7 - j))) != 0 ? 1 : 0;

        mac.V[0xF] |= (mac.screen[pos] & pixel);
        mac.screen[pos] ^= pixel;
      }
    }
  }
}

_skp_x(Machine mac, OpCode op) {
  if (mac.V[op.x] == mac.keyPressed) mac.pc += 2;
}

_sknp_x(Machine mac, OpCode op) {
  if (mac.V[op.x] != mac.keyPressed) mac.pc += 2;
}

/// LD -> v[x] = DT
_ld_xdt(Machine mac, OpCode op) {
  mac.V[op.x] = mac.dt;
}

_ld_xk(Machine mac, OpCode op) {
  mac.waitForKey = op.x;
}

/// LD -> DT = v[x]
_ld_dtx(Machine mac, OpCode op) {
  mac.dt = mac.V[op.x];
}

/// LD -> ST = v[x]
_ld_stx(Machine mac, OpCode op) {
  mac.st = mac.V[op.x];
}

/// add I, v[x]
_add_ix(Machine mac, OpCode op) {
  mac.I += mac.V[op.x];
}

_ld_fx(Machine mac, OpCode op) {
  mac.I = 0x50 + mac.V[op.x] * 5;
}

/// LD B, V[x] -> load BCD number in mem
_ld_bx(Machine mac, OpCode op) {
  int num = mac.V[op.x];
  mac.mem[mac.I + 2] = num % 10; //units
  mac.mem[mac.I + 1] = (num ~/ 10) % 10; //tens
  mac.mem[mac.I] = num ~/ 100; //hundreds
}

/// LD [I], V[x]
_ld_ix(Machine mac, OpCode op) {
  for (int reg = 0; reg <= op.x; reg++) {
    mac.mem[mac.I + reg] = mac.V[reg];
  }
}

/// LD V[x], [I]
_ld_xi(Machine mac, OpCode op) {
  for (int reg = 0; reg <= op.x; reg++) {
    mac.V[reg] = mac.mem[mac.I + reg];
  }
}
