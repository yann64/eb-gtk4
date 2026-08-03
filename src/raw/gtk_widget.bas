' Raw FFI layer: GtkWidget core (`gtk-4`).

#include once "gobject.bas"

Extern "C" Lib "gtk-4"
    Declare Sub gtk_widget_show(ByVal widget AS GObj PTR)
    Declare Sub gtk_widget_set_visible(ByVal widget AS GObj PTR, ByVal visible AS INTEGER)
    Declare Sub gtk_widget_set_size_request(ByVal widget AS GObj PTR, ByVal width AS INTEGER, ByVal height AS INTEGER)
    ' A dedicated, non-variadic convenience function (unlike most GTK
    ' style/appearance knobs) - the natural fit for LSP hover text.
    Declare Sub gtk_widget_set_tooltip_text(ByVal widget AS GObj PTR, ByVal text AS ZSTRING)
End Extern
