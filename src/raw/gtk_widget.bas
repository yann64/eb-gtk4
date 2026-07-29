' Raw FFI layer: GtkWidget core (`gtk-4`).

#include once "gobject.bas"

Extern "C" Lib "gtk-4"
    Declare Sub gtk_widget_show(ByVal widget AS ANY PTR)
    Declare Sub gtk_widget_set_visible(ByVal widget AS ANY PTR, ByVal visible AS INTEGER)
    Declare Sub gtk_widget_set_size_request(ByVal widget AS ANY PTR, ByVal width AS INTEGER, ByVal height AS INTEGER)
End Extern
