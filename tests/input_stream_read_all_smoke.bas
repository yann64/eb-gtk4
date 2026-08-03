' Smoke test: the blocking InputStreamReadAll (subprocess.bas) - fixed-
' byte-count reads, the shape ebasic-editor's LSP client needs for a
' Content-Length-framed JSON-RPC body (which may contain embedded
' newlines, so line-based DataInputStreamReadLine doesn't fit). Spawns
' `printf` with no trailing newline, reads exactly 10 of its 10 bytes.

#include once "../src/lib.bas"

DIM launcher AS SubprocessLauncher
launcher = NewSubprocessLauncher(G_SUBPROCESS_FLAGS_STDOUT_PIPE)

DIM argv(2) AS ZSTRING
argv(0) = "printf"
argv(1) = "hello12345"

DIM sp AS Subprocess
sp = SubprocessLauncherSpawnv(launcher, @argv(0))
PRINT sp.handle <> 0

DIM outPipe AS InputStream
outPipe = SubprocessGetStdoutPipe(sp)

DIM buf AS ANY PTR
buf = g_malloc(11)
DIM bytesRead AS INTEGER
DIM ok AS INTEGER
ok = InputStreamReadAll(outPipe, buf, 10, bytesRead)
PRINT ok
PRINT bytesRead

DIM viaZstring AS ZSTRING
viaZstring = buf
DIM text AS STRING
text = viaZstring
PRINT text

CALL g_free(buf)
CALL SubprocessWait(sp)
PRINT "input stream read all smoke ok"
