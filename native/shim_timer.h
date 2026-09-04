// eb-gtk4 native shim - the ONLY native code in this otherwise pure-FFI
// package (see this package's own README "Status" section - everything
// else is plain `Extern "C" Lib "gtk-4"` FFI over GLib/GObject/GTK4's
// own stable, OS-independent C ABI).
//
// Real GLib has no persistent, configurable "Timer object" - only
// `g_timeout_add(interval, GSourceFunc, data)`, a fire-and-forget
// primitive whose own callback signature (`gboolean (*)(gpointer)`)
// decides repeat-vs-stop *reactively*, per firing, via its own return
// value. That idiom doesn't map onto a richer "configure interval and
// single-shot up front, Start/Stop independently, callback has no
// return value" object model (the shape eb-qt6's own QTimer already
// has, and the one eb-gui's universal contract adopts to match it) -
// bridging the two needs a real trampoline, the same class of reason
// eb-gui-gtk4 needed one for its own close-callback (eBasic itself has
// no way to call through an arbitrary stored function pointer).
#pragma once

extern "C" {

typedef void (*EbGtk4TimerCallback)(void* userData);

void* eb_gtk4_timer_create();
void eb_gtk4_timer_set_interval(void* timer, unsigned int milliseconds);
void eb_gtk4_timer_set_single_shot(void* timer, int singleShot);
void eb_gtk4_timer_connect_timeout(void* timer, EbGtk4TimerCallback cb, void* userData);
void eb_gtk4_timer_start(void* timer);
void eb_gtk4_timer_stop(void* timer);
int eb_gtk4_timer_is_active(void* timer);
// Stops the timer (if running) and frees it - unlike every other handle
// in this package (GObject-refcounted), a timer is this package's own
// plain heap allocation, not a GObject, so this is the only way to
// release it.
void eb_gtk4_timer_destroy(void* timer);

}
