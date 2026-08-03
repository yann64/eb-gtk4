' Idiomatic layer: GtkFileChooserNative (open/save dialogs).
'
' Deliberately GtkFileChooserNative, not the newer GTK 4.10+ GtkFileDialog
' API - broader GTK4 version compatibility (this package's own scope cut).

#include once "widget.bas"
#include once "window.bas"
#include once "raw/glib.bas"
#include once "raw/gtk_filechooser.bas"

''' A native (platform-provided, e.g. a real GTK/portal dialog under
''' Flatpak) file chooser - a GtkNativeDialog, not a GtkWidget, so this
''' extends Obj directly, matching Application's own EXTENDS choice.
''' Inherently asynchronous - connect to its "response" signal (via the
''' existing ObjConnect) rather than expecting a blocking call to return
''' the chosen file.
TYPE FileChooserNative EXTENDS Obj
END TYPE

''' Creates a new file chooser dialog - `action` is one of
''' GTK_FILE_CHOOSER_ACTION_OPEN/SAVE/SELECT_FOLDER (raw/gtk_filechooser.bas).
''' `parent` may be a "null" Window (`.handle = 0`) if there's no natural
''' parent window yet.
FUNCTION NewFileChooserNative(title AS ZSTRING, parent AS Window, action AS INTEGER, acceptLabel AS ZSTRING, cancelLabel AS ZSTRING) AS FileChooserNative
    DIM fc AS FileChooserNative
    fc.handle = SinkHandle(gtk_file_chooser_native_new(title, parent.handle, action, acceptLabel, cancelLabel))
    NewFileChooserNative = fc
END FUNCTION

''' Shows the dialog - connect to "response" first (handler shape: `SUB
''' OnResponse(dialog AS GObj PTR, responseId AS INTEGER, data AS ANY
''' PTR)`; `responseId` is GTK_RESPONSE_ACCEPT or GTK_RESPONSE_CANCEL -
''' see raw/gtk_filechooser.bas). Call FileChooserGetFilePath from inside
''' that handler, only when accepted.
SUB FileChooserNativeShow(fc AS FileChooserNative)
    CALL gtk_native_dialog_show(fc.handle)
END SUB

''' Hides the dialog without destroying it.
SUB FileChooserNativeHide(fc AS FileChooserNative)
    CALL gtk_native_dialog_hide(fc.handle)
END SUB

''' Destroys the dialog - call once done with it (typically from inside
''' its own "response" handler).
SUB FileChooserNativeDestroy(fc AS FileChooserNative)
    CALL gtk_native_dialog_destroy(fc.handle)
END SUB

''' The chosen file's real filesystem path - only meaningful when called
''' from inside a "response" handler that received GTK_RESPONSE_ACCEPT;
''' returns "" if no file was chosen.
FUNCTION FileChooserGetFilePath(fc AS FileChooserNative) AS STRING
    DIM file AS ANY PTR
    file = gtk_file_chooser_get_file(fc.handle)
    IF file = 0 THEN
        FileChooserGetFilePath = ""
    ELSE
        DIM rawPtr AS ANY PTR
        rawPtr = g_file_get_path(file)
        IF rawPtr = 0 THEN
            FileChooserGetFilePath = ""
        ELSE
            DIM viaZstring AS ZSTRING
            viaZstring = rawPtr
            DIM result AS STRING
            result = viaZstring
            CALL g_free(rawPtr)
            FileChooserGetFilePath = result
        END IF
    END IF
END FUNCTION

''' See WrapWidget's own doc comment.
FUNCTION WrapFileChooserNative(h AS ANY PTR) AS FileChooserNative
    DIM fc AS FileChooserNative
    fc.handle = h
    WrapFileChooserNative = fc
END FUNCTION
