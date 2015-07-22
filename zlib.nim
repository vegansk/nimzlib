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

proc zlibVersion: cstring {.importc: "zlibVersion", header: ZlibHeader, cdecl.}

when isMainModule:
  echo zlibVersion()
