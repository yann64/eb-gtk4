' Raw FFI layer: GtkPaned core (`gtk-4`).

#include once "gobject.bas"

Extern "C" Lib "gtk-4"
    Declare Function gtk_paned_new(ByVal orientation AS INTEGER) AS GObj PTR
    Declare Sub gtk_paned_set_start_child(ByVal paned AS GObj PTR, ByVal child AS GObj PTR)
    Declare Sub gtk_paned_set_end_child(ByVal paned AS GObj PTR, ByVal child AS GObj PTR)
    Declare Sub gtk_paned_set_position(ByVal paned AS GObj PTR, ByVal position AS INTEGER)
    Declare Sub gtk_paned_set_wide_handle(ByVal paned AS GObj PTR, ByVal wide AS INTEGER)
End Extern
