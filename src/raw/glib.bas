' Raw FFI layer: GLib core (`glib-2.0`).

Extern "C" Lib "glib-2.0"
    Declare Function g_malloc(ByVal n_bytes AS ULONGINT) AS ANY PTR
    ' Zero-initialized allocation - needed for GValue (G_VALUE_INIT's real
    ' C macro is a zeroed-struct literal; g_value_init on non-zeroed
    ' memory is undefined behavior), see raw/gobject.bas.
    Declare Function g_malloc0(ByVal n_bytes AS ULONGINT) AS ANY PTR
    Declare Sub g_free(ByVal mem AS ANY PTR)

    ' Pumps the default main context once. `may_block` (0/-1) mirrors
    ' `gboolean`. Lets a `.bas` program drive GLib's event loop by hand
    ' (`DO ... LOOP` around a single iteration) without needing a
    ' callback-based `g_main_loop_run`/quit pair - useful until the M0
    ' function-pointer work lands and idiomatic signal handling exists.
    Declare Function g_main_context_iteration(ByVal context AS ANY PTR, ByVal may_block AS INTEGER) AS INTEGER

    ' `contents` is an out-param: a caller-allocated ANY PTR PTR slot that
    ' receives a newly `g_malloc`'d buffer's address (the file's full,
    ' NUL-terminated content) - read it back via eBasic's own `ANY PTR
    ' PTR` dereference (verified directly: a real `void**` out-param
    ' works correctly with no new compiler features needed), then free it
    ' via g_free once done, same as any other g_malloc'd string here.
    ' `length`/`error` are always 0/NULL (deliberate scope cuts).
    Declare Function g_file_get_contents(ByVal filename AS ZSTRING, ByVal contents AS ANY PTR, ByVal length AS ANY PTR, ByVal error AS ANY PTR) AS INTEGER
    ' `length` = -1 means `contents` is a plain NUL-terminated ZSTRING
    ' (its own length computed via strlen internally) - the common case.
    Declare Function g_file_set_contents(ByVal filename AS ZSTRING, ByVal contents AS ZSTRING, ByVal length AS LONGINT, ByVal error AS ANY PTR) AS INTEGER
End Extern
