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
DIM rawText AS ANY PTR
rawText = TextBufferGetText(buf)
DIM viaZstring AS ZSTRING
viaZstring = rawText
DIM text AS STRING
text = viaZstring
CALL FreeGMallocString(rawText)
PRINT text

CALL TextBufferSetModified(buf, 0)
PRINT TextBufferGetModified(buf)
CALL TextBufferSetText(buf, "changed")
PRINT TextBufferGetModified(buf)

CALL TextBufferPlaceCursorAt(buf, 0, 3)
PRINT TextBufferGetCursorLine(buf)
PRINT TextBufferGetCursorColumn(buf)

DIM appendBuf AS TextBuffer
appendBuf = NewTextBuffer()
CALL TextBufferAppendLine(appendBuf, "first")
CALL TextBufferAppendLine(appendBuf, "second")
DIM rawAppended AS ANY PTR
rawAppended = TextBufferGetText(appendBuf)
DIM viaZstring2 AS ZSTRING
viaZstring2 = rawAppended
DIM appended AS STRING
appended = viaZstring2
CALL FreeGMallocString(rawAppended)
PRINT appended
CALL ObjDestroy(appendBuf)

CALL ObjDestroy(buf)

PRINT "text buffer smoke ok"
