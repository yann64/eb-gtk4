' Raw FFI layer: GObject core (`gobject-2.0`).
'
' Mirrors the real C API 1:1 - internal use only. See the idiomatic
' wrapper layer (`src/*.bas`) for the package's real public API.
'
' Every GObject-derived instance (GtkWidget, GtkWindow, GApplication, ...)
' is passed as `ANY PTR` throughout this package, not a distinct opaque
' handle TYPE - GTK/GObject only distinguish instance types at runtime via
' GType anyway (matches how the real C API itself treats an object pointer
' at the ABI level), and eBasic's compiler cannot yet emit the cast a
' typed pointer target needs when the *source* is `ANY PTR` (only the
' reverse direction - a typed pointer assigned/passed into an `ANY PTR`
' slot - compiles, since that direction is a plain, implicit C++
' conversion). Using `ANY PTR` uniformly sidesteps that gap entirely,
' without losing anything: a single opaque handle TYPE would have
' provided no extra compile-time safety over `ANY PTR` here regardless
' (real type safety comes from the idiomatic layer's own wrapper TYPEs -
' see `src/widget.bas`).

Extern "C" Lib "gobject-2.0"
    Declare Function g_object_ref(ByVal obj AS ANY PTR) AS ANY PTR
    Declare Sub g_object_ref_sink(ByVal obj AS ANY PTR)
    Declare Sub g_object_unref(ByVal obj AS ANY PTR)

    ' `c_handler` is a real C function pointer (a `GCallback`) - `ANY PTR`
    ' here matches GCallback's own generic, cast-at-the-call-site
    ' convention (see the language's own `@ProcName` docs).
    Declare Function g_signal_connect_data(ByVal instance AS ANY PTR, ByVal detailed_signal AS ZSTRING, ByVal c_handler AS ANY PTR, ByVal data AS ANY PTR, ByVal destroy_data AS ANY PTR, ByVal connect_flags AS INTEGER) AS ULONGINT
End Extern
