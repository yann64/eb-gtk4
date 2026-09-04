' Raw FFI layer: GtkStatusbar core (`gtk-4`).
'
' Deprecated since GTK 4.10 (real upstream GTK4 has no non-deprecated
' replacement widget for this exact role as of this writing) but still
' fully present and functional - the only concrete statusbar widget
' GTK4 offers at all, so this package binds it as-is.

#include once "gobject.bas"

Extern "C" Lib "gtk-4"
    Declare Function gtk_statusbar_new() AS GObj PTR
    ' A statusbar can track several independent message "contexts"
    ' (stacks) at once, each identified by this id - this package always
    ' uses exactly one, obtained once per statusbar and reused for every
    ' push/pop, since the universal API only ever needs a single current
    ' message.
    Declare Function gtk_statusbar_get_context_id(ByVal statusbar AS GObj PTR, ByVal context_description AS ZSTRING) AS UINTEGER
    Declare Function gtk_statusbar_push(ByVal statusbar AS GObj PTR, ByVal context_id AS UINTEGER, ByVal text AS ZSTRING) AS UINTEGER
    Declare Sub gtk_statusbar_pop(ByVal statusbar AS GObj PTR, ByVal context_id AS UINTEGER)
End Extern
