' Raw FFI layer: GtkWidget core (`gtk-4`).

#include once "gobject.bas"

Extern "C" Lib "gtk-4"
    Declare Sub gtk_widget_show(ByVal widget AS GObj PTR)
    Declare Sub gtk_widget_set_visible(ByVal widget AS GObj PTR, ByVal visible AS INTEGER)
    Declare Sub gtk_widget_set_size_request(ByVal widget AS GObj PTR, ByVal width AS INTEGER, ByVal height AS INTEGER)
    ' A dedicated, non-variadic convenience function (unlike most GTK
    ' style/appearance knobs) - the natural fit for LSP hover text.
    Declare Sub gtk_widget_set_tooltip_text(ByVal widget AS GObj PTR, ByVal text AS ZSTRING)
    ' Returns TRUE/FALSE (INTEGER) - a widget can refuse focus (not
    ' focusable, not visible/mapped yet, ...), matching real GTK4
    ' semantics; the idiomatic wrapper doesn't force callers to check it
    ' (best-effort, same as WidgetShow/WidgetSetVisible's own fire-and-
    ' forget shape), but the raw signature still reflects the real return
    ' type rather than silently discarding it at the FFI boundary.
    Declare Function gtk_widget_grab_focus(ByVal widget AS GObj PTR) AS INTEGER
    ' A desensitized (disabled) widget is grayed out and stops accepting
    ' input - real GTK4 also desensitizes (transitively) any child
    ' widgets, unless one of them was explicitly re-sensitized itself.
    ' GTK4 has no window-level "disabled" concept of its own - this is
    ' the only enable/disable primitive that exists, at any level.
    Declare Sub gtk_widget_set_sensitive(ByVal widget AS GObj PTR, ByVal sensitive AS INTEGER)
    Declare Function gtk_widget_get_sensitive(ByVal widget AS GObj PTR) AS INTEGER
End Extern
