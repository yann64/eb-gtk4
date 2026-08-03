' Raw FFI layer: GtkFileChooserNative core (`gtk-4`) + GFile path access
' (`gio-2.0`, already linked).
'
' GtkFileChooserNative is asynchronous by nature (the platform's own
' native dialog, possibly out-of-process under Flatpak's portal) - there
' is no blocking "run and get the result" call. A caller connects to its
' `"response"` signal (via the existing ObjConnect) and reads the chosen
' file only if the response is GTK_RESPONSE_ACCEPT.

#include once "gobject.bas"

' GtkFileChooserAction (docs.gtk.org).
CONST GTK_FILE_CHOOSER_ACTION_OPEN = 0
CONST GTK_FILE_CHOOSER_ACTION_SAVE = 1
CONST GTK_FILE_CHOOSER_ACTION_SELECT_FOLDER = 2

' GtkResponseType's two values a file dialog's own "response" signal
' actually uses (the full enum has many more, irrelevant here).
CONST GTK_RESPONSE_ACCEPT = -3
CONST GTK_RESPONSE_CANCEL = -6

Extern "C" Lib "gtk-4"
    Declare Function gtk_file_chooser_native_new(ByVal title AS ZSTRING, ByVal parent AS GObj PTR, ByVal action AS INTEGER, ByVal accept_label AS ZSTRING, ByVal cancel_label AS ZSTRING) AS GObj PTR
    Declare Sub gtk_native_dialog_show(ByVal dialog AS GObj PTR)
    Declare Sub gtk_native_dialog_hide(ByVal dialog AS GObj PTR)
    Declare Sub gtk_native_dialog_destroy(ByVal dialog AS GObj PTR)
    ' Part of the GtkFileChooser interface, which GtkFileChooserNative
    ' implements - returns a borrowed GFile*, valid only inside the
    ' "response" handler (call g_file_get_path before returning from it).
    Declare Function gtk_file_chooser_get_file(ByVal chooser AS GObj PTR) AS GObj PTR
End Extern

Extern "C" Lib "gio-2.0"
    ' Returns a newly allocated path string the caller must g_free - same
    ' shape as gtk_text_buffer_get_text (see text.bas's own doc comment on
    ' its ANY-PTR-as-ZSTRING bridge pattern).
    Declare Function g_file_get_path(ByVal file AS GObj PTR) AS ANY PTR
End Extern
