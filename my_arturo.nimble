# Package

version       = "0.1.0"
author        = "0918nobita"
description   = "The Arturo programming language"
license       = "MIT"
srcDir        = "src"
bin           = @["my_arturo"]

task pretty, "format code":
    exec "nim c -r --outdir:bin/util src/util/format.nim"

# Dependencies

requires "nim >= 1.4.0"
requires "bignum 1.0.4"
