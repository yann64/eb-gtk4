' Idiomatic layer: GtkScrolledWindow.

#include once "widget.bas"
#include once "raw/gtk_scrolled_window.bas"

''' A scrollable viewport for a single child widget - GtkTextView/
''' GtkSourceView don't scroll themselves, so this is how a code editor's
''' text area actually gets a scrollbar.
TYPE ScrolledWindow EXTENDS Widget
END TYPE

''' Creates a new, empty GtkScrolledWindow.
FUNCTION NewScrolledWindow() AS ScrolledWindow
    DIM s AS ScrolledWindow
    s.handle = SinkHandle(gtk_scrolled_window_new())
    NewScrolledWindow = s
END FUNCTION

''' Sets the single child widget to scroll (typically a TextView/SourceView).
SUB ScrolledWindowSetChild(sw AS ScrolledWindow, child AS Widget)
    CALL gtk_scrolled_window_set_child(sw.handle, child.handle)
END SUB

''' See WrapWidget's own doc comment.
FUNCTION WrapScrolledWindow(h AS ANY PTR) AS ScrolledWindow
    DIM s AS ScrolledWindow
    s.handle = h
    WrapScrolledWindow = s
END FUNCTION
