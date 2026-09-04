' Idiomatic layer: GtkListBox (see raw/gtk_listbox.bas for why this,
' not GtkListView/GListStore, backs this package's flat-list needs).

#include once "widget.bas"
#include once "raw/gtk_listbox.bas"

''' A plain list of widget rows.
TYPE ListBox EXTENDS Widget
END TYPE

''' A single row - GtkListBox auto-wraps every appended widget in one of
''' these; a "row-activated" signal handler receives the row itself (not
''' the widget you appended) as its own parameter.
TYPE ListBoxRow EXTENDS Widget
END TYPE

''' Creates a new, empty GtkListBox.
FUNCTION NewListBox() AS ListBox
    DIM b AS ListBox
    b.handle = SinkHandle(gtk_list_box_new())
    NewListBox = b
END FUNCTION

''' Appends a widget as a new row at the end of the list.
SUB ListBoxAppend(box AS ListBox, child AS Widget)
    CALL gtk_list_box_append(box.handle, child.handle)
END SUB

''' Removes every row.
SUB ListBoxRemoveAll(box AS ListBox)
    CALL gtk_list_box_remove_all(box.handle)
END SUB

''' The row at `index` (0-based), or a "not found" result (`.handle = 0`)
''' if out of range.
FUNCTION ListBoxGetRowAtIndex(box AS ListBox, index AS INTEGER) AS ListBoxRow
    DIM r AS ListBoxRow
    r.handle = gtk_list_box_get_row_at_index(box.handle, index)
    ListBoxGetRowAtIndex = r
END FUNCTION

''' A row's own 0-based position within its list box.
FUNCTION ListBoxRowGetIndex(row AS ListBoxRow) AS INTEGER
    ListBoxRowGetIndex = gtk_list_box_row_get_index(row.handle)
END FUNCTION

''' Whether a single click (rather than a double-click) fires
''' "row-activated" - a code editor's file list typically wants this on.
SUB ListBoxSetActivateOnSingleClick(box AS ListBox, singleClick AS INTEGER)
    CALL gtk_list_box_set_activate_on_single_click(box.handle, singleClick)
END SUB

''' The currently selected row, or a "none selected" result
''' (`.handle = 0`) - real GTK4 returns NULL when nothing is selected.
FUNCTION ListBoxGetSelectedRow(box AS ListBox) AS ListBoxRow
    DIM r AS ListBoxRow
    r.handle = gtk_list_box_get_selected_row(box.handle)
    ListBoxGetSelectedRow = r
END FUNCTION

''' Selects `row` - pass a `ListBoxRow` with `.handle = 0` to clear the
''' selection (real GTK4 accepts NULL directly).
SUB ListBoxSelectRow(box AS ListBox, row AS ListBoxRow)
    CALL gtk_list_box_select_row(box.handle, row.handle)
END SUB

''' A row's own appended child widget (see ListBoxAppend) - lets a
''' caller read back what it stored per row without tracking it
''' separately.
FUNCTION ListBoxRowGetChild(row AS ListBoxRow) AS Widget
    DIM w AS Widget
    w.handle = gtk_list_box_row_get_child(row.handle)
    ListBoxRowGetChild = w
END FUNCTION

''' See WrapWidget's own doc comment.
FUNCTION WrapListBox(h AS ANY PTR) AS ListBox
    DIM b AS ListBox
    b.handle = h
    WrapListBox = b
END FUNCTION

''' See WrapWidget's own doc comment.
FUNCTION WrapListBoxRow(h AS ANY PTR) AS ListBoxRow
    DIM r AS ListBoxRow
    r.handle = h
    WrapListBoxRow = r
END FUNCTION
