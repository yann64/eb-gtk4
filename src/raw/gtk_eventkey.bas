' Raw FFI layer: GtkEventControllerKey (`gtk-4`) - the simplest way to
' react to a specific key combination (e.g. Ctrl+S), deliberately used
' here instead of the full GAction/GtkApplication-accelerator subsystem
' (a much larger binding surface for the same narrow need). Real GDK
' keyval/modifier-mask constants confirmed directly against the installed
' GTK4 headers (gdk/gdkkeysyms.h, gdk/gdkenums.h), not recalled from
' memory alone.

#include once "gobject.bas"

' GdkModifierType bits actually needed here (gdk/gdkenums.h).
CONST GDK_SHIFT_MASK = 1
CONST GDK_CONTROL_MASK = 4

' A few common GDK keyvals (gdk/gdkkeysyms.h) - lowercase-letter keyvals
' equal their own ASCII codepoint by GDK's own long-standing convention.
CONST GDK_KEY_s = 115

Extern "C" Lib "gtk-4"
    Declare Function gtk_event_controller_key_new() AS GObj PTR
    Declare Sub gtk_widget_add_controller(ByVal widget AS GObj PTR, ByVal controller AS GObj PTR)
End Extern
