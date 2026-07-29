' Raw FFI layer: GtkApplication core (`gtk-4`).

#include once "gobject.bas"

' GApplicationFlags: 0 covers both G_APPLICATION_DEFAULT_FLAGS (current
' GLib) and the older G_APPLICATION_FLAGS_NONE alias it replaced.
CONST GTK4_APPLICATION_FLAGS_NONE = 0

Extern "C" Lib "gtk-4"
    Declare Function gtk_application_new(ByVal application_id AS ZSTRING, ByVal flags AS INTEGER) AS GObj PTR
    Declare Function gtk_application_window_new(ByVal application AS GObj PTR) AS GObj PTR
End Extern
