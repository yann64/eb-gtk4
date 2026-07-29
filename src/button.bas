' Idiomatic layer: GtkButton.

#include once "widget.bas"
#include once "raw/gtk_button.bas"

TYPE Button EXTENDS Widget
END TYPE

FUNCTION NewButton(label AS ZSTRING) AS Button
    DIM b AS Button
    b.handle = SinkHandle(gtk_button_new_with_label(label))
    NewButton = b
END FUNCTION

SUB ButtonSetLabel(btn AS Button, label AS ZSTRING)
    CALL gtk_button_set_label(btn.handle, label)
END SUB

FUNCTION ButtonGetLabel(btn AS Button) AS ZSTRING
    ButtonGetLabel = gtk_button_get_label(btn.handle)
END FUNCTION
