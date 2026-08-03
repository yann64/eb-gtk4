' Idiomatic layer: plain-path file I/O (GLib's g_file_get_contents/
' g_file_set_contents - not GIO's own GFile object API, which isn't
' needed here since FileChooserGetFilePath already hands back a plain
' path string).

#include once "raw/glib.bas"

''' Reads a file's entire content - sets `ok` to 0 on failure (not
''' found, permission denied, ...) or 1 on success, with the content
''' returned as a newly `g_malloc`'d string the caller must free via
''' FreeGMallocString (see TextBufferGetText's own doc comment on why -
''' STRING itself can't cross this package's `--lib` boundary).
FUNCTION ReadFileContents(path AS ZSTRING, BYREF ok AS INTEGER) AS ANY PTR
    DIM contentsSlot AS ANY PTR
    contentsSlot = g_malloc(8)
    DIM success AS INTEGER
    success = g_file_get_contents(path, contentsSlot, 0, 0)
    ok = success
    IF success = 0 THEN
        CALL g_free(contentsSlot)
        ReadFileContents = 0
    ELSE
        DIM contentsPtrPtr AS ANY PTR PTR
        contentsPtrPtr = contentsSlot
        DIM result AS ANY PTR
        result = *contentsPtrPtr
        CALL g_free(contentsSlot)
        ReadFileContents = result
    END IF
END FUNCTION

''' Writes `contents` to a file, replacing its previous content entirely
''' (creating it if it doesn't exist) - returns whether it succeeded.
FUNCTION WriteFileContents(path AS ZSTRING, contents AS ZSTRING) AS INTEGER
    WriteFileContents = g_file_set_contents(path, contents, -1, 0)
END FUNCTION
