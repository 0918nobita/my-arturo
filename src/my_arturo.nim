#[
Arturo

MIT License

Copyright (c) 2019-2020 Yanis Zafirópulos (aka Dr.Kameleon)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]#

import parseopt, system, tables, unicode
import bignum

# entrypoint (arturo.nim)
# - bootup template (arturo.nim)
# - doExec proc (vm/exec.nim)
#   - Translation type (vm/bytecode.nim)
#     - ValueArray, ByteArray type (vm/value.nim)
#       - Value type (vm/value.nim)
#         - Int type (@bignum)
#   - ValueDict type (vm/value.nim)
#   - Opcode type (vm/bytecode.nim)
#   - Add template (vm/library/Artihmetic.nim)
#     - stack.push template (vm/stack.nim) -> stackPush proc
#       - Stack global variable (vm/stack.nim) -> stack global variable
#       - SP global variable (vm/stack.nim) -> sp global variable
#     - require template (vm/exec.nim)
#       - OpSpecs constant (vm/bytecode.nim)
#         - OpSpec type (vm/bytecode.nim)
#       - panic template (vm/exec.nim)
#         - vmPanic global variable (vm/exec.nim)
#         - vmError global variable (vm/exec.nim)

type ValueKind {.pure.} = enum
    Null = 0
    # Boolean  = 1
    Integer = 2
    # Floating = 3
    # Type     = 4
    Char = 5
    # String   = 6
    # Word     = 7
    # Literal  = 8
    Any = 21

type IntegerKind {.pure.} = enum
    Normal
    BigInt

type Value {.acyclic.} = ref object
    case kind: ValueKind:
        of Null, Any: discard
        # of Boolean: b: bool
        of Integer:
            case iKind: IntegerKind:
                of IntegerKind.Normal: i: int
                of IntegerKind.BigInt: bi: Int
        # of Floating: f: float
        # of Type:     t: ValueKind
        of Char: c: Rune
        # of String,
        #    Word,
        #    Literal:  s: string

type ValueArray = seq[Value]

type ValueDict = OrderedTable[string, Value]

type ByteArray = seq[byte]

type Translation = (ValueArray, ByteArray)

# VM 命令
type Opcode = enum
    opAdd = 0x50

type ParamSpec = set[ValueKind]

# VM 命令の仕様の形式
type OpSpec = object
    name: string
    args: int
    a, b, c: ParamSpec

# VM 命令の仕様一覧
const OpSpecs = [
    opAdd: OpSpec(name: "add", args: 2)
]

var stack {.threadvar.}: seq[Value] # スタックの実体
var sp: int # スタックポインタ

proc stackPush(v: Value) =
    stack[sp] = v
    sp += 1

var vmPanic = false
var vmError = false

# VM の異常終了
template panic(msg: string): untyped =
    vmPanic = true
    vmError = msg
    return

# 写経途中
template require(op: OpCode): untyped =
    if SP < (static OpSpecs[op].args):
        panic "cannot perform"

    when (static OpSpecs[op].args) >= 1:
        when (static OpSpecs[op].a) != {ANY}:
            if not (Stack[SP-1].kind in (static OpSpecs[op].a)):
                let acceptStr = toSeq((OpSpecs[op].a).items).map(proc(
                        x: ValueKind): string = ":" & ($(x)).toLowerAscii()).join(" ")
                panic "cannot perform '" & (static OpSpecs[op].name) &
                        "' -> :" & ($(Stack[SP-1].kind)).toLowerAscii() &
                        "...; incorrect argument type for 1st parameter; accepts " & acceptsStr

# template Add(): untyped =
#     require(opAdd)
#     if x.kind == Literal: # x って何？？
#         syms[x.s] += y
#     else:
#         stackPush(x + y)

# 写経途中
proc doExec(input: Translation, depth: int = 0, withSyms: ptr ValueDict = nil) =
    let cnst = input[0]
    let it = input[1]
    var i = 0
    var op: Opcode
    var syms: ValueDict
    if withSyms != nil:
        syms = withSyms[]
    else:
        syms = initOrderedTable[string, Value]()
    var oldSyms = syms # ??
    while true:
        op = (Opcode)(it[i])
        # case op:
        #     of opAdd: Add()

func box [A](a: A): ref A =
    new(result)
    result[] = a

# エントリーポイント
when isMainModule:
    var token = initOptParser()

    token.next()

    case token.kind:
        of cmdArgument:
            echo token.key
        else:
            discard
