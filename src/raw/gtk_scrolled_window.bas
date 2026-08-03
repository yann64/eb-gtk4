' Raw FFI layer: GtkScrolledWindow core (`gtk-4`).

#include once "gobject.bas"

Extern "C" Lib "gtk-4"
    Declare Function gtk_scrolled_window_new() AS GObj PTR
    Declare Sub gtk_scrolled_window_set_child(ByVal scrolled_window AS GObj PTR, ByVal child AS GObj PTR)
End Extern
