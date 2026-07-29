' Idiomatic layer: GtkLabel.

#include once "widget.bas"
#include once "raw/gtk_label.bas"

''' A GtkLabel - a plain, non-editable text display.
TYPE Label EXTENDS Widget
END TYPE

''' Creates a new GtkLabel with the given text.
FUNCTION NewLabel(text AS ZSTRING) AS Label
    DIM l AS Label
    l.handle = SinkHandle(gtk_label_new(text))
    NewLabel = l
END FUNCTION

''' Sets a label's text.
SUB LabelSetText(lbl AS Label, text AS ZSTRING)
    CALL gtk_label_set_text(lbl.handle, text)
END SUB

''' Reads a label's current text.
FUNCTION LabelGetText(lbl AS Label) AS ZSTRING
    LabelGetText = gtk_label_get_text(lbl.handle)
END FUNCTION

''' See WrapWidget's own doc comment.
FUNCTION WrapLabel(h AS ANY PTR) AS Label
    DIM l AS Label
    l.handle = h
    WrapLabel = l
END FUNCTION
