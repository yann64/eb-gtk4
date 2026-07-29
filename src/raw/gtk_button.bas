' Raw FFI layer: GtkButton core (`gtk-4`).

#include once "gobject.bas"

Extern "C" Lib "gtk-4"
    Declare Function gtk_button_new() AS ANY PTR
    Declare Function gtk_button_new_with_label(ByVal label AS ZSTRING) AS ANY PTR
    Declare Sub gtk_button_set_label(ByVal button AS ANY PTR, ByVal label AS ZSTRING)
    Declare Function gtk_button_get_label(ByVal button AS ANY PTR) AS ZSTRING
End Extern
