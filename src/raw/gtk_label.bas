' Raw FFI layer: GtkLabel core (`gtk-4`).

#include once "gobject.bas"

Extern "C" Lib "gtk-4"
    Declare Function gtk_label_new(ByVal str AS ZSTRING) AS ANY PTR
    Declare Sub gtk_label_set_text(ByVal label AS ANY PTR, ByVal str AS ZSTRING)
    Declare Function gtk_label_get_text(ByVal label AS ANY PTR) AS ZSTRING
End Extern
