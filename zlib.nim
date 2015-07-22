## zlib interface
import os, sequtils, macros

template pwd: string =
  parentDir(instantiationInfo(-1, true).filename)

const
  ZlibVer = "1.2.8"
  ZlibDir = pwd / "private" / "zlib-" & ZlibVer
  ZlibSrc = ["adler32.c",
             "compress.c",
             "crc32.c",
             "deflate.c",
             "gzclose.c",
             "gzlib.c",
             "gzread.c",
             "gzwrite.c",
             "inflate.c",
             "infback.c",
             "inftrees.c",
             "inffast.c",
             "trees.c",
             "uncompr.c",
             "zutil.c"
             ].mapIt(string, ZlibDir / it)
  ZlibHeader = ZlibDir / "zlib.h"

macro cc(f: string): stmt =
  result = quote do:
    {.compile: `f`.}

macro cc(files: static[openArray[string]]): stmt =
  result = newStmtList()
  for f in files:
    result.add quote do:
      cc`f`

# Compile zlib
cc ZlibSrc

type
  Uint* = int32
  Ulong* = int
  Ulongf* = int
  Pulongf* = ptr Ulongf
  ZOffT* = int32
  Pbyte* = cstring
  Pbytef* = cstring
  TAllocfunc* = proc (p: pointer, items: Uint, size: Uint): pointer{.cdecl.}
  TFreeFunc* = proc (p: pointer, address: pointer){.cdecl.}
  TInternalState*{.final, pure.} = object 
  PInternalState* = ptr TInternalState
  TZStream*{.final, pure.} = object 
    nextIn*: Pbytef
    availIn*: Uint
    totalIn*: Ulong
    nextOut*: Pbytef
    availOut*: Uint
    totalOut*: Ulong
    msg*: Pbytef
    state*: PInternalState
    zalloc*: TAllocfunc
    zfree*: TFreeFunc
    opaque*: pointer
    dataType*: int32
    adler*: Ulong
    reserved*: Ulong

  TZStreamRec* = TZStream
  PZstream* = ptr TZStream
  GzFile* = pointer

const 
  Z_NO_FLUSH* = 0
  Z_PARTIAL_FLUSH* = 1
  Z_SYNC_FLUSH* = 2
  Z_FULL_FLUSH* = 3
  Z_FINISH* = 4
  Z_OK* = 0
  Z_STREAM_END* = 1
  Z_NEED_DICT* = 2
  Z_ERRNO* = -1
  Z_STREAM_ERROR* = -2
  Z_DATA_ERROR* = -3
  Z_MEM_ERROR* = -4
  Z_BUF_ERROR* = -5
  Z_VERSION_ERROR* = -6
  Z_NO_COMPRESSION* = 0
  Z_BEST_SPEED* = 1
  Z_BEST_COMPRESSION* = 9
  Z_DEFAULT_COMPRESSION* = -1
  Z_FILTERED* = 1
  Z_HUFFMAN_ONLY* = 2
  Z_DEFAULT_STRATEGY* = 0
  Z_BINARY* = 0
  Z_ASCII* = 1
  Z_UNKNOWN* = 2
  Z_DEFLATED* = 8
  Z_NULL* = 0

proc zlibVersion*(): cstring{.cdecl, header: ZlibHeader, importc: "zlibVersion".}
proc deflate*(strm: var TZStream, flush: int32): int32{.cdecl, header: ZlibHeader, 
    importc: "deflate".}
proc deflateEnd*(strm: var TZStream): int32{.cdecl, header: ZlibHeader, 
    importc: "deflateEnd".}
proc inflate*(strm: var TZStream, flush: int32): int32{.cdecl, header: ZlibHeader, 
    importc: "inflate".}
proc inflateEnd*(strm: var TZStream): int32{.cdecl, header: ZlibHeader, 
    importc: "inflateEnd".}
proc deflateSetDictionary*(strm: var TZStream, dictionary: Pbytef, 
                           dictLength: Uint): int32{.cdecl, header: ZlibHeader, 
    importc: "deflateSetDictionary".}
proc deflateCopy*(dest, source: var TZStream): int32{.cdecl, header: ZlibHeader, 
    importc: "deflateCopy".}
proc deflateReset*(strm: var TZStream): int32{.cdecl, header: ZlibHeader, 
    importc: "deflateReset".}
proc deflateParams*(strm: var TZStream, level: int32, strategy: int32): int32{.
    cdecl, header: ZlibHeader, importc: "deflateParams".}
proc inflateSetDictionary*(strm: var TZStream, dictionary: Pbytef, 
                           dictLength: Uint): int32{.cdecl, header: ZlibHeader, 
    importc: "inflateSetDictionary".}
proc inflateSync*(strm: var TZStream): int32{.cdecl, header: ZlibHeader, 
    importc: "inflateSync".}
proc inflateReset*(strm: var TZStream): int32{.cdecl, header: ZlibHeader, 
    importc: "inflateReset".}
proc compress*(dest: Pbytef, destLen: Pulongf, source: Pbytef, sourceLen: Ulong): cint{.
    cdecl, header: ZlibHeader, importc: "compress".}
proc compress2*(dest: Pbytef, destLen: Pulongf, source: Pbytef, 
                sourceLen: Ulong, level: cint): cint{.cdecl, header: ZlibHeader, 
    importc: "compress2".}
proc uncompress*(dest: Pbytef, destLen: Pulongf, source: Pbytef, 
                 sourceLen: Ulong): cint{.cdecl, header: ZlibHeader, 
    importc: "uncompress".}
proc compressBound*(sourceLen: Ulong): Ulong {.cdecl, header: ZlibHeader, importc.}
proc gzopen*(path: cstring, mode: cstring): GzFile{.cdecl, header: ZlibHeader, 
    importc: "gzopen".}
proc gzdopen*(fd: int32, mode: cstring): GzFile{.cdecl, header: ZlibHeader, 
    importc: "gzdopen".}
proc gzsetparams*(thefile: GzFile, level: int32, strategy: int32): int32{.cdecl, 
    header: ZlibHeader, importc: "gzsetparams".}
proc gzread*(thefile: GzFile, buf: pointer, length: int): int32{.cdecl, 
    header: ZlibHeader, importc: "gzread".}
proc gzwrite*(thefile: GzFile, buf: pointer, length: int): int32{.cdecl, 
    header: ZlibHeader, importc: "gzwrite".}
proc gzprintf*(thefile: GzFile, format: Pbytef): int32{.varargs, cdecl, 
    header: ZlibHeader, importc: "gzprintf".}
proc gzputs*(thefile: GzFile, s: Pbytef): int32{.cdecl, header: ZlibHeader, 
    importc: "gzputs".}
proc gzgets*(thefile: GzFile, buf: Pbytef, length: int32): Pbytef{.cdecl, 
    header: ZlibHeader, importc: "gzgets".}
proc gzputc*(thefile: GzFile, c: int32): int32{.cdecl, header: ZlibHeader, 
    importc: "gzputc".}
proc gzgetc*(thefile: GzFile): int32{.cdecl, header: ZlibHeader, importc: "gzgetc".}
proc gzungetc*(c: int32, thefile: GzFile): int32{.cdecl, header: ZlibHeader, importc: "gzungetc".}
proc gzflush*(thefile: GzFile, flush: int32): int32{.cdecl, header: ZlibHeader, 
    importc: "gzflush".}
proc gzseek*(thefile: GzFile, offset: ZOffT, whence: int32): ZOffT{.cdecl, 
    header: ZlibHeader, importc: "gzseek".}
proc gzrewind*(thefile: GzFile): int32{.cdecl, header: ZlibHeader, importc: "gzrewind".}
proc gztell*(thefile: GzFile): ZOffT{.cdecl, header: ZlibHeader, importc: "gztell".}
proc gzeof*(thefile: GzFile): int {.cdecl, header: ZlibHeader, importc: "gzeof".}
proc gzclose*(thefile: GzFile): int32{.cdecl, header: ZlibHeader, importc: "gzclose".}
proc gzerror*(thefile: GzFile, errnum: var int32): Pbytef{.cdecl, header: ZlibHeader, 
    importc: "gzerror".}
proc adler32*(adler: Ulong, buf: Pbytef, length: Uint): Ulong{.cdecl, 
    header: ZlibHeader, importc: "adler32".}
  ## **Warning**: Adler-32 requires at least a few hundred bytes to get rolling.
proc crc32*(crc: Ulong, buf: Pbytef, length: Uint): Ulong{.cdecl, header: ZlibHeader, 
    importc: "crc32".}
proc deflateInitu*(strm: var TZStream, level: int32, version: cstring, 
                   streamSize: int32): int32{.cdecl, header: ZlibHeader, 
    importc: "deflateInit_".}
proc inflateInitu*(strm: var TZStream, version: cstring,
                   streamSize: int32): int32 {.
    cdecl, header: ZlibHeader, importc: "inflateInit_".}
proc deflateInit*(strm: var TZStream, level: int32): int32
proc inflateInit*(strm: var TZStream): int32
proc deflateInit2u*(strm: var TZStream, level: int32, `method`: int32, 
                    windowBits: int32, memLevel: int32, strategy: int32, 
                    version: cstring, streamSize: int32): int32 {.cdecl, 
                    header: ZlibHeader, importc: "deflateInit2_".}
proc inflateInit2u*(strm: var TZStream, windowBits: int32, version: cstring, 
                    streamSize: int32): int32{.cdecl, header: ZlibHeader, 
    importc: "inflateInit2_".}
proc deflateInit2*(strm: var TZStream, 
                   level, `method`, windowBits, memLevel,
                   strategy: int32): int32
proc inflateInit2*(strm: var TZStream, windowBits: int32): int32
proc zError*(err: int32): cstring{.cdecl, header: ZlibHeader, importc: "zError".}
proc inflateSyncPoint*(z: PZstream): int32{.cdecl, header: ZlibHeader, 
    importc: "inflateSyncPoint".}
proc getCrcTable*(): pointer{.cdecl, header: ZlibHeader, importc: "get_crc_table".}

proc deflateInit(strm: var TZStream, level: int32): int32 = 
  result = deflateInitu(strm, level, zlibVersion(), sizeof(TZStream).cint)

proc inflateInit(strm: var TZStream): int32 = 
  result = inflateInitu(strm, zlibVersion(), sizeof(TZStream).cint)

proc deflateInit2(strm: var TZStream, 
                  level, `method`, windowBits, memLevel,
                  strategy: int32): int32 = 
  result = deflateInit2u(strm, level, `method`, windowBits, memLevel, 
                         strategy, zlibVersion(), sizeof(TZStream).cint)

proc inflateInit2(strm: var TZStream, windowBits: int32): int32 = 
  result = inflateInit2u(strm, windowBits, zlibVersion(), 
                         sizeof(TZStream).cint)

proc zlibAllocMem*(appData: pointer, items, size: int): pointer {.cdecl.} = 
  result = alloc(items * size)

proc zlibFreeMem*(appData, `block`: pointer) {.cdecl.} = 
  dealloc(`block`)

proc uncompress*(sourceBuf: cstring, sourceLen: int): string =
  ## Given a deflated cstring returns its inflated version.
  ##
  ## Passing a nil cstring will crash this proc in release mode and assert in
  ## debug mode.
  ##
  ## Returns nil on problems. Failure is a very loose concept, it could be you
  ## passing a non deflated string, or it could mean not having enough memory
  ## for the inflated version.
  ##
  ## The uncompression algorithm is based on
  ## http://stackoverflow.com/questions/17820664 but does ignore some of the
  ## original signed/unsigned checks, so may fail with big chunks of data
  ## exceeding the positive size of an int32. The algorithm can deal with
  ## concatenated deflated values properly.
  assert (not sourceBuf.isNil)

  var z: TZStream
  # Initialize input.
  z.nextIn = sourceBuf

  # Input left to decompress.
  var left = zlib.Uint(sourceLen)
  if left < 1:
    # Incomplete gzip stream, or overflow?
    return

  # Create starting space for output (guess double the input size, will grow if
  # needed -- in an extreme case, could end up needing more than 1000 times the
  # input size)
  var space = zlib.Uint(left shl 1)
  if space < left:
    space = left

  var decompressed = newStringOfCap(space)

  # Initialize output.
  z.nextOut = addr(decompressed[0])
  # Output generated so far.
  var have = 0

  # Set up for gzip decoding.
  z.availIn = 0;
  var status = inflateInit2(z, (15+16))
  if status != Z_OK:
    # Out of memory.
    return

  # Make sure memory allocated by inflateInit2() is freed eventually.
  defer: discard inflateEnd(z)

  # Decompress all of self.
  while true:
    # Allow for concatenated gzip streams (per RFC 1952).
    if status == Z_STREAM_END:
      discard inflateReset(z)

    # Provide input for inflate.
    if z.availIn == 0:
      # This only makes sense in the C version using unsigned values.
      z.availIn = left
      left -= z.availIn

    # Decompress the available input.
    while true:
      # Allocate more output space if none left.
      if space == have:
        # Double space, handle overflow.
        space = space shl 1
        if space < have:
          # Space was likely already maxed out.
          discard inflateEnd(z)
          return

        # Increase space.
        decompressed.setLen(space)
        # Update output pointer (might have moved).
        z.nextOut = addr(decompressed[have])

      # Provide output space for inflate.
      z.availOut = zlib.Uint(space - have)
      have += z.availOut;

      # Inflate and update the decompressed size.
      status = inflate(z, Z_SYNC_FLUSH);
      have -= z.availOut;

      # Bail out if any errors.
      if status != Z_OK and status != Z_BUF_ERROR and status != Z_STREAM_END:
        # Invalid gzip stream.
        discard inflateEnd(z)
        return

      # Repeat until all output is generated from provided input (note
      # that even if z.avail_in is zero, there may still be pending
      # output -- we're not done until the output buffer isn't filled)
      if z.availOut != 0:
        break
    # Continue until all input consumed.
    if left == 0 and z.availIn == 0:
      break

  # Verify that the input is a valid gzip stream.
  if status != Z_STREAM_END:
    # Incomplete gzip stream.
    return

  decompressed.setLen(have)
  swap(result, decompressed)


proc inflate*(buffer: var string): bool {.discardable.} =
  ## Convenience proc which inflates a string containing compressed data.
  ##
  ## Passing a nil string will crash this proc in release mode and assert in
  ## debug mode. It is ok to pass a buffer which doesn't contain deflated data,
  ## in this case the proc won't modify the buffer.
  ##
  ## Returns true if `buffer` was successfully inflated.
  assert (not buffer.isNil)
  if buffer.len < 1: return
  var temp = uncompress(addr(buffer[0]), buffer.len)
  if not temp.isNil:
    swap(buffer, temp)
    result = true

when isMainModule:
  echo zlibVersion()
