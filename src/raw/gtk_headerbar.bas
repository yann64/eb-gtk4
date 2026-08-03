' Raw FFI layer: GtkHeaderBar core (`gtk-4`).

#include once "gobject.bas"

Extern "C" Lib "gtk-4"
    Declare Function gtk_header_bar_new() AS GObj PTR
    Declare Sub gtk_header_bar_pack_start(ByVal bar AS GObj PTR, ByVal child AS GObj PTR)
    Declare Sub gtk_header_bar_pack_end(ByVal bar AS GObj PTR, ByVal child AS GObj PTR)
    Declare Sub gtk_header_bar_set_show_title_buttons(ByVal bar AS GObj PTR, ByVal setting AS INTEGER)
    ' GTK4 has no plain-string title setter - a title is any widget (see
    ' idiomatic HeaderBarSetTitle, which wraps a GtkLabel for the common case).
    Declare Sub gtk_header_bar_set_title_widget(ByVal bar AS GObj PTR, ByVal title_widget AS GObj PTR)
End Extern
