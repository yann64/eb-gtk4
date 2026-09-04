' Raw FFI layer: GApplication core (`gio-2.0`).
'
' `GtkApplication` is a `GApplication` subclass - GApplication's own
' run-loop entry point is what actually drives a GTK4 app.

#include once "gobject.bas"

Extern "C" Lib "gio-2.0"
    ' Runs the application's main loop until it exits. `argv` is `ANY
    ' PTR` so callers can pass a literal 0 for the common "no CLI args"
    ' case (`g_application_run(app, 0, 0)`).
    Declare Function g_application_run(ByVal application AS GObj PTR, ByVal argc AS INTEGER, ByVal argv AS ANY PTR) AS INTEGER
    ' Stops a running g_application_run loop (safe to call from within
    ' any signal handler, including one connected to the application
    ' itself).
    Declare Sub g_application_quit(ByVal application AS GObj PTR)
End Extern
