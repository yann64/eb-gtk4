' Idiomatic layer: GtkBox.

#include once "widget.bas"
#include once "raw/gtk_box.bas"
#include once "raw/gtk_orientable.bas"

''' A GtkBox - a simple horizontal/vertical layout container.
TYPE Box EXTENDS Widget
END TYPE

''' Creates a new GtkBox. `orientation` is GTK_ORIENTATION_HORIZONTAL or
''' GTK_ORIENTATION_VERTICAL; `spacing` is the pixel gap between children.
FUNCTION NewBox(orientation AS INTEGER, spacing AS INTEGER) AS Box
    DIM b AS Box
    b.handle = SinkHandle(gtk_box_new(orientation, spacing))
    NewBox = b
END FUNCTION

''' Appends a child widget to the end of the box.
SUB BoxAppend(box AS Box, child AS Widget)
    CALL gtk_box_append(box.handle, child.handle)
END SUB

''' Inserts a child widget at the start of the box, ahead of every
''' existing child - used by WindowMenuBar/WindowToolBar (window.bas) to
''' keep a window's chrome above its main content regardless of the
''' order those are requested in.
SUB BoxPrepend(box AS Box, child AS Widget)
    CALL gtk_box_prepend(box.handle, child.handle)
END SUB

''' Removes a child widget from the box (must already be one of its
''' direct children).
SUB BoxRemove(box AS Box, child AS Widget)
    CALL gtk_box_remove(box.handle, child.handle)
END SUB

''' Changes the pixel gap between the box's children.
SUB BoxSetSpacing(box AS Box, spacing AS INTEGER)
    CALL gtk_box_set_spacing(box.handle, spacing)
END SUB

''' See WrapWidget's own doc comment.
FUNCTION WrapBox(h AS ANY PTR) AS Box
    DIM b AS Box
    b.handle = h
    WrapBox = b
END FUNCTION
