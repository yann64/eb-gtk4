' Raw FFI layer: GtkBox core (`gtk-4`).

#include once "gobject.bas"

Extern "C" Lib "gtk-4"
    Declare Function gtk_box_new(ByVal orientation AS INTEGER, ByVal spacing AS INTEGER) AS ANY PTR
    Declare Sub gtk_box_append(ByVal box AS ANY PTR, ByVal child AS ANY PTR)
    Declare Sub gtk_box_remove(ByVal box AS ANY PTR, ByVal child AS ANY PTR)
    Declare Sub gtk_box_set_spacing(ByVal box AS ANY PTR, ByVal spacing AS INTEGER)
End Extern
