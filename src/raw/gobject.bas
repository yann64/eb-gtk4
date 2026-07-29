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
End Extern
