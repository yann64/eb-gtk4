' Idiomatic layer: GtkWindow.

#include once "widget.bas"
#include once "application.bas"
#include once "raw/gtk_window.bas"
#include once "raw/gtk_application.bas"

TYPE Window EXTENDS Widget
END TYPE

FUNCTION NewWindow() AS Window
    DIM w AS Window
    w.handle = SinkHandle(gtk_window_new())
    NewWindow = w
END FUNCTION

FUNCTION NewApplicationWindow(app AS Application) AS Window
    DIM w AS Window
    w.handle = SinkHandle(gtk_application_window_new(app.handle))
    NewApplicationWindow = w
END FUNCTION

SUB WindowSetTitle(w AS Window, title AS ZSTRING)
    CALL gtk_window_set_title(w.handle, title)
END SUB

SUB WindowSetDefaultSize(w AS Window, width AS INTEGER, height AS INTEGER)
    CALL gtk_window_set_default_size(w.handle, width, height)
END SUB

SUB WindowSetChild(w AS Window, child AS Widget)
    CALL gtk_window_set_child(w.handle, child.handle)
END SUB

SUB WindowPresent(w AS Window)
    CALL gtk_window_present(w.handle)
END SUB

SUB WindowDestroy(w AS Window)
    CALL gtk_window_destroy(w.handle)
END SUB
