import 'dart:typed_data';

import 'package:flutter/cupertino.dart';

var _BITMAP_FILE_HEADER_SIZE_BYTES = 14;
var _BITMAP_INFO_HEADER_SIZE_BYTES = 40;

int writeSize2(Uint8List res, int offset, int val) {
  res[offset] = val >> 8;
  offset++;
  res[offset] = val & 0xFF;
  offset++;
  return offset;
}

int writeSize4(Uint8List res, int offset, int val) {
  res[offset] = val >> 24;
  offset++;
  res[offset] = (val >> 16) & 0xFF;
  offset++;
  res[offset] = (val >> 8) & 0xFF;
  offset++;
  res[offset] = (val) & 0xFF;
  offset++;
  return offset;

}

int writeSize2Reverse(Uint8List res, int offset, int val) {
  res[offset] = val & 0xFF;
  offset++;
  res[offset] = val >> 8;
  offset++;
  return offset;
}

int writeSize4Reverse(Uint8List res, int offset, int val) {
  res[offset] = (val) & 0xFF;
  offset++;
  res[offset] = (val >> 8) & 0xFF;
  offset++;
  res[offset] = (val >> 16) & 0xFF;
  offset++;
  res[offset] = val >> 24;
  offset++;
  return offset;
}

class _FileHeader {
  int bfType = 0; // 2 bytes
  int bfSize = 0; // 4 bytes
  int bfReserved1 = 0; // 2 bytes
  int bfReserved2 = 0; // 2 bytes
  int bfOffBits = 0; // 4 bytes
  write (Uint8List res, int offset) {
    offset = writeSize2(res, offset, bfType);
    offset = writeSize4(res, offset, bfSize);
    offset = writeSize2(res, offset, bfReserved1);
    offset = writeSize2(res, offset, bfReserved2);
    offset = writeSize4(res, offset, bfOffBits);
    assert(() {
      return offset == _BITMAP_FILE_HEADER_SIZE_BYTES;
    }());
  }
  writeReverse (Uint8List res, int offset) {
    offset = writeSize2Reverse(res, offset, bfType);
    offset = writeSize4Reverse(res, offset, bfSize);
    offset = writeSize2Reverse(res, offset, bfReserved1);
    offset = writeSize2Reverse(res, offset, bfReserved2);
    offset = writeSize4Reverse(res, offset, bfOffBits);
    assert(() {
      return offset == _BITMAP_FILE_HEADER_SIZE_BYTES;
    }());
  }
}

class _InfoHeader {
  int biSize = 0; // 4 bytes
  int biWidth = 0; // 4 bytes
  int biHeight = 0; // 4 bytes
  int biPlanes = 0; // 2 bytes
  int biBitCount = 0; // 2 bytes
  int biCompression = 0; // 4 bytes
  int biSizeImage = 0; // 4 bytes
  int biXPelsPerMeter = 0; // 4 bytes
  int biYPelsPerMeter = 0; // 4 bytes
  int biClrUsed = 0; // 4 bytes
  int biClrImportant = 0; // 4 bytes
  write (Uint8List res, int offset) {
    offset = writeSize4(res, offset, biSize);
    offset = writeSize4(res, offset, biWidth);
    offset = writeSize4(res, offset, biHeight);
    offset = writeSize2(res, offset, biPlanes);
    offset = writeSize2(res, offset, biBitCount);
    offset = writeSize4(res, offset, biCompression);
    offset = writeSize4(res, offset, biSizeImage);
    offset = writeSize4(res, offset, biXPelsPerMeter);
    offset = writeSize4(res, offset, biYPelsPerMeter);
    offset = writeSize4(res, offset, biClrUsed);
    offset = writeSize4(res, offset, biClrImportant);
    assert(() {
      return offset == _BITMAP_FILE_HEADER_SIZE_BYTES + _BITMAP_INFO_HEADER_SIZE_BYTES;
    }());
  }
  writeReverse (Uint8List res, int offset) {
    offset = writeSize4Reverse(res, offset, biSize);
    offset = writeSize4Reverse(res, offset, biWidth);
    offset = writeSize4Reverse(res, offset, biHeight);
    offset = writeSize2Reverse(res, offset, biPlanes);
    offset = writeSize2Reverse(res, offset, biBitCount);
    offset = writeSize4Reverse(res, offset, biCompression);
    offset = writeSize4Reverse(res, offset, biSizeImage);
    offset = writeSize4Reverse(res, offset, biXPelsPerMeter);
    offset = writeSize4Reverse(res, offset, biYPelsPerMeter);
    offset = writeSize4Reverse(res, offset, biClrUsed);
    offset = writeSize4Reverse(res, offset, biClrImportant);
    assert(() {
      return offset == _BITMAP_FILE_HEADER_SIZE_BYTES + _BITMAP_INFO_HEADER_SIZE_BYTES;
    }());
  }
}

Uint8List createBitmap(int w, int h, Uint8List rgb) {
  // size in bytes
  var padding_size = (4 - (rgb.length % 4)) % 4;
  // Uint8List 1 byte per position
  _InfoHeader bmpInfoHeader = _InfoHeader();
  var bitsPerPixel = 3 * 8;
  bmpInfoHeader.biSize = _BITMAP_INFO_HEADER_SIZE_BYTES;
  // Bit count
  bmpInfoHeader.biBitCount = bitsPerPixel;
  // Use all colors
  bmpInfoHeader.biClrImportant = 0;
  // Use as many colors according to bits per pixel
  bmpInfoHeader.biClrUsed = 0;
  // Store as un-compressed
  bmpInfoHeader.biCompression = 0;
  // Set the height in pixels
  bmpInfoHeader.biHeight = h;
  // Width of the Image in pixels
  bmpInfoHeader.biWidth = w;
  // Default number of planes
  bmpInfoHeader.biPlanes = 1;
  // Calculate the image size in bytes
  bmpInfoHeader.biSizeImage =
      h * ((w * (bitsPerPixel / 8).toInt()) + padding_size);

  _FileHeader bfh = _FileHeader();

  // This value should be values of BM letters
  bfh.bfType = 0x4D42;
  // Offset to the RGBQUAD
  bfh.bfOffBits = _BITMAP_FILE_HEADER_SIZE_BYTES + _BITMAP_INFO_HEADER_SIZE_BYTES;

  // Total size of image including size of headers
  bfh.bfSize =
      _BITMAP_FILE_HEADER_SIZE_BYTES + _BITMAP_INFO_HEADER_SIZE_BYTES + rgb.length;

  Uint8List res = Uint8List(bfh.bfSize);

  bfh.writeReverse(res, 0);
  bmpInfoHeader.writeReverse(res, _BITMAP_FILE_HEADER_SIZE_BYTES);

  var offset = bfh.bfOffBits;
  for (int i = 0; i < rgb.length; i++) {
    var k = i + offset;
    res[k] = rgb[i];
  }
  return res;
}
