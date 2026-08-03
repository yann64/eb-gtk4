' Raw FFI layer: GtkTextBuffer/GtkTextView core (`gtk-4`).
'
' `GtkTextIter` is a caller-allocated-by-value struct in the real C API
' (every function taking one expects the caller to own its storage and
' pass its address) - but an eBasic opaque TYPE (zero fields/methods) may
' only ever be used behind a PTR, never by value (see docs/reference/
' extern-interop.md). Rather than replicate GtkTextIter's exact byte
' layout as an eBasic value TYPE (fragile across GTK versions/platforms -
' empirically 80 bytes on GTK 4.22/x86-64 today, per a throwaway `sizeof`
' probe during development), every GtkTextIter this binding ever touches
' is a heap-allocated opaque blob (`g_malloc`'d, comfortably larger than
' any real GtkTextIter) treated as a plain `ANY PTR` handle - exactly like
' every other opaque GObject handle in this package. See gtk_text_iter_*
' below and the idiomatic layer's `NewIter`/`FreeIter`.

#include once "glib.bas"
#include once "gobject.bas"

''' Bytes allocated per `GtkTextIter` - real size is 80 on GTK 4.22/
''' x86-64 (measured via `sizeof`); this is a deliberately generous
''' margin, not a tight fit, so it stays safe across GTK point releases/
''' platforms without needing to be re-measured.
CONST GTK4_TEXT_ITER_SIZE AS INTEGER = 128

' GtkWrapMode (docs.gtk.org) - a code editor wants GTK_WRAP_NONE (no
' wrapping, horizontal scroll instead), but every value is exposed for
' completeness.
CONST GTK_WRAP_NONE = 0
CONST GTK_WRAP_CHAR = 1
CONST GTK_WRAP_WORD = 2
CONST GTK_WRAP_WORD_CHAR = 3

Extern "C" Lib "gtk-4"
    Declare Function gtk_text_buffer_new(ByVal table AS ANY PTR) AS GObj PTR
    Declare Sub gtk_text_buffer_set_text(ByVal buffer AS GObj PTR, ByVal text AS ZSTRING, ByVal len AS INTEGER)
    ' Returns a newly `g_malloc`'d string the caller must `g_free` (unlike
    ' `gtk_editable_get_text`'s borrowed string) - declared `ANY PTR`, not
    ' `ZSTRING`, so `g_free` (see glib.bas) can free it directly with no
    ' bridging at all; the idiomatic layer reads it via eBasic's ANY-PTR
    ' -as-ZSTRING bridge (an `ebc` compiler feature added specifically for
    ' this: a bare ANY PTR value may be read as a ZSTRING, one direction
    ' only - see docs/architecture/roadmap.md's "ANY PTR -> ZSTRING" fix
    ' in the main eBasic repo) before freeing the original ANY PTR value.
    Declare Function gtk_text_buffer_get_text(ByVal buffer AS GObj PTR, ByVal start_iter AS ANY PTR, ByVal end_iter AS ANY PTR, ByVal include_hidden_chars AS INTEGER) AS ANY PTR
    Declare Sub gtk_text_buffer_insert(ByVal buffer AS GObj PTR, ByVal iter AS ANY PTR, ByVal text AS ZSTRING, ByVal len AS INTEGER)
    Declare Sub gtk_text_buffer_delete(ByVal buffer AS GObj PTR, ByVal start_iter AS ANY PTR, ByVal end_iter AS ANY PTR)
    Declare Sub gtk_text_buffer_get_start_iter(ByVal buffer AS GObj PTR, ByVal iter AS ANY PTR)
    Declare Sub gtk_text_buffer_get_end_iter(ByVal buffer AS GObj PTR, ByVal iter AS ANY PTR)
    Declare Sub gtk_text_buffer_get_bounds(ByVal buffer AS GObj PTR, ByVal start_iter AS ANY PTR, ByVal end_iter AS ANY PTR)
    Declare Sub gtk_text_buffer_get_iter_at_offset(ByVal buffer AS GObj PTR, ByVal iter AS ANY PTR, ByVal char_offset AS INTEGER)
    Declare Sub gtk_text_buffer_get_iter_at_line_offset(ByVal buffer AS GObj PTR, ByVal iter AS ANY PTR, ByVal line_number AS INTEGER, ByVal char_offset AS INTEGER)
    Declare Function gtk_text_buffer_get_modified(ByVal buffer AS GObj PTR) AS INTEGER
    Declare Sub gtk_text_buffer_set_modified(ByVal buffer AS GObj PTR, ByVal setting AS INTEGER)
    Declare Sub gtk_text_buffer_place_cursor(ByVal buffer AS GObj PTR, ByVal iter AS ANY PTR)
    Declare Function gtk_text_buffer_get_insert(ByVal buffer AS GObj PTR) AS ANY PTR
    Declare Sub gtk_text_buffer_get_iter_at_mark(ByVal buffer AS GObj PTR, ByVal iter AS ANY PTR, ByVal mark AS ANY PTR)
    Declare Sub gtk_text_buffer_select_range(ByVal buffer AS GObj PTR, ByVal ins_iter AS ANY PTR, ByVal bound_iter AS ANY PTR)
    Declare Function gtk_text_buffer_get_selection_bounds(ByVal buffer AS GObj PTR, ByVal start_iter AS ANY PTR, ByVal end_iter AS ANY PTR) AS INTEGER
    Declare Function gtk_text_buffer_get_can_undo(ByVal buffer AS GObj PTR) AS INTEGER
    Declare Function gtk_text_buffer_get_can_redo(ByVal buffer AS GObj PTR) AS INTEGER
    Declare Sub gtk_text_buffer_undo(ByVal buffer AS GObj PTR)
    Declare Sub gtk_text_buffer_redo(ByVal buffer AS GObj PTR)

    ' GtkTextTag/GtkTextTagTable - see text.bas's TextBufferCreateUnderlineTag
    ' for why properties are set via GValue/g_object_set_property (raw/
    ' gobject.bas) rather than the real, variadic gtk_text_buffer_create_tag.
    Declare Function gtk_text_tag_new(ByVal name AS ZSTRING) AS GObj PTR
    Declare Function gtk_text_buffer_get_tag_table(ByVal buffer AS GObj PTR) AS GObj PTR
    Declare Function gtk_text_tag_table_add(ByVal table AS GObj PTR, ByVal tag AS GObj PTR) AS INTEGER
    Declare Sub gtk_text_buffer_apply_tag(ByVal buffer AS GObj PTR, ByVal tag AS GObj PTR, ByVal start_iter AS ANY PTR, ByVal end_iter AS ANY PTR)
    Declare Sub gtk_text_buffer_remove_tag(ByVal buffer AS GObj PTR, ByVal tag AS GObj PTR, ByVal start_iter AS ANY PTR, ByVal end_iter AS ANY PTR)

    Declare Function gtk_text_iter_get_line(ByVal iter AS ANY PTR) AS INTEGER
    Declare Function gtk_text_iter_get_line_offset(ByVal iter AS ANY PTR) AS INTEGER
    Declare Function gtk_text_iter_get_offset(ByVal iter AS ANY PTR) AS INTEGER

    Declare Function gtk_text_view_new() AS GObj PTR
    Declare Function gtk_text_view_get_buffer(ByVal text_view AS GObj PTR) AS GObj PTR
    Declare Sub gtk_text_view_set_buffer(ByVal text_view AS GObj PTR, ByVal buffer AS GObj PTR)
    Declare Sub gtk_text_view_set_monospace(ByVal text_view AS GObj PTR, ByVal monospace AS INTEGER)
    Declare Sub gtk_text_view_set_editable(ByVal text_view AS GObj PTR, ByVal setting AS INTEGER)
    Declare Sub gtk_text_view_set_wrap_mode(ByVal text_view AS GObj PTR, ByVal wrap_mode AS INTEGER)
End Extern
