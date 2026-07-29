' Raw FFI layer: GtkButton core (`gtk-4`).

#include once "gobject.bas"

Extern "C" Lib "gtk-4"
    Declare Function gtk_button_new() AS GObj PTR
    Declare Function gtk_button_new_with_label(ByVal label AS ZSTRING) AS GObj PTR
    Declare Sub gtk_button_set_label(ByVal button AS GObj PTR, ByVal label AS ZSTRING)
    Declare Function gtk_button_get_label(ByVal button AS GObj PTR) AS ZSTRING
End Extern
