' Raw FFI layer: GtkProgressBar (`gtk-4`). Real GTK4's own value model
' is a plain 0.0-1.0 double fraction - no integer min/max/value concept
' at all, unlike Qt6/Haiku's own real progress-bar APIs.

#include once "gobject.bas"

Extern "C" Lib "gtk-4"
    Declare Function gtk_progress_bar_new() AS GObj PTR
    Declare Sub gtk_progress_bar_set_fraction(ByVal pbar AS GObj PTR, ByVal fraction AS DOUBLE)
    Declare Function gtk_progress_bar_get_fraction(ByVal pbar AS GObj PTR) AS DOUBLE
End Extern
