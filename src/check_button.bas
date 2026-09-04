' Idiomatic layer: GtkCheckButton. Real GTK4 unifies checkbox and
' radio-button semantics into this single widget class - GtkRadioButton
' was removed upstream entirely. This package exposes ONE CheckButton
' TYPE; eb-gui-gtk4 is what gives checkbox/radio-button separate
' contract identities on top of it, not this package.

#include once "widget.bas"
#include once "raw/gtk_check_button.bas"

''' A GtkCheckButton - used for both plain checkboxes and (once grouped
''' via CheckButtonSetGroup) mutually-exclusive radio buttons.
TYPE CheckButton EXTENDS Widget
END TYPE

''' Creates a new GtkCheckButton with a text label.
FUNCTION NewCheckButton(label AS ZSTRING) AS CheckButton
    DIM c AS CheckButton
    c.handle = SinkHandle(gtk_check_button_new_with_label(label))
    NewCheckButton = c
END FUNCTION

SUB CheckButtonSetActive(c AS CheckButton, active AS INTEGER)
    CALL gtk_check_button_set_active(c.handle, active)
END SUB

FUNCTION CheckButtonGetActive(c AS CheckButton) AS INTEGER
    CheckButtonGetActive = gtk_check_button_get_active(c.handle)
END FUNCTION

SUB CheckButtonSetLabel(c AS CheckButton, label AS ZSTRING)
    CALL gtk_check_button_set_label(c.handle, label)
END SUB

FUNCTION CheckButtonGetLabel(c AS CheckButton) AS ZSTRING
    CheckButtonGetLabel = gtk_check_button_get_label(c.handle)
END FUNCTION

''' Groups `c` with `group` for mutual exclusivity (radio-button
''' semantics) - real GTK4 has no separate group object at all, a
''' GtkCheckButton is simply chained directly to another one.
SUB CheckButtonSetGroup(c AS CheckButton, group AS CheckButton)
    CALL gtk_check_button_set_group(c.handle, group.handle)
END SUB

''' See WrapWidget's own doc comment - e.g. for a "toggled" signal
''' handler's own `c AS ANY PTR` parameter.
FUNCTION WrapCheckButton(h AS ANY PTR) AS CheckButton
    DIM c AS CheckButton
    c.handle = h
    WrapCheckButton = c
END FUNCTION
