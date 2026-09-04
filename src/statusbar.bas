' Idiomatic layer: GtkStatusbar.
'
' Deprecated since GTK 4.10 upstream, but the only concrete statusbar
' widget GTK4 offers at all - see raw/gtk_statusbar.bas's own top
' comment. This wrapper always uses exactly one message "context"
' (obtained once at construction, stored in the TYPE itself alongside
' the handle), matching the universal eb-gui API's own simple
' single-current-message model - real GtkStatusbar's own multi-context
' stacking is not exposed here.

#include once "widget.bas"
#include once "raw/gtk_statusbar.bas"

TYPE StatusBar EXTENDS Widget
    contextId AS UINTEGER
END TYPE

''' Creates a new, empty GtkStatusbar.
FUNCTION NewStatusBar() AS StatusBar
    DIM s AS StatusBar
    s.handle = SinkHandle(gtk_statusbar_new())
    s.contextId = gtk_statusbar_get_context_id(s.handle, "eb-gtk4")
    NewStatusBar = s
END FUNCTION

''' Shows `text`, replacing any message currently shown.
SUB StatusBarShowMessage(s AS StatusBar, text AS ZSTRING)
    CALL gtk_statusbar_push(s.handle, s.contextId, text)
END SUB

''' Clears the currently shown message, if any.
SUB StatusBarClear(s AS StatusBar)
    CALL gtk_statusbar_pop(s.handle, s.contextId)
END SUB
