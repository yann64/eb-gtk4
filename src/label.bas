' Idiomatic layer: GtkLabel.

#include once "widget.bas"
#include once "raw/gtk_label.bas"

TYPE Label EXTENDS Widget
END TYPE

FUNCTION NewLabel(text AS ZSTRING) AS Label
    DIM l AS Label
    l.handle = SinkHandle(gtk_label_new(text))
    NewLabel = l
END FUNCTION

SUB LabelSetText(lbl AS Label, text AS ZSTRING)
    CALL gtk_label_set_text(lbl.handle, text)
END SUB

FUNCTION LabelGetText(lbl AS Label) AS ZSTRING
    LabelGetText = gtk_label_get_text(lbl.handle)
END FUNCTION
