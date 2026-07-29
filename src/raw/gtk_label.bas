' Raw FFI layer: GtkLabel core (`gtk-4`).

#include once "gobject.bas"

Extern "C" Lib "gtk-4"
    Declare Function gtk_label_new(ByVal str AS ZSTRING) AS GObj PTR
    Declare Sub gtk_label_set_text(ByVal label AS GObj PTR, ByVal str AS ZSTRING)
    Declare Function gtk_label_get_text(ByVal label AS GObj PTR) AS ZSTRING
End Extern
