import os, osproc, strutils

proc execPretty(startDir: string) =
    for f in walkDirRec(dir = startDir, yieldFilter = {pcFile}):
        if f.endsWith(".nim"):
            let process = startProcess(
                "nimpretty",
                startDir,
                @["--backup:on", "--indent:4", f],
                env = nil,
                options = {poUsePath, poStdErrToStdout})
            echo f
            discard process.waitForExit()

when isMainModule:
    let
        cmdArgs = os.commandLineParams()
        targetDir =
            if cmdArgs.len == 1:
                os.expandFilename(cmdArgs[0])
            else:
                os.expandFilename("./src")
    echo targetDir
    execPretty(targetDir)
