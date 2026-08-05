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

''' A GtkSourceCompletion - owns the real completion popup UI
''' (positioning, live filtering-as-you-type, keyboard navigation,
''' insertion) entirely internally; created automatically the first time
''' its GtkSourceView is constructed, never by this package - see
''' SourceViewGetCompletion (a borrowed reference, same convention as
''' TextViewGetBuffer).
TYPE SourceCompletion EXTENDS Obj
END TYPE

''' A GtkSourceCompletionWords - a ready-made completion provider that
''' needs no custom GObject-interface implementation at all: register a
''' plain TextBuffer against it (SourceCompletionWordsRegister) and it
''' offers every distinct word found in that buffer's text as a
''' completion candidate. The registered buffer never needs a display
''' (same "a TextBuffer needs no display to construct or operate on"
''' fact text.bas's own callers already rely on) - a natural place to
''' keep a live, off-screen list of known names (keywords, procedure
''' names, ...) fed from wherever a consumer gets that data (e.g. an LSP
''' client).
TYPE SourceCompletionWords EXTENDS Obj
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

''' Reads a view's completion controller - always already exists (created
''' automatically when the view itself was constructed), a borrowed
''' reference, same convention as TextViewGetBuffer.
FUNCTION SourceViewGetCompletion(view AS SourceView) AS SourceCompletion
    DIM c AS SourceCompletion
    c.handle = gtk_source_view_get_completion(view.handle)
    SourceViewGetCompletion = c
END FUNCTION

''' Attaches a provider (e.g. one created via NewSourceCompletionWords) to
''' a view's completion controller - live-as-you-type completion starts
''' working the moment at least one provider is attached, no separate
''' opt-in call needed.
SUB SourceCompletionAddProvider(comp AS SourceCompletion, words AS SourceCompletionWords)
    CALL gtk_source_completion_add_provider(comp.handle, words.handle)
END SUB

''' Shows the completion popup immediately, regardless of what (if
''' anything) has been typed yet - the usual "show suggestions now"
''' affordance on top of live-as-you-type triggering.
SUB SourceCompletionShow(comp AS SourceCompletion)
    CALL gtk_source_completion_show(comp.handle)
END SUB

''' Creates a new words-based completion provider - `title` is a short,
''' human-readable label for this provider (shown if a consuming app ever
''' displays multiple providers' names; a single-provider app like this
''' one never actually shows it). Register one or more TextBuffers
''' against it via SourceCompletionWordsRegister before attaching it to a
''' view via SourceCompletionAddProvider.
FUNCTION NewSourceCompletionWords(title AS ZSTRING) AS SourceCompletionWords
    DIM w AS SourceCompletionWords
    w.handle = SinkHandle(gtk_source_completion_words_new(title))
    NewSourceCompletionWords = w
END FUNCTION

''' Registers a TextBuffer as a source of candidate words - every distinct
''' word found in its text becomes a completion candidate. The buffer
''' never needs to be shown by any view; a plain NewTextBuffer() used only
''' to hold a known-names list works fine.
SUB SourceCompletionWordsRegister(words AS SourceCompletionWords, buf AS TextBuffer)
    CALL gtk_source_completion_words_register(words.handle, buf.handle)
END SUB
