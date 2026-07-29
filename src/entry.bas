' Idiomatic layer: GtkEntry.

#include once "widget.bas"
#include once "raw/gtk_entry.bas"

TYPE Entry EXTENDS Widget
END TYPE

FUNCTION NewEntry() AS Entry
    DIM e AS Entry
    e.handle = SinkHandle(gtk_entry_new())
    NewEntry = e
END FUNCTION

SUB EntrySetText(e AS Entry, text AS ZSTRING)
    CALL gtk_editable_set_text(e.handle, text)
END SUB

FUNCTION EntryGetText(e AS Entry) AS ZSTRING
    EntryGetText = gtk_editable_get_text(e.handle)
END FUNCTION
