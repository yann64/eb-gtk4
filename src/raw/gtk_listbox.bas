' Raw FFI layer: GtkListBox core (`gtk-4`).
'
' A plain, non-model-backed list of widget rows - deliberately used here
' instead of GtkListView/GListStore (GTK4's own newer, model+factory-based
' list widget) for this package's "flat file list" scope: GtkListBox lets
' a caller `Append` a real widget per row directly, with none of
' GListModel/GtkListItemFactory's virtual-function wiring - the simplest
' binding that still delivers a real, usable list widget. GtkListView
' remains available to bind later if a future need (e.g. a large,
' virtualized list) actually requires it.

#include once "gobject.bas"

Extern "C" Lib "gtk-4"
    Declare Function gtk_list_box_new() AS GObj PTR
    Declare Sub gtk_list_box_append(ByVal box AS GObj PTR, ByVal child AS GObj PTR)
    Declare Sub gtk_list_box_remove_all(ByVal box AS GObj PTR)
    Declare Function gtk_list_box_get_row_at_index(ByVal box AS GObj PTR, ByVal index AS INTEGER) AS GObj PTR
    Declare Function gtk_list_box_row_get_index(ByVal row AS GObj PTR) AS INTEGER
    Declare Sub gtk_list_box_set_activate_on_single_click(ByVal box AS GObj PTR, ByVal singleClick AS INTEGER)
    ' Selection - a NULL row means "none selected".
    Declare Function gtk_list_box_get_selected_row(ByVal box AS GObj PTR) AS GObj PTR
    Declare Sub gtk_list_box_select_row(ByVal box AS GObj PTR, ByVal row AS GObj PTR)
    ' A row's own appended child widget (see gtk_list_box_append) -
    ' lets a caller read back what it stored per row without needing to
    ' track it separately.
    Declare Function gtk_list_box_row_get_child(ByVal row AS GObj PTR) AS GObj PTR
End Extern
