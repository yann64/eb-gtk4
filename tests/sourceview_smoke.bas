' Smoke test: exercises GtkSourceView's display-independent parts -
' SourceBuffer (a GtkTextBuffer subclass, needs no display, same
' reasoning as text_buffer_smoke.bas) and the language/style-scheme
' manager singletons (pure lookups, no widget involved at all). Real
' SourceView widget construction needs a display backend - see
' tests/manual/widget_construction.bas.

#include once "../src/lib.bas"

DIM langMgr AS SourceLanguageManager
langMgr = SourceLanguageManagerGetDefault()

DIM py AS SourceLanguage
py = SourceLanguageManagerGetLanguage(langMgr, "python3")
PRINT py.handle <> 0

DIM nosuch AS SourceLanguage
nosuch = SourceLanguageManagerGetLanguage(langMgr, "no-such-language-xyz")
PRINT nosuch.handle = 0

DIM schemeMgr AS SourceStyleSchemeManager
schemeMgr = SourceStyleSchemeManagerGetDefault()

DIM nosuchScheme AS SourceStyleScheme
nosuchScheme = SourceStyleSchemeManagerGetScheme(schemeMgr, "no-such-scheme-xyz")
PRINT nosuchScheme.handle = 0

DIM buf AS SourceBuffer
buf = NewSourceBufferWithLanguage(py)
CALL SourceBufferSetHighlightSyntax(buf, 1)
CALL TextBufferSetText(buf, "print(1)")

DIM rawText AS ANY PTR
rawText = TextBufferGetText(buf)
DIM viaZstring AS ZSTRING
viaZstring = rawText
DIM text AS STRING
text = viaZstring
CALL FreeGMallocString(rawText)
PRINT text

CALL ObjDestroy(buf)

PRINT "sourceview smoke ok"
