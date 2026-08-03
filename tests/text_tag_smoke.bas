' Smoke test: GtkTextTag creation/application via the non-variadic GValue
' path (TextBufferCreateUnderlineTag et al, text.bas) - display-independent
' (a GtkTextBuffer/GtkTextTag never render anything themselves), same
' reasoning as text_buffer_smoke.bas. Exercises the new g_type_from_name/
' GValue/g_object_set_property bindings (raw/gobject.bas) end to end.

#include once "../src/lib.bas"

DIM buf AS TextBuffer
buf = NewTextBuffer()
CALL TextBufferSetText(buf, "DIM x AS INTEGER")

DIM errorTag AS ANY PTR
errorTag = TextBufferCreateUnderlineTag(buf, "lsp-error", PANGO_UNDERLINE_ERROR)
PRINT errorTag <> 0

' Apply the tag over "x" (line 0, columns 4-5) and clear it again - if
' either call passed a bad GType/property name, this would abort the
' whole process (a GLib critical warning followed by g_object ref
' assertion failures), so simply reaching "smoke ok" below is real
' verification, not just a non-empty-pointer check.
CALL TextBufferApplyTagRange(buf, errorTag, 0, 4, 0, 5)
CALL TextBufferClearTag(buf, errorTag)

PRINT "text tag smoke ok"
