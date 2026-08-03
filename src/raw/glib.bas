' Raw FFI layer: GLib core (`glib-2.0`).

Extern "C" Lib "glib-2.0"
    Declare Function g_malloc(ByVal n_bytes AS ULONGINT) AS ANY PTR
    Declare Sub g_free(ByVal mem AS ANY PTR)

    ' Pumps the default main context once. `may_block` (0/-1) mirrors
    ' `gboolean`. Lets a `.bas` program drive GLib's event loop by hand
    ' (`DO ... LOOP` around a single iteration) without needing a
    ' callback-based `g_main_loop_run`/quit pair - useful until the M0
    ' function-pointer work lands and idiomatic signal handling exists.
    Declare Function g_main_context_iteration(ByVal context AS ANY PTR, ByVal may_block AS INTEGER) AS INTEGER
End Extern
