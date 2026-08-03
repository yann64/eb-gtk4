' Smoke test: exercises GtkTextBuffer's idiomatic layer (text.bas) -
' display-independent (a GtkTextBuffer holds text but never renders
' anything itself, unlike GtkTextView), so this runs safely under `ebpm
' test` in a headless/CI sandbox, same reasoning as raw_smoke.bas/
' idiomatic_smoke.bas. Also exercises the ANY-PTR-as-ZSTRING compiler
' bridge TextBufferGetText relies on to safely free GTK's own allocation.

#include once "../src/lib.bas"

DIM buf AS TextBuffer
buf = NewTextBuffer()

CALL TextBufferSetText(buf, "hello world")
PRINT TextBufferGetText(buf)

CALL TextBufferSetModified(buf, 0)
PRINT TextBufferGetModified(buf)
CALL TextBufferSetText(buf, "changed")
PRINT TextBufferGetModified(buf)

CALL TextBufferPlaceCursorAt(buf, 0, 3)
PRINT TextBufferGetCursorLine(buf)
PRINT TextBufferGetCursorColumn(buf)

CALL ObjDestroy(buf)

PRINT "text buffer smoke ok"
