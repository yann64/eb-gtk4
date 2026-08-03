' Raw FFI layer: GObject core (`gobject-2.0`).
'
' Mirrors the real C API 1:1 - internal use only. See the idiomatic
' wrapper layer (`src/*.bas`) for the package's real public API.

''' Opaque handle for any GObject-derived instance (GtkWidget, GtkWindow,
''' GApplication, ...). GTK/GObject only distinguish instance types at
''' runtime via GType, so one opaque pointer type covers every object -
''' matches how the real C API itself treats an object pointer at the ABI
''' level; the idiomatic layer builds real eBasic-side type safety on top
''' via composition (see `src/widget.bas`), not one opaque type per class.
TYPE GObj
END TYPE

''' Bytes allocated per `GValue` - real size is 24 on GTK 4.22/x86-64
''' (measured via `sizeof`); like GTK4_TEXT_ITER_SIZE, a deliberately
''' generous margin so it stays safe across GLib point releases/platforms.
CONST GLIB_GVALUE_SIZE AS INTEGER = 64

Extern "C" Lib "gobject-2.0"
    Declare Function g_object_ref(ByVal obj AS GObj PTR) AS GObj PTR
    Declare Sub g_object_ref_sink(ByVal obj AS GObj PTR)
    Declare Sub g_object_unref(ByVal obj AS GObj PTR)

    ' `c_handler` is a real C function pointer (a `GCallback`) and `data`/
    ' `destroy_data` are genuinely arbitrary user context - both stay
    ' `ANY PTR` (not `GObj PTR`, they're never a GObject instance
    ' themselves), matching GCallback's own generic, cast-at-the-call-site
    ' convention (see the language's own `@ProcName` docs).
    Declare Function g_signal_connect_data(ByVal instance AS GObj PTR, ByVal detailed_signal AS ZSTRING, ByVal c_handler AS ANY PTR, ByVal data AS ANY PTR, ByVal destroy_data AS ANY PTR, ByVal connect_flags AS INTEGER) AS ULONGINT

    ' Looks up a registered GType by its C name (e.g. "PangoUnderline") -
    ' the only non-variadic way to discover a dynamically-registered enum/
    ' boxed type's GType at runtime. eBasic has no variadic-call support,
    ' so `gtk_text_buffer_create_tag`-style "name, first_property, ..."
    ' APIs can't be called directly - g_type_from_name + a GValue (below)
    ' + g_object_set_property is the non-variadic equivalent this package
    ' uses instead (see text.bas's TextBufferCreateUnderlineTag).
    Declare Function g_type_from_name(ByVal name AS ZSTRING) AS ULONGINT
    ' Real signature returns the same GValue* passed in - ignored here
    ' (Sub), matching this file's own g_object_ref_sink precedent. `value`
    ' must point at zeroed memory (see g_malloc0 in raw/glib.bas).
    Declare Sub g_value_init(ByVal value AS ANY PTR, ByVal g_type AS ULONGINT)
    Declare Sub g_value_set_enum(ByVal value AS ANY PTR, ByVal v_enum AS INTEGER)
    Declare Sub g_value_set_string(ByVal value AS ANY PTR, ByVal v_string AS ZSTRING)
    Declare Sub g_value_unset(ByVal value AS ANY PTR)
    ' The non-variadic counterpart of g_object_set - sets exactly one
    ' property from a pre-built GValue.
    Declare Sub g_object_set_property(ByVal object_ AS GObj PTR, ByVal property_name AS ZSTRING, ByVal value AS ANY PTR)
End Extern
