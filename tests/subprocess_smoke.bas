' Smoke test: exercises GSubprocess end to end - display-independent (pure
' GIO, no GTK dependency at all), so this runs safely under `ebpm test`.
' Spawns a real child process (`echo`), reads its output line by line
' (blocking - fine for this short-lived command), and checks its exit
' status - exactly the "one-shot subprocess" shape `ebpm`/`git`
' integration will use.

#include once "../src/lib.bas"

DIM launcher AS SubprocessLauncher
launcher = NewSubprocessLauncher(G_SUBPROCESS_FLAGS_STDOUT_PIPE)

DIM argv(3) AS ZSTRING
argv(0) = "echo"
argv(1) = "hello"
argv(2) = "world"
' argv(3) stays unassigned (nullptr) - the argv NUL terminator.

DIM sp AS Subprocess
sp = SubprocessLauncherSpawnv(launcher, @argv(0))
PRINT sp.handle <> 0

DIM outPipe AS InputStream
outPipe = SubprocessGetStdoutPipe(sp)
DIM lineReader AS DataInputStream
lineReader = NewDataInputStream(outPipe)

DIM gotLine AS INTEGER
DIM rawLine AS ANY PTR
rawLine = DataInputStreamReadLine(lineReader, gotLine)
PRINT gotLine
DIM viaZstring AS ZSTRING
viaZstring = rawLine
DIM line AS STRING
line = viaZstring
CALL FreeGMallocString(rawLine)
PRINT line

rawLine = DataInputStreamReadLine(lineReader, gotLine)
PRINT gotLine

CALL SubprocessWait(sp)
PRINT SubprocessGetSuccessful(sp)
PRINT SubprocessGetExitStatus(sp)

CALL ObjDestroy(lineReader)
CALL ObjDestroy(sp)
CALL ObjDestroy(launcher)

PRINT "subprocess smoke ok"
