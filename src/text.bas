' Idiomatic layer: GtkTextBuffer/GtkTextView.
'
' GtkTextIter is never exposed in this package's own public API - every
' function here takes/returns plain line/column (0-based, character
' offsets) positions instead, hiding the heap-allocated-opaque-blob
' representation described in raw/gtk_text.bas entirely inside this file.
' This also matches LSP's own `Position` shape (0-based line/character),
' which is the whole reason this package exists.

#include once "widget.bas"
#include once "raw/glib.bas"
#include once "raw/gtk_text.bas"

''' A GtkTextBuffer - never a GtkWidget itself (a GtkTextView displays
''' one), so this extends Obj directly, matching Application's own
''' EXTENDS choice.
TYPE TextBuffer EXTENDS Obj
END TYPE

''' A GtkTextView - the widget that displays/edits a TextBuffer's content.
TYPE TextView EXTENDS Widget
END TYPE

''' Allocates one GtkTextIter's worth of scratch storage - see this
''' package's own doc comment in raw/gtk_text.bas for why. Every function
''' below that needs an iterator allocates one, uses it, and frees it via
''' FreeIter before returning - callers never see a raw iterator at all.
FUNCTION NewIter() AS ANY PTR
    NewIter = g_malloc(GTK4_TEXT_ITER_SIZE)
END FUNCTION

''' Frees an iterator allocated by NewIter.
SUB FreeIter(iter AS ANY PTR)
    CALL g_free(iter)
END SUB

''' Creates a new, empty GtkTextBuffer (no tag table - CALL
''' TextBufferSetText next, or use it as-is for an empty document).
FUNCTION NewTextBuffer() AS TextBuffer
    DIM b AS TextBuffer
    b.handle = SinkHandle(gtk_text_buffer_new(0))
    NewTextBuffer = b
END FUNCTION

''' Replaces a buffer's entire content.
SUB TextBufferSetText(buf AS TextBuffer, text AS ZSTRING)
    CALL gtk_text_buffer_set_text(buf.handle, text, -1)
END SUB

''' Reads a buffer's entire content as a newly `g_malloc`'d string the
''' caller must free via FreeGMallocString once done - **not** exported as
''' `STRING`: no top-level `STRING`-returning function can cross this
''' package's own `--lib` boundary yet (confirmed directly - the generated
''' interface silently drops any that try, per its own "not exported: uses
''' STRING" comment), so every text-returning function in this package's
''' public API hands back the raw allocation instead, same as any
''' `ZSTRING`-returning-but-owned C API would. Read it via eBasic's own
''' ANY-PTR-as-ZSTRING bridge yourself (that part needs nothing from this
''' package, just the language's own bridging feature), then free it:
''' `DIM raw AS ANY PTR : raw = TextBufferGetText(buf)`
''' `DIM z AS ZSTRING : z = raw`
''' `DIM s AS STRING : s = z`
''' `CALL FreeGMallocString(raw)`
FUNCTION TextBufferGetText(buf AS TextBuffer) AS ANY PTR
    DIM startIter AS ANY PTR
    DIM endIter AS ANY PTR
    startIter = NewIter()
    endIter = NewIter()
    CALL gtk_text_buffer_get_start_iter(buf.handle, startIter)
    CALL gtk_text_buffer_get_end_iter(buf.handle, endIter)

    DIM rawPtr AS ANY PTR
    rawPtr = gtk_text_buffer_get_text(buf.handle, startIter, endIter, 0)

    CALL FreeIter(startIter)
    CALL FreeIter(endIter)
    TextBufferGetText = rawPtr
END FUNCTION

''' Frees a `g_malloc`'d string returned by TextBufferGetText (or any of
''' this package's other functions with the same "raw ANY PTR, caller
''' frees it" shape - FileChooserGetFilePath, DataInputStreamReadLine/
''' Finish) - exported specifically for this, since raw `g_free` itself
''' isn't part of this package's public `--lib` interface (only real
''' idiomatic-layer SUB/FUNCTION bodies are, never a raw Extern
''' declaration).
SUB FreeGMallocString(rawPtr AS ANY PTR)
    CALL g_free(rawPtr)
END SUB

''' Whether a buffer has unsaved changes since the last TextBufferSetModified(buf, 0)
''' (a fresh buffer, or one just saved, should call that to clear the flag).
FUNCTION TextBufferGetModified(buf AS TextBuffer) AS INTEGER
    TextBufferGetModified = gtk_text_buffer_get_modified(buf.handle)
END FUNCTION

''' Sets/clears the modified flag - call with 0 right after loading or
''' saving a file.
SUB TextBufferSetModified(buf AS TextBuffer, modified AS INTEGER)
    CALL gtk_text_buffer_set_modified(buf.handle, modified)
END SUB

''' Whether GtkTextBuffer's built-in undo manager has anything to undo/redo.
FUNCTION TextBufferGetCanUndo(buf AS TextBuffer) AS INTEGER
    TextBufferGetCanUndo = gtk_text_buffer_get_can_undo(buf.handle)
END FUNCTION

FUNCTION TextBufferGetCanRedo(buf AS TextBuffer) AS INTEGER
    TextBufferGetCanRedo = gtk_text_buffer_get_can_redo(buf.handle)
END FUNCTION

SUB TextBufferUndo(buf AS TextBuffer)
    CALL gtk_text_buffer_undo(buf.handle)
END SUB

SUB TextBufferRedo(buf AS TextBuffer)
    CALL gtk_text_buffer_redo(buf.handle)
END SUB

''' The cursor's current line (0-based) - see this file's own doc comment
''' on why positions are always line/column here, never a raw iterator.
FUNCTION TextBufferGetCursorLine(buf AS TextBuffer) AS INTEGER
    DIM mark AS ANY PTR
    DIM iter AS ANY PTR
    mark = gtk_text_buffer_get_insert(buf.handle)
    iter = NewIter()
    CALL gtk_text_buffer_get_iter_at_mark(buf.handle, iter, mark)
    TextBufferGetCursorLine = gtk_text_iter_get_line(iter)
    CALL FreeIter(iter)
END FUNCTION

''' The cursor's current column (0-based character offset within its line).
FUNCTION TextBufferGetCursorColumn(buf AS TextBuffer) AS INTEGER
    DIM mark AS ANY PTR
    DIM iter AS ANY PTR
    mark = gtk_text_buffer_get_insert(buf.handle)
    iter = NewIter()
    CALL gtk_text_buffer_get_iter_at_mark(buf.handle, iter, mark)
    TextBufferGetCursorColumn = gtk_text_iter_get_line_offset(iter)
    CALL FreeIter(iter)
END FUNCTION

''' Moves the cursor (and clears any selection) to a given line/column.
SUB TextBufferPlaceCursorAt(buf AS TextBuffer, line AS INTEGER, col AS INTEGER)
    DIM iter AS ANY PTR
    iter = NewIter()
    CALL gtk_text_buffer_get_iter_at_line_offset(buf.handle, iter, line, col)
    CALL gtk_text_buffer_place_cursor(buf.handle, iter)
    CALL FreeIter(iter)
END SUB

''' Selects the text between two line/column positions.
SUB TextBufferSelectRange(buf AS TextBuffer, startLine AS INTEGER, startCol AS INTEGER, endLine AS INTEGER, endCol AS INTEGER)
    DIM startIter AS ANY PTR
    DIM endIter AS ANY PTR
    startIter = NewIter()
    endIter = NewIter()
    CALL gtk_text_buffer_get_iter_at_line_offset(buf.handle, startIter, startLine, startCol)
    CALL gtk_text_buffer_get_iter_at_line_offset(buf.handle, endIter, endLine, endCol)
    CALL gtk_text_buffer_select_range(buf.handle, startIter, endIter)
    CALL FreeIter(startIter)
    CALL FreeIter(endIter)
END SUB

' Pango underline styles (real pango enum, docs.gtk.org) - PANGO_UNDERLINE_ERROR
' renders GTK's own recognizable red squiggly underline, the natural
' choice for LSP error diagnostics; the others are exposed for completeness.
CONST PANGO_UNDERLINE_NONE = 0
CONST PANGO_UNDERLINE_SINGLE = 1
CONST PANGO_UNDERLINE_DOUBLE = 2
CONST PANGO_UNDERLINE_LOW = 3
CONST PANGO_UNDERLINE_ERROR = 4

''' Creates a new tag styled with the given Pango underline style (e.g.
''' PANGO_UNDERLINE_ERROR for a diagnostics squiggle) and registers it in
''' `buf`'s own tag table. Returns the raw GtkTextTag handle - pass it to
''' TextBufferApplyTagRange/TextBufferClearTag. See raw/gobject.bas's own
''' doc comment on g_type_from_name for why this goes through GValue/
''' g_object_set_property rather than the real, variadic
''' gtk_text_buffer_create_tag (eBasic has no variadic-call support).
FUNCTION TextBufferCreateUnderlineTag(buf AS TextBuffer, name AS ZSTRING, style AS INTEGER) AS ANY PTR
    DIM tag AS ANY PTR
    tag = gtk_text_tag_new(name)

    DIM gvalue AS ANY PTR
    gvalue = g_malloc0(GLIB_GVALUE_SIZE)
    DIM underlineType AS ULONGINT
    underlineType = g_type_from_name("PangoUnderline")
    CALL g_value_init(gvalue, underlineType)
    CALL g_value_set_enum(gvalue, style)
    CALL g_object_set_property(tag, "underline", gvalue)
    CALL g_value_unset(gvalue)
    CALL g_free(gvalue)

    DIM table AS ANY PTR
    table = gtk_text_buffer_get_tag_table(buf.handle)
    CALL gtk_text_tag_table_add(table, tag)

    TextBufferCreateUnderlineTag = tag
END FUNCTION

''' Applies a tag (from TextBufferCreateUnderlineTag) to a line/column range.
SUB TextBufferApplyTagRange(buf AS TextBuffer, tag AS ANY PTR, startLine AS INTEGER, startCol AS INTEGER, endLine AS INTEGER, endCol AS INTEGER)
    DIM startIter AS ANY PTR
    DIM endIter AS ANY PTR
    startIter = NewIter()
    endIter = NewIter()
    CALL gtk_text_buffer_get_iter_at_line_offset(buf.handle, startIter, startLine, startCol)
    CALL gtk_text_buffer_get_iter_at_line_offset(buf.handle, endIter, endLine, endCol)
    CALL gtk_text_buffer_apply_tag(buf.handle, tag, startIter, endIter)
    CALL FreeIter(startIter)
    CALL FreeIter(endIter)
END SUB

''' Removes a tag from the buffer's entire content - e.g. to clear all
''' previous diagnostics squiggles before re-applying a fresh set.
SUB TextBufferClearTag(buf AS TextBuffer, tag AS ANY PTR)
    DIM startIter AS ANY PTR
    DIM endIter AS ANY PTR
    startIter = NewIter()
    endIter = NewIter()
    CALL gtk_text_buffer_get_start_iter(buf.handle, startIter)
    CALL gtk_text_buffer_get_end_iter(buf.handle, endIter)
    CALL gtk_text_buffer_remove_tag(buf.handle, tag, startIter, endIter)
    CALL FreeIter(startIter)
    CALL FreeIter(endIter)
END SUB

''' See WrapWidget's own doc comment.
FUNCTION WrapTextBuffer(h AS ANY PTR) AS TextBuffer
    DIM b AS TextBuffer
    b.handle = h
    WrapTextBuffer = b
END FUNCTION

''' Creates a new, empty GtkTextView with its own freshly-created buffer
''' (see TextViewGetBuffer/SetBuffer to use a specific one instead).
FUNCTION NewTextView() AS TextView
    DIM v AS TextView
    v.handle = SinkHandle(gtk_text_view_new())
    NewTextView = v
END FUNCTION

''' Reads a view's current buffer - a borrowed reference (the view owns
''' it), matching WrapWidget's own "no new SinkHandle" convention.
FUNCTION TextViewGetBuffer(view AS TextView) AS TextBuffer
    TextViewGetBuffer = WrapTextBuffer(gtk_text_view_get_buffer(view.handle))
END FUNCTION

''' Attaches a buffer to a view (e.g. one created via NewTextBuffer,
''' possibly shared with GtkSourceView machinery - see sourceview.bas).
SUB TextViewSetBuffer(view AS TextView, buf AS TextBuffer)
    CALL gtk_text_view_set_buffer(view.handle, buf.handle)
END SUB

''' Selects a monospace font - always wanted for a code editor.
SUB TextViewSetMonospace(view AS TextView, monospace AS INTEGER)
    CALL gtk_text_view_set_monospace(view.handle, monospace)
END SUB

''' Toggles whether the view's text can be edited (0 for a read-only
''' output/diagnostics panel).
SUB TextViewSetEditable(view AS TextView, editable AS INTEGER)
    CALL gtk_text_view_set_editable(view.handle, editable)
END SUB

''' Sets line-wrapping behavior - see GTK_WRAP_* in raw/gtk_text.bas.
SUB TextViewSetWrapMode(view AS TextView, mode AS INTEGER)
    CALL gtk_text_view_set_wrap_mode(view.handle, mode)
END SUB

''' See WrapWidget's own doc comment.
FUNCTION WrapTextView(h AS ANY PTR) AS TextView
    DIM v AS TextView
    v.handle = h
    WrapTextView = v
END FUNCTION
