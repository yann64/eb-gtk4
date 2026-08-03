' Raw FFI layer: GSubprocess/GSubprocessLauncher + GInputStream/
' GOutputStream/GDataInputStream core (`gio-2.0`, already linked - see
' gio.bas). This is the *one* subprocess primitive this package exposes,
' reused identically for spawning `ebasic_lsp`, `ebpm`, and `git` -
' GSubprocess is portable (Linux/macOS/Windows) and integrates natively
' with GLib's own main loop for async, non-blocking I/O (crucial: a
' synchronous blocking read here would freeze the whole GTK UI while
' waiting on a child process). Symbol names verified directly against a
' real installed libgio-2.0.so (`nm -D`), matching this package's own
' established discipline for less-obvious APIs.
'
' A NULL-terminated argv for g_subprocess_launcher_spawnv is built from an
' eBasic array of ZSTRING: `DIM argv(n) AS ZSTRING` value-initializes
' every slot to a real null pointer (Codegen emits `std::vector<const
' char*> argv(n+1);`, which value-constructs every element - confirmed by
' direct compile+run test), so leaving the *last* slot unassigned and
' passing `@argv(0)` (std::vector's storage is guaranteed contiguous, so
' this is a genuine, valid C array address) gives a real, correctly
' NUL-terminated `char**` with zero further language features needed.

#include once "gobject.bas"

' GSubprocessFlags (docs.gtk.org).
CONST G_SUBPROCESS_FLAGS_NONE = 0
CONST G_SUBPROCESS_FLAGS_STDIN_PIPE = 1
CONST G_SUBPROCESS_FLAGS_STDIN_INHERIT = 2
CONST G_SUBPROCESS_FLAGS_STDOUT_PIPE = 4
CONST G_SUBPROCESS_FLAGS_STDOUT_SILENCE = 8
CONST G_SUBPROCESS_FLAGS_STDERR_PIPE = 16
CONST G_SUBPROCESS_FLAGS_STDERR_SILENCE = 32
CONST G_SUBPROCESS_FLAGS_STDERR_MERGE = 64
CONST G_SUBPROCESS_FLAGS_INHERIT_FDS = 128

' GAsyncReadyCallback's `io_priority` convention - the default/normal
' priority most callers want.
CONST G_PRIORITY_DEFAULT = 0

Extern "C" Lib "gio-2.0"
    Declare Function g_subprocess_launcher_new(ByVal flags AS INTEGER) AS GObj PTR
    Declare Sub g_subprocess_launcher_set_cwd(ByVal launcher AS GObj PTR, ByVal cwd AS ZSTRING)
    Declare Sub g_subprocess_launcher_setenv(ByVal launcher AS GObj PTR, ByVal variable AS ZSTRING, ByVal value AS ZSTRING, ByVal overwrite AS INTEGER)
    ' `error` is always passed 0/NULL here (a deliberate scope cut - no
    ' detailed GError propagation yet) - a NULL return means spawn failed.
    Declare Function g_subprocess_launcher_spawnv(ByVal launcher AS GObj PTR, ByVal argv AS ANY PTR, ByVal error AS ANY PTR) AS GObj PTR

    Declare Function g_subprocess_get_stdin_pipe(ByVal subprocess AS GObj PTR) AS GObj PTR
    Declare Function g_subprocess_get_stdout_pipe(ByVal subprocess AS GObj PTR) AS GObj PTR
    Declare Function g_subprocess_get_stderr_pipe(ByVal subprocess AS GObj PTR) AS GObj PTR
    Declare Function g_subprocess_wait(ByVal subprocess AS GObj PTR, ByVal cancellable AS ANY PTR, ByVal error AS ANY PTR) AS INTEGER
    Declare Sub g_subprocess_wait_async(ByVal subprocess AS GObj PTR, ByVal cancellable AS ANY PTR, ByVal callback AS ANY PTR, ByVal user_data AS ANY PTR)
    Declare Function g_subprocess_wait_finish(ByVal subprocess AS GObj PTR, ByVal res AS ANY PTR, ByVal error AS ANY PTR) AS INTEGER
    Declare Function g_subprocess_get_exit_status(ByVal subprocess AS GObj PTR) AS INTEGER
    Declare Function g_subprocess_get_successful(ByVal subprocess AS GObj PTR) AS INTEGER
    Declare Sub g_subprocess_send_signal(ByVal subprocess AS GObj PTR, ByVal signal_num AS INTEGER)
    Declare Sub g_subprocess_force_exit(ByVal subprocess AS GObj PTR)

    Declare Function g_data_input_stream_new(ByVal base_stream AS GObj PTR) AS GObj PTR
    ' The blocking counterpart of read_line_async/finish below - fine for
    ' a short-lived, one-shot child process (`ebpm`/`git`) where blocking
    ' briefly is acceptable; a long-lived one (`ebasic_lsp`) should use
    ' the async pair instead so the GTK main loop isn't frozen.
    Declare Function g_data_input_stream_read_line(ByVal stream AS GObj PTR, ByVal length AS ANY PTR, ByVal cancellable AS ANY PTR, ByVal error AS ANY PTR) AS ANY PTR
    Declare Sub g_data_input_stream_read_line_async(ByVal stream AS GObj PTR, ByVal io_priority AS INTEGER, ByVal cancellable AS ANY PTR, ByVal callback AS ANY PTR, ByVal user_data AS ANY PTR)
    ' `length` (bytes read, excluding the NUL) and `error` are always 0/
    ' NULL here - EOF and a genuine zero-length line are distinguished by
    ' the idiomatic layer checking the raw return for NULL *before*
    ' bridging it to ZSTRING (see text.bas's own ANY-PTR-as-ZSTRING
    ' pattern), not by inspecting `length`.
    Declare Function g_data_input_stream_read_line_finish(ByVal stream AS GObj PTR, ByVal res AS ANY PTR, ByVal length AS ANY PTR, ByVal error AS ANY PTR) AS ANY PTR

    Declare Sub g_input_stream_read_all_async(ByVal stream AS GObj PTR, ByVal buffer AS ANY PTR, ByVal count AS ULONGINT, ByVal io_priority AS INTEGER, ByVal cancellable AS ANY PTR, ByVal callback AS ANY PTR, ByVal user_data AS ANY PTR)
    ' `bytes_read` is a caller-allocated ULONGINT-sized out-slot (see
    ' idiomatic layer) - `error` is always 0/NULL.
    Declare Function g_input_stream_read_all_finish(ByVal stream AS GObj PTR, ByVal res AS ANY PTR, ByVal bytes_read AS ANY PTR, ByVal error AS ANY PTR) AS INTEGER

    Declare Function g_output_stream_write_all(ByVal stream AS GObj PTR, ByVal buffer AS ZSTRING, ByVal count AS ULONGINT, ByVal bytes_written AS ANY PTR, ByVal cancellable AS ANY PTR, ByVal error AS ANY PTR) AS INTEGER
    Declare Function g_output_stream_close(ByVal stream AS GObj PTR, ByVal cancellable AS ANY PTR, ByVal error AS ANY PTR) AS INTEGER
    Declare Function g_input_stream_close(ByVal stream AS GObj PTR, ByVal cancellable AS ANY PTR, ByVal error AS ANY PTR) AS INTEGER
End Extern

' `strlen` (libc) - needed to compute a ZSTRING's byte length for
' g_output_stream_write_all's `count` parameter; no built-in LEN()-style
' string function exists in eBasic yet.
Declare Function strlen Lib "c" (ByVal s AS ZSTRING) AS ULONGINT
