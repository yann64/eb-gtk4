' Idiomatic layer: GtkBox.

#include once "widget.bas"
#include once "raw/gtk_box.bas"
#include once "raw/gtk_orientable.bas"

TYPE Box EXTENDS Widget
END TYPE

FUNCTION NewBox(orientation AS INTEGER, spacing AS INTEGER) AS Box
    DIM b AS Box
    b.handle = SinkHandle(gtk_box_new(orientation, spacing))
    NewBox = b
END FUNCTION

SUB BoxAppend(box AS Box, child AS Widget)
    CALL gtk_box_append(box.handle, child.handle)
END SUB

SUB BoxSetSpacing(box AS Box, spacing AS INTEGER)
    CALL gtk_box_set_spacing(box.handle, spacing)
END SUB
