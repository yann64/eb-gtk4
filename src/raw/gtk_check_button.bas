' Raw FFI layer: GtkCheckButton (`gtk-4`). Real GTK4 unifies checkbox
' and radio-button semantics into this single widget class - GtkRadioButton
' was removed upstream entirely. Radio grouping is done by chaining a
' GtkCheckButton to another one via gtk_check_button_set_group - there
' is no separate group object in real GTK4 at all.

#include once "gobject.bas"

Extern "C" Lib "gtk-4"
    Declare Function gtk_check_button_new_with_label(ByVal label AS ZSTRING) AS GObj PTR
    Declare Function gtk_check_button_get_active(ByVal self AS GObj PTR) AS INTEGER
    Declare Sub gtk_check_button_set_active(ByVal self AS GObj PTR, ByVal setting AS INTEGER)
    Declare Sub gtk_check_button_set_group(ByVal self AS GObj PTR, ByVal group AS GObj PTR)
    Declare Function gtk_check_button_get_label(ByVal self AS GObj PTR) AS ZSTRING
    Declare Sub gtk_check_button_set_label(ByVal self AS GObj PTR, ByVal label AS ZSTRING)
End Extern
