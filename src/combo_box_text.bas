' Idiomatic layer: GtkComboBoxText. See raw/gtk_combo_box_text.bas for
' why this deprecated-but-simple widget was chosen over GtkDropDown.

#include once "widget.bas"
#include once "raw/gtk_combo_box_text.bas"

TYPE ComboBoxText EXTENDS Widget
END TYPE

FUNCTION NewComboBoxText() AS ComboBoxText
    DIM c AS ComboBoxText
    c.handle = SinkHandle(gtk_combo_box_text_new())
    NewComboBoxText = c
END FUNCTION

SUB ComboBoxTextAppendText(c AS ComboBoxText, text AS ZSTRING)
    CALL gtk_combo_box_text_append_text(c.handle, text)
END SUB

''' Returns a newly `g_malloc`'d string the caller must free via
''' text.bas's own FreeGMallocString - see TextBufferGetText's own doc
''' comment for the exact ANY-PTR-as-ZSTRING bridging pattern.
FUNCTION ComboBoxTextGetActiveText(c AS ComboBoxText) AS ANY PTR
    ComboBoxTextGetActiveText = gtk_combo_box_text_get_active_text(c.handle)
END FUNCTION

''' Index-based accessors - real GtkComboBox (the base class) functions,
''' since GtkComboBoxText itself has no index accessor of its own.
FUNCTION ComboBoxTextGetActive(c AS ComboBoxText) AS INTEGER
    ComboBoxTextGetActive = gtk_combo_box_get_active(c.handle)
END FUNCTION

SUB ComboBoxTextSetActive(c AS ComboBoxText, index AS INTEGER)
    CALL gtk_combo_box_set_active(c.handle, index)
END SUB

''' See WrapWidget's own doc comment - e.g. for a "changed" signal
''' handler's own `c AS ANY PTR` parameter.
FUNCTION WrapComboBoxText(h AS ANY PTR) AS ComboBoxText
    DIM c AS ComboBoxText
    c.handle = h
    WrapComboBoxText = c
END FUNCTION
