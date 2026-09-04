' Raw FFI layer: GtkWindow core (`gtk-4`).

#include once "gobject.bas"

Extern "C" Lib "gtk-4"
    Declare Function gtk_window_new() AS GObj PTR
    Declare Sub gtk_window_set_title(ByVal window AS GObj PTR, ByVal title AS ZSTRING)
    Declare Sub gtk_window_set_default_size(ByVal window AS GObj PTR, ByVal width AS INTEGER, ByVal height AS INTEGER)
    Declare Sub gtk_window_set_child(ByVal window AS GObj PTR, ByVal child AS GObj PTR)
    Declare Sub gtk_window_set_titlebar(ByVal window AS GObj PTR, ByVal titlebar AS GObj PTR)
    Declare Sub gtk_window_present(ByVal window AS GObj PTR)
    Declare Sub gtk_window_destroy(ByVal window AS GObj PTR)
    ' A modal window blocks interaction with its transient parent (and
    ' any of the parent's other transient children) until closed - real
    ' GTK4 requires a transient parent to be set for modality to have any
    ' visible effect (an unparented modal window just blocks nothing).
    Declare Sub gtk_window_set_modal(ByVal window AS GObj PTR, ByVal modal AS INTEGER)
    Declare Sub gtk_window_set_transient_for(ByVal window AS GObj PTR, ByVal parent AS GObj PTR)
    Declare Function gtk_window_get_modal(ByVal window AS GObj PTR) AS INTEGER
    ' Requests a window close through the same "close-request" signal
    ' path a real click on the titlebar's close button goes through
    ' (unlike gtk_window_destroy, which bypasses it entirely) - lets a
    ' close-request handler be exercised/tested programmatically.
    Declare Sub gtk_window_close(ByVal window AS GObj PTR)
End Extern
