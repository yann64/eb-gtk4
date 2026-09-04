' Raw FFI layer: GtkComboBoxText (`gtk-4`). Real GTK4 deprecated this in
' favor of GtkDropDown (4.10+), but GtkComboBoxText is still real, still
' linkable, and far simpler (one string in, one string out, one
' "changed" signal) - matching this project's own established
' preference for the simplest working API, the same reasoning that
' chose plain Box/Grid over more elaborate layout constructs.
' gtk_combo_box_get_active/set_active are real GtkComboBox (the base
' class) functions, needed since GtkComboBoxText itself has no
' index-based accessor of its own.

#include once "gobject.bas"

Extern "C" Lib "gtk-4"
    Declare Function gtk_combo_box_text_new() AS GObj PTR
    Declare Sub gtk_combo_box_text_append_text(ByVal comboBox AS GObj PTR, ByVal text AS ZSTRING)
    ' Returns a newly `g_malloc`'d string the caller must free via
    ' FreeGMallocString (see text.bas's own TextBufferGetText) - unlike
    ' gtk_check_button_get_label's borrowed string.
    Declare Function gtk_combo_box_text_get_active_text(ByVal comboBox AS GObj PTR) AS ANY PTR
    Declare Function gtk_combo_box_get_active(ByVal comboBox AS GObj PTR) AS INTEGER
    Declare Sub gtk_combo_box_set_active(ByVal comboBox AS GObj PTR, ByVal index AS INTEGER)
End Extern
