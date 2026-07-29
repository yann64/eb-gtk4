' Raw FFI layer: GtkGrid core (`gtk-4`).

#include once "gobject.bas"

Extern "C" Lib "gtk-4"
    Declare Function gtk_grid_new() AS GObj PTR
    Declare Sub gtk_grid_attach(ByVal grid AS GObj PTR, ByVal child AS GObj PTR, ByVal column AS INTEGER, ByVal row AS INTEGER, ByVal width AS INTEGER, ByVal height AS INTEGER)
End Extern
