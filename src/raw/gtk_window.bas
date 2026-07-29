' Raw FFI layer: GtkWindow core (`gtk-4`).

#include once "gobject.bas"

Extern "C" Lib "gtk-4"
    Declare Function gtk_window_new() AS ANY PTR
    Declare Sub gtk_window_set_title(ByVal window AS ANY PTR, ByVal title AS ZSTRING)
    Declare Sub gtk_window_set_default_size(ByVal window AS ANY PTR, ByVal width AS INTEGER, ByVal height AS INTEGER)
    Declare Sub gtk_window_set_child(ByVal window AS ANY PTR, ByVal child AS ANY PTR)
    Declare Sub gtk_window_present(ByVal window AS ANY PTR)
    Declare Sub gtk_window_destroy(ByVal window AS ANY PTR)
End Extern
