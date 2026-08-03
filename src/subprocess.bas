' Idiomatic layer: GSubprocess/GSubprocessLauncher + GInputStream/
' GOutputStream/GDataInputStream. The one subprocess primitive this whole
' package exposes - spawning `ebasic_lsp`, `ebpm`, or `git` all go through
' this same API. See raw/gsubprocess.bas for the real GIO functions and
' the argv-construction convention every caller should follow.

#include once "widget.bas"
#include once "raw/glib.bas"
#include once "raw/gsubprocess.bas"

TYPE SubprocessLauncher EXTENDS Obj
END TYPE

TYPE Subprocess EXTENDS Obj
END TYPE

''' A GInputStream (a subprocess's stdout/stderr pipe, or the base stream
''' a DataInputStream reads lines from).
TYPE InputStream EXTENDS Obj
END TYPE

''' A GOutputStream (a subprocess's stdin pipe).
TYPE OutputStream EXTENDS Obj
END TYPE

''' A line-buffering wrapper over an InputStream - see
''' DataInputStreamReadLineAsync/Finish. A real GInputStream subclass, so
''' every InputStream-taking function also accepts one directly (e.g. to
''' close it via InputStreamClose).
TYPE DataInputStream EXTENDS InputStream
END TYPE

''' Creates a launcher configured with `flags` (see GSubprocess constants
''' in raw/gsubprocess.bas) - e.g.
''' `G_SUBPROCESS_FLAGS_STDIN_PIPE OR G_SUBPROCESS_FLAGS_STDOUT_PIPE OR
''' G_SUBPROCESS_FLAGS_STDERR_PIPE` for a fully piped child process like
''' `ebasic_lsp`.
FUNCTION NewSubprocessLauncher(flags AS INTEGER) AS SubprocessLauncher
    DIM l AS SubprocessLauncher
    l.handle = SinkHandle(g_subprocess_launcher_new(flags))
    NewSubprocessLauncher = l
END FUNCTION

''' Sets the child process's working directory.
SUB SubprocessLauncherSetCwd(launcher AS SubprocessLauncher, cwd AS ZSTRING)
    CALL g_subprocess_launcher_set_cwd(launcher.handle, cwd)
END SUB

''' Sets (or overwrites) an environment variable for the child process.
SUB SubprocessLauncherSetEnv(launcher AS SubprocessLauncher, variableName AS ZSTRING, value AS ZSTRING, overwrite AS INTEGER)
    CALL g_subprocess_launcher_setenv(launcher.handle, variableName, value, overwrite)
END SUB

''' Spawns the child process named by `argvFirst` - the address of the
''' first element of a caller-built, NUL-terminated ZSTRING array (see
''' raw/gsubprocess.bas's own doc comment: `DIM argv(n) AS ZSTRING`, fill
''' in `argv(0)`..`argv(n-1)`, leave `argv(n)` unassigned as the
''' terminator, pass `@argv(0)`). The result's `.handle` is 0 if spawning
''' failed (e.g. the program doesn't exist) - no detailed error is
''' surfaced (a deliberate scope cut).
FUNCTION SubprocessLauncherSpawnv(launcher AS SubprocessLauncher, argvFirst AS ANY PTR) AS Subprocess
    DIM sp AS Subprocess
    sp.handle = g_subprocess_launcher_spawnv(launcher.handle, argvFirst, 0)
    SubprocessLauncherSpawnv = sp
END FUNCTION

''' The child's stdin, as a stream to write to - only valid if the
''' launcher was created with G_SUBPROCESS_FLAGS_STDIN_PIPE.
FUNCTION SubprocessGetStdinPipe(sp AS Subprocess) AS OutputStream
    DIM s AS OutputStream
    s.handle = g_subprocess_get_stdin_pipe(sp.handle)
    SubprocessGetStdinPipe = s
END FUNCTION

''' The child's stdout, as a stream to read from - only valid with
''' G_SUBPROCESS_FLAGS_STDOUT_PIPE.
FUNCTION SubprocessGetStdoutPipe(sp AS Subprocess) AS InputStream
    DIM s AS InputStream
    s.handle = g_subprocess_get_stdout_pipe(sp.handle)
    SubprocessGetStdoutPipe = s
END FUNCTION

''' The child's stderr, as a stream to read from - only valid with
''' G_SUBPROCESS_FLAGS_STDERR_PIPE.
FUNCTION SubprocessGetStderrPipe(sp AS Subprocess) AS InputStream
    DIM s AS InputStream
    s.handle = g_subprocess_get_stderr_pipe(sp.handle)
    SubprocessGetStderrPipe = s
END FUNCTION

''' Blocks until the child process exits - fine for a short-lived,
''' run-to-completion child (`ebpm build`, a `git` subcommand); use
''' SubprocessWaitAsync for a long-lived one (`ebasic_lsp`) so the GTK
''' main loop isn't frozen waiting on it. Returns whether the wait itself
''' succeeded (not whether the child's own exit code was 0 - see
''' SubprocessGetSuccessful/GetExitStatus for that).
FUNCTION SubprocessWait(sp AS Subprocess) AS INTEGER
    SubprocessWait = g_subprocess_wait(sp.handle, 0, 0)
END FUNCTION

''' Starts an async wait - `callback` receives (source AS GObj PTR, res AS
''' ANY PTR, data AS ANY PTR); call SubprocessWaitFinish(sp, res) from
''' inside it.
SUB SubprocessWaitAsync(sp AS Subprocess, callback AS ANY PTR, data AS ANY PTR)
    CALL g_subprocess_wait_async(sp.handle, 0, callback, data)
END SUB

''' Completes an async wait started by SubprocessWaitAsync.
FUNCTION SubprocessWaitFinish(sp AS Subprocess, res AS ANY PTR) AS INTEGER
    SubprocessWaitFinish = g_subprocess_wait_finish(sp.handle, res, 0)
END FUNCTION

''' The child's exit code - only meaningful after a successful wait.
FUNCTION SubprocessGetExitStatus(sp AS Subprocess) AS INTEGER
    SubprocessGetExitStatus = g_subprocess_get_exit_status(sp.handle)
END FUNCTION

''' Whether the child exited normally with status 0 - only meaningful
''' after a successful wait.
FUNCTION SubprocessGetSuccessful(sp AS Subprocess) AS INTEGER
    SubprocessGetSuccessful = g_subprocess_get_successful(sp.handle)
END FUNCTION

''' Sends a POSIX signal to the child (e.g. SIGTERM = 15).
SUB SubprocessSendSignal(sp AS Subprocess, signalNum AS INTEGER)
    CALL g_subprocess_send_signal(sp.handle, signalNum)
END SUB

''' Forcibly terminates the child immediately (SIGKILL on Unix).
SUB SubprocessForceExit(sp AS Subprocess)
    CALL g_subprocess_force_exit(sp.handle)
END SUB

''' Wraps a stream (e.g. SubprocessGetStdoutPipe's result) for line-based
''' reading - the natural shape for ebasic_lsp's Content-Length *header*
''' lines, and for ebpm/git's own line-oriented output.
FUNCTION NewDataInputStream(baseStream AS InputStream) AS DataInputStream
    DIM s AS DataInputStream
    s.handle = SinkHandle(g_data_input_stream_new(baseStream.handle))
    NewDataInputStream = s
END FUNCTION

''' Starts an async read of the next line - `callback` receives (source
''' AS GObj PTR, res AS ANY PTR, data AS ANY PTR); call
''' DataInputStreamReadLineFinish(stream, res) from inside it.
SUB DataInputStreamReadLineAsync(stream AS DataInputStream, callback AS ANY PTR, data AS ANY PTR)
    CALL g_data_input_stream_read_line_async(stream.handle, G_PRIORITY_DEFAULT, 0, callback, data)
END SUB

''' Completes an async line read - sets `gotLine` to 0 on EOF/error (with
''' `""` returned) or 1 with the line's real text (never including its own
''' trailing newline).
FUNCTION DataInputStreamReadLineFinish(stream AS DataInputStream, res AS ANY PTR, BYREF gotLine AS INTEGER) AS STRING
    DIM rawPtr AS ANY PTR
    rawPtr = g_data_input_stream_read_line_finish(stream.handle, res, 0, 0)
    IF rawPtr = 0 THEN
        gotLine = 0
        DataInputStreamReadLineFinish = ""
    ELSE
        gotLine = 1
        DIM viaZstring AS ZSTRING
        viaZstring = rawPtr
        DIM result AS STRING
        result = viaZstring
        CALL g_free(rawPtr)
        DataInputStreamReadLineFinish = result
    END IF
END FUNCTION

''' The blocking counterpart of DataInputStreamReadLineAsync/Finish - see
''' raw/gsubprocess.bas's own doc comment on when blocking is acceptable.
''' Same `gotLine`/return convention as DataInputStreamReadLineFinish.
FUNCTION DataInputStreamReadLine(stream AS DataInputStream, BYREF gotLine AS INTEGER) AS STRING
    DIM rawPtr AS ANY PTR
    rawPtr = g_data_input_stream_read_line(stream.handle, 0, 0, 0)
    IF rawPtr = 0 THEN
        gotLine = 0
        DataInputStreamReadLine = ""
    ELSE
        gotLine = 1
        DIM viaZstring AS ZSTRING
        viaZstring = rawPtr
        DIM result AS STRING
        result = viaZstring
        CALL g_free(rawPtr)
        DataInputStreamReadLine = result
    END IF
END FUNCTION

''' Starts an async read of exactly `count` bytes into a caller-allocated
''' `buffer` (e.g. `g_malloc(count)`) - the natural shape for
''' ebasic_lsp's Content-Length *body* (a fixed byte count, not
''' necessarily line-terminated - a JSON payload may contain embedded
''' newlines). The caller owns `buffer`'s lifetime (must outlive the
''' async operation, and must still be freed afterward) - matching this
''' package's existing "you manage what you allocate" convention (see
''' NewIter/FreeIter), not hidden behind this call.
SUB InputStreamReadAllAsync(stream AS InputStream, buffer AS ANY PTR, count AS INTEGER, callback AS ANY PTR, data AS ANY PTR)
    CALL g_input_stream_read_all_async(stream.handle, buffer, count, G_PRIORITY_DEFAULT, 0, callback, data)
END SUB

''' Completes an async fixed-count read - `bytesRead` receives how many
''' bytes actually landed in the buffer passed to
''' InputStreamReadAllAsync; the return value is whether the read
''' succeeded at all (a short read before EOF is still "successful" with
''' `bytesRead` less than requested - check it).
FUNCTION InputStreamReadAllFinish(stream AS InputStream, res AS ANY PTR, BYREF bytesRead AS INTEGER) AS INTEGER
    DIM countSlot AS ANY PTR
    countSlot = g_malloc(8)
    DIM ok AS INTEGER
    ok = g_input_stream_read_all_finish(stream.handle, res, countSlot, 0)
    DIM countPtr AS ULONGINT PTR
    countPtr = countSlot
    bytesRead = *countPtr
    CALL g_free(countSlot)
    InputStreamReadAllFinish = ok
END FUNCTION

''' Closes an input stream (a subprocess's stdout/stderr pipe, or a
''' DataInputStream wrapping one).
SUB InputStreamClose(stream AS InputStream)
    CALL g_input_stream_close(stream.handle, 0, 0)
END SUB

''' Writes `text` in full (blocking) - fine for the typically-small,
''' one-shot messages this package's own use cases send (a single
''' JSON-RPC request, matching the plan's own "synchronous write" scope
''' cut). Returns whether the write succeeded.
FUNCTION OutputStreamWriteAll(stream AS OutputStream, text AS ZSTRING) AS INTEGER
    OutputStreamWriteAll = g_output_stream_write_all(stream.handle, text, strlen(text), 0, 0, 0)
END FUNCTION

''' Closes an output stream (a subprocess's stdin pipe) - e.g. to signal
''' EOF to a child that reads until its stdin closes.
SUB OutputStreamClose(stream AS OutputStream)
    CALL g_output_stream_close(stream.handle, 0, 0)
END SUB
