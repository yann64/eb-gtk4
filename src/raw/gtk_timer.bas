' Raw FFI layer: this package's own small native shim (`ebgtk4shim`),
' not real GTK4/GLib itself - see native/shim_timer.h's own top comment
' for why a persistent Timer object needs a trampoline GLib doesn't
' provide natively.

Extern "C" Lib "ebgtk4shim"
    Declare Function eb_gtk4_timer_create() AS ANY PTR
    Declare Sub eb_gtk4_timer_set_interval(ByVal timer AS ANY PTR, ByVal milliseconds AS UINTEGER)
    Declare Sub eb_gtk4_timer_set_single_shot(ByVal timer AS ANY PTR, ByVal singleShot AS INTEGER)
    Declare Sub eb_gtk4_timer_connect_timeout(ByVal timer AS ANY PTR, ByVal cb AS ANY PTR, ByVal userData AS ANY PTR)
    Declare Sub eb_gtk4_timer_start(ByVal timer AS ANY PTR)
    Declare Sub eb_gtk4_timer_stop(ByVal timer AS ANY PTR)
    Declare Function eb_gtk4_timer_is_active(ByVal timer AS ANY PTR) AS INTEGER
    Declare Sub eb_gtk4_timer_destroy(ByVal timer AS ANY PTR)
End Extern
