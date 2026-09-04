' Idiomatic layer: GtkWindow.

#include once "widget.bas"
#include once "application.bas"
#include once "raw/gtk_window.bas"
#include once "raw/gtk_application.bas"

''' A top-level window.
TYPE Window EXTENDS Widget
END TYPE

''' Creates a plain, standalone GtkWindow (not tied to a GtkApplication -
''' see NewApplicationWindow for the usual case).
FUNCTION NewWindow() AS Window
    DIM w AS Window
    w.handle = SinkHandle(gtk_window_new())
    NewWindow = w
END FUNCTION

''' Creates a GtkApplicationWindow tied to the given application - the
''' usual way to create a top-level window inside an "activate" handler.
FUNCTION NewApplicationWindow(app AS Application) AS Window
    DIM w AS Window
    w.handle = SinkHandle(gtk_application_window_new(app.handle))
    NewApplicationWindow = w
END FUNCTION

''' Sets a window's title bar text.
SUB WindowSetTitle(w AS Window, title AS ZSTRING)
    CALL gtk_window_set_title(w.handle, title)
END SUB

''' Sets a window's initial size.
SUB WindowSetDefaultSize(w AS Window, width AS INTEGER, height AS INTEGER)
    CALL gtk_window_set_default_size(w.handle, width, height)
END SUB

''' Sets a window's single child widget (typically a Box holding the
''' rest of the UI).
SUB WindowSetChild(w AS Window, child AS Widget)
    CALL gtk_window_set_child(w.handle, child.handle)
END SUB

''' Sets a window's title bar to a custom widget (typically a HeaderBar -
''' any Widget works here, matching gtk_window_set_titlebar's own real
''' signature).
SUB WindowSetTitlebar(w AS Window, titlebar AS Widget)
    CALL gtk_window_set_titlebar(w.handle, titlebar.handle)
END SUB

''' Shows and raises a window.
SUB WindowPresent(w AS Window)
    CALL gtk_window_present(w.handle)
END SUB

''' Makes `w` modal with respect to `parent` - blocks interaction with
''' `parent` (and any of its other transient children) until `w` is
''' closed or WindowClearModal is called. Sets both the transient-parent
''' relationship and the modal flag in one call, since real GTK4's
''' modality has no visible effect without a transient parent also set.
SUB WindowSetModal(w AS Window, parent AS Window)
    CALL gtk_window_set_transient_for(w.handle, parent.handle)
    CALL gtk_window_set_modal(w.handle, 1)
END SUB

''' Stops `w` from blocking its transient parent - the transient-parent
''' relationship itself is left in place (harmless once non-modal;
''' re-call WindowSetModal to restore both).
SUB WindowClearModal(w AS Window)
    CALL gtk_window_set_modal(w.handle, 0)
END SUB

FUNCTION WindowIsModal(w AS Window) AS INTEGER
    WindowIsModal = gtk_window_get_modal(w.handle)
END FUNCTION

''' Requests a window close through the same "close-request" signal path
''' a real click on the titlebar's close button goes through (unlike
''' WindowDestroy, which bypasses it entirely) - the way to exercise/test
''' a close-request handler without needing a real click.
'''
''' CONFIRMED (via a standalone, non-interactive program, not assumed):
''' `w` must already have been WindowPresent-ed at least once - calling
''' this on a window that was only ever created, never presented, does
''' NOT emit "close-request" at all (no error either - it's just silently
''' a no-op signal-wise). Present first, then close.
SUB WindowClose(w AS Window)
    CALL gtk_window_close(w.handle)
END SUB

''' Destroys a window (and, transitively, its children).
SUB WindowDestroy(w AS Window)
    CALL gtk_window_destroy(w.handle)
END SUB

''' See WrapWidget's own doc comment.
FUNCTION WrapWindow(h AS ANY PTR) AS Window
    DIM w AS Window
    w.handle = h
    WrapWindow = w
END FUNCTION
