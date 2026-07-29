' Raw FFI layer: GtkEntry core (`gtk-4`).
' Text access goes through the GtkEditable interface (gtk_editable_*),
' which GtkEntry implements, rather than Entry-specific functions.

#include once "gobject.bas"

Extern "C" Lib "gtk-4"
    Declare Function gtk_entry_new() AS GObj PTR
    Declare Sub gtk_editable_set_text(ByVal editable AS GObj PTR, ByVal text AS ZSTRING)
    Declare Function gtk_editable_get_text(ByVal editable AS GObj PTR) AS ZSTRING
End Extern
