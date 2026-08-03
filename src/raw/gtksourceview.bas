' Raw FFI layer: GtkSourceView core (`gtksourceview-5`).
'
' GtkSourceView/GtkSourceBuffer are real GtkTextView/GtkTextBuffer
' subclasses - a `GObj PTR` from here is fully substitutable wherever
' raw/gtk_text.bas's own functions expect one (matching this whole
' package's "one opaque pointer type per instance, real type safety only
' at the idiomatic layer" convention). Symbol names confirmed directly
' against the installed library (`nm -D libgtksourceview-5.so.0`), not
' just recalled from memory, since this is a newer/less-documented
' library than core GTK4.

#include once "gobject.bas"

Extern "C" Lib "gtksourceview-5"
    Declare Function gtk_source_view_new() AS GObj PTR
    Declare Function gtk_source_view_new_with_buffer(ByVal buffer AS GObj PTR) AS GObj PTR
    Declare Sub gtk_source_view_set_show_line_numbers(ByVal view AS GObj PTR, ByVal show AS INTEGER)
    Declare Sub gtk_source_view_set_highlight_current_line(ByVal view AS GObj PTR, ByVal highlight AS INTEGER)
    Declare Sub gtk_source_view_set_tab_width(ByVal view AS GObj PTR, ByVal width AS UINTEGER)
    Declare Sub gtk_source_view_set_insert_spaces_instead_of_tabs(ByVal view AS GObj PTR, ByVal enable AS INTEGER)
    Declare Sub gtk_source_view_set_auto_indent(ByVal view AS GObj PTR, ByVal enable AS INTEGER)

    ' `table` (a GtkTextTagTable*) is 0/NULL for the common case - a fresh
    ' tag table is created automatically.
    Declare Function gtk_source_buffer_new(ByVal table AS ANY PTR) AS GObj PTR
    Declare Function gtk_source_buffer_new_with_language(ByVal language AS GObj PTR) AS GObj PTR
    Declare Sub gtk_source_buffer_set_language(ByVal buffer AS GObj PTR, ByVal language AS GObj PTR)
    Declare Function gtk_source_buffer_get_language(ByVal buffer AS GObj PTR) AS GObj PTR
    Declare Sub gtk_source_buffer_set_style_scheme(ByVal buffer AS GObj PTR, ByVal scheme AS GObj PTR)
    Declare Sub gtk_source_buffer_set_highlight_syntax(ByVal buffer AS GObj PTR, ByVal highlight AS INTEGER)

    ' The language/style-scheme managers are process-wide singletons -
    ' `get_default` returns a borrowed reference the caller never owns/
    ' frees (matching this package's existing WrapWidget-style "just
    ' naming a handle" convention, never SinkHandle'd).
    Declare Function gtk_source_language_manager_get_default() AS GObj PTR
    Declare Sub gtk_source_language_manager_append_search_path(ByVal manager AS GObj PTR, ByVal path AS ZSTRING)
    ' Returns a borrowed GtkSourceLanguage*, or NULL (a 0 handle, directly
    ' checkable - see SourceLanguage's own doc comment) if `id` isn't a
    ' known language.
    Declare Function gtk_source_language_manager_get_language(ByVal manager AS GObj PTR, ByVal id AS ZSTRING) AS GObj PTR

    Declare Function gtk_source_style_scheme_manager_get_default() AS GObj PTR
    Declare Function gtk_source_style_scheme_manager_get_scheme(ByVal manager AS GObj PTR, ByVal scheme_id AS ZSTRING) AS GObj PTR
End Extern
