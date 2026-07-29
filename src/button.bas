' Idiomatic layer: GtkButton.

#include once "widget.bas"
#include once "raw/gtk_button.bas"

''' A GtkButton.
TYPE Button EXTENDS Widget
END TYPE

''' Creates a new GtkButton with a text label.
FUNCTION NewButton(label AS ZSTRING) AS Button
    DIM b AS Button
    b.handle = SinkHandle(gtk_button_new_with_label(label))
    NewButton = b
END FUNCTION

''' Sets a button's text label.
SUB ButtonSetLabel(btn AS Button, label AS ZSTRING)
    CALL gtk_button_set_label(btn.handle, label)
END SUB

''' Reads a button's current text label.
FUNCTION ButtonGetLabel(btn AS Button) AS ZSTRING
    ButtonGetLabel = gtk_button_get_label(btn.handle)
END FUNCTION

''' See WrapWidget's own doc comment - e.g. for a "clicked" signal
''' handler's own `btn AS ANY PTR` parameter.
FUNCTION WrapButton(h AS ANY PTR) AS Button
    DIM b AS Button
    b.handle = h
    WrapButton = b
END FUNCTION
