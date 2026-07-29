' Raw FFI layer: GApplication core (`gio-2.0`).
'
' `GtkApplication` is a `GApplication` subclass - GApplication's own
' run-loop entry point is what actually drives a GTK4 app.

#include once "gobject.bas"

Extern "C" Lib "gio-2.0"
    ' Runs the application's main loop until it exits. `argv` is `ANY
    ' PTR` so callers can pass a literal 0 for the common "no CLI args"
    ' case (`g_application_run(app, 0, 0)`).
    Declare Function g_application_run(ByVal application AS ANY PTR, ByVal argc AS INTEGER, ByVal argv AS ANY PTR) AS INTEGER
End Extern
