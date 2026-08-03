' Idiomatic layer: GtkPaned.

#include once "widget.bas"
#include once "raw/gtk_paned.bas"

''' A resizable two-pane split (e.g. sidebar | editor).
TYPE Paned EXTENDS Widget
END TYPE

''' Creates a new GtkPaned - `orientation` is GTK_ORIENTATION_HORIZONTAL
''' (side-by-side panes) or GTK_ORIENTATION_VERTICAL (stacked panes),
''' see raw/gtk_orientable.bas.
FUNCTION NewPaned(orientation AS INTEGER) AS Paned
    DIM p AS Paned
    p.handle = SinkHandle(gtk_paned_new(orientation))
    NewPaned = p
END FUNCTION

''' Sets the start (left/top) pane's widget.
SUB PanedSetStartChild(p AS Paned, child AS Widget)
    CALL gtk_paned_set_start_child(p.handle, child.handle)
END SUB

''' Sets the end (right/bottom) pane's widget.
SUB PanedSetEndChild(p AS Paned, child AS Widget)
    CALL gtk_paned_set_end_child(p.handle, child.handle)
END SUB

''' Sets the divider's position, in pixels from the start.
SUB PanedSetPosition(p AS Paned, position AS INTEGER)
    CALL gtk_paned_set_position(p.handle, position)
END SUB

''' Widens the divider handle, making it easier to grab.
SUB PanedSetWideHandle(p AS Paned, wide AS INTEGER)
    CALL gtk_paned_set_wide_handle(p.handle, wide)
END SUB

''' See WrapWidget's own doc comment.
FUNCTION WrapPaned(h AS ANY PTR) AS Paned
    DIM p AS Paned
    p.handle = h
    WrapPaned = p
END FUNCTION
