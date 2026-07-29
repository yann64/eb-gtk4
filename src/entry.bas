' Idiomatic layer: GtkEntry.

#include once "widget.bas"
#include once "raw/gtk_entry.bas"

''' A GtkEntry - a single-line text input field.
TYPE Entry EXTENDS Widget
END TYPE

''' Creates a new, empty GtkEntry.
FUNCTION NewEntry() AS Entry
    DIM e AS Entry
    e.handle = SinkHandle(gtk_entry_new())
    NewEntry = e
END FUNCTION

''' Sets an entry's text.
SUB EntrySetText(e AS Entry, text AS ZSTRING)
    CALL gtk_editable_set_text(e.handle, text)
END SUB

''' Reads an entry's current text.
FUNCTION EntryGetText(e AS Entry) AS ZSTRING
    EntryGetText = gtk_editable_get_text(e.handle)
END FUNCTION

''' See WrapWidget's own doc comment.
FUNCTION WrapEntry(h AS ANY PTR) AS Entry
    DIM e AS Entry
    e.handle = h
    WrapEntry = e
END FUNCTION
