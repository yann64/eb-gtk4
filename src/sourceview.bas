' Idiomatic layer: GtkSourceView (syntax-highlighted text editing).
'
' SourceView EXTENDS TextView and SourceBuffer EXTENDS TextBuffer (real
' GtkSourceView/GtkSourceBuffer subclassing, mirrored here) - every
' function in text.bas (TextBufferGetText/SetText, cursor/selection
' helpers, ...) already works on a SourceBuffer value directly, and a
' SourceView is usable anywhere a Widget is expected (e.g.
' ScrolledWindowSetChild). No separate Source-prefixed text-access
' functions are added here - text.bas's own already cover it.

#include once "text.bas"
#include once "raw/gtksourceview.bas"

TYPE SourceView EXTENDS TextView
END TYPE

TYPE SourceBuffer EXTENDS TextBuffer
END TYPE

''' A GtkSourceLanguage - always a *borrowed* reference from
''' SourceLanguageManagerGetLanguage (owned by the language manager's own
''' cache, never freed by this package) - EXTENDS Obj (not Widget; it's
''' not a widget at all). A "no such language" result has `.handle = 0`,
''' directly checkable (this language has no OOP encapsulation yet, so
''' every field is already public).
TYPE SourceLanguage EXTENDS Obj
END TYPE

''' A GtkSourceStyleScheme - likewise always a borrowed reference, `.handle
''' = 0` for "no such scheme".
TYPE SourceStyleScheme EXTENDS Obj
END TYPE

''' The process-wide language manager singleton - see
''' SourceLanguageManagerGetDefault.
TYPE SourceLanguageManager EXTENDS Obj
END TYPE

''' The process-wide style-scheme manager singleton - see
''' SourceStyleSchemeManagerGetDefault.
TYPE SourceStyleSchemeManager EXTENDS Obj
END TYPE

''' Creates a new GtkSourceView with its own fresh GtkSourceBuffer - see
''' NewSourceViewWithBuffer to attach a specific buffer instead (e.g. one
''' already configured with a language/style scheme).
FUNCTION NewSourceView() AS SourceView
    DIM v AS SourceView
    v.handle = SinkHandle(gtk_source_view_new())
    NewSourceView = v
END FUNCTION

''' Creates a new GtkSourceView attached to a specific SourceBuffer.
FUNCTION NewSourceViewWithBuffer(buf AS SourceBuffer) AS SourceView
    DIM v AS SourceView
    v.handle = SinkHandle(gtk_source_view_new_with_buffer(buf.handle))
    NewSourceViewWithBuffer = v
END FUNCTION

''' Shows/hides the line-number gutter.
SUB SourceViewSetShowLineNumbers(view AS SourceView, show AS INTEGER)
    CALL gtk_source_view_set_show_line_numbers(view.handle, show)
END SUB

''' Highlights the line the cursor is currently on.
SUB SourceViewSetHighlightCurrentLine(view AS SourceView, highlight AS INTEGER)
    CALL gtk_source_view_set_highlight_current_line(view.handle, highlight)
END SUB

''' Sets the visual width of a tab character, in spaces.
SUB SourceViewSetTabWidth(view AS SourceView, width AS INTEGER)
    CALL gtk_source_view_set_tab_width(view.handle, width)
END SUB

''' Whether pressing Tab inserts spaces instead of a literal tab character.
SUB SourceViewSetInsertSpacesInsteadOfTabs(view AS SourceView, enable AS INTEGER)
    CALL gtk_source_view_set_insert_spaces_instead_of_tabs(view.handle, enable)
END SUB

''' Whether a new line auto-indents to match the previous one.
SUB SourceViewSetAutoIndent(view AS SourceView, enable AS INTEGER)
    CALL gtk_source_view_set_auto_indent(view.handle, enable)
END SUB

''' See WrapWidget's own doc comment.
FUNCTION WrapSourceView(h AS ANY PTR) AS SourceView
    DIM v AS SourceView
    v.handle = h
    WrapSourceView = v
END FUNCTION

''' Creates a new, empty GtkSourceBuffer with no language set yet (CALL
''' SourceBufferSetLanguage next - or use NewSourceBufferWithLanguage).
FUNCTION NewSourceBuffer() AS SourceBuffer
    DIM b AS SourceBuffer
    b.handle = SinkHandle(gtk_source_buffer_new(0))
    NewSourceBuffer = b
END FUNCTION

''' Creates a new GtkSourceBuffer with a language already set (its own
''' syntax-highlighting definition - see SourceLanguageManagerGetLanguage).
FUNCTION NewSourceBufferWithLanguage(lang AS SourceLanguage) AS SourceBuffer
    DIM b AS SourceBuffer
    b.handle = SinkHandle(gtk_source_buffer_new_with_language(lang.handle))
    NewSourceBufferWithLanguage = b
END FUNCTION

''' Sets/changes a buffer's language (its syntax-highlighting definition).
SUB SourceBufferSetLanguage(buf AS SourceBuffer, lang AS SourceLanguage)
    CALL gtk_source_buffer_set_language(buf.handle, lang.handle)
END SUB

''' Reads a buffer's current language - a "none set" result has
''' `.handle = 0`, same borrowed-reference convention as
''' SourceLanguageManagerGetLanguage.
FUNCTION SourceBufferGetLanguage(buf AS SourceBuffer) AS SourceLanguage
    DIM lang AS SourceLanguage
    lang.handle = gtk_source_buffer_get_language(buf.handle)
    SourceBufferGetLanguage = lang
END FUNCTION

''' Sets a buffer's color scheme (see SourceStyleSchemeManagerGetScheme).
SUB SourceBufferSetStyleScheme(buf AS SourceBuffer, scheme AS SourceStyleScheme)
    CALL gtk_source_buffer_set_style_scheme(buf.handle, scheme.handle)
END SUB

''' Toggles syntax highlighting on/off entirely.
SUB SourceBufferSetHighlightSyntax(buf AS SourceBuffer, highlight AS INTEGER)
    CALL gtk_source_buffer_set_highlight_syntax(buf.handle, highlight)
END SUB

''' See WrapWidget's own doc comment.
FUNCTION WrapSourceBuffer(h AS ANY PTR) AS SourceBuffer
    DIM b AS SourceBuffer
    b.handle = h
    WrapSourceBuffer = b
END FUNCTION

''' The process-wide GtkSourceLanguageManager - append your own custom
''' `.lang` directory to it (SourceLanguageManagerAppendSearchPath) before
''' looking up a language that isn't one of GtkSourceView's own built-in
''' ones (e.g. eBasic's own, shipped separately from this package).
FUNCTION SourceLanguageManagerGetDefault() AS SourceLanguageManager
    DIM m AS SourceLanguageManager
    m.handle = gtk_source_language_manager_get_default()
    SourceLanguageManagerGetDefault = m
END FUNCTION

''' Adds `path` to the manager's search path for `.lang` files - additive,
''' does not replace the built-in search path GtkSourceView ships with.
SUB SourceLanguageManagerAppendSearchPath(mgr AS SourceLanguageManager, path AS ZSTRING)
    CALL gtk_source_language_manager_append_search_path(mgr.handle, path)
END SUB

''' Looks up a language by its `.lang` file's own `id` (e.g. "ebasic") -
''' the result's `.handle` is 0 if no such language is known.
FUNCTION SourceLanguageManagerGetLanguage(mgr AS SourceLanguageManager, id AS ZSTRING) AS SourceLanguage
    DIM lang AS SourceLanguage
    lang.handle = gtk_source_language_manager_get_language(mgr.handle, id)
    SourceLanguageManagerGetLanguage = lang
END FUNCTION

''' The process-wide GtkSourceStyleSchemeManager.
FUNCTION SourceStyleSchemeManagerGetDefault() AS SourceStyleSchemeManager
    DIM m AS SourceStyleSchemeManager
    m.handle = gtk_source_style_scheme_manager_get_default()
    SourceStyleSchemeManagerGetDefault = m
END FUNCTION

''' Looks up a built-in color scheme by id (e.g. "classic", "solarized-dark")
''' - the result's `.handle` is 0 if no such scheme is known.
FUNCTION SourceStyleSchemeManagerGetScheme(mgr AS SourceStyleSchemeManager, schemeId AS ZSTRING) AS SourceStyleScheme
    DIM s AS SourceStyleScheme
    s.handle = gtk_source_style_scheme_manager_get_scheme(mgr.handle, schemeId)
    SourceStyleSchemeManagerGetScheme = s
END FUNCTION
