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

''' Shows and raises a window.
SUB WindowPresent(w AS Window)
    CALL gtk_window_present(w.handle)
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
