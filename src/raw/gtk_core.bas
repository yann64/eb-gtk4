' Raw FFI layer: GTK4 library-level queries (`gtk-4`).
' These don't touch a display backend - safe to call in a headless/CI
' environment, unlike widget construction (see tests/raw_smoke.bas).

Extern "C" Lib "gtk-4"
    Declare Function gtk_get_major_version() AS INTEGER
    Declare Function gtk_get_minor_version() AS INTEGER
    Declare Function gtk_get_micro_version() AS INTEGER
End Extern
