' Smoke test: confirms the raw GLib/GObject/GIO/GTK4 declarations really
' link against the installed libraries (not just parse) and the symbol
' signatures/names are correct.
'
' Deliberately calls only display-independent functions (GLib/GObject
' basics, GTK's own version query) - safe in a headless/CI sandbox. Real
' widget construction (gtk_window_new and friends) needs a working GTK4
' display backend; see tests/manual/widget_construction.bas for that,
' verified separately on a real desktop rather than via `ebpm test`.

#include once "../src/lib.bas"

CALL g_main_context_iteration(0, 0)

PRINT "gtk major version:"
PRINT gtk_get_major_version()

DIM app AS GObj PTR
app = gtk_application_new("io.github.yann64.ebgtk4.smoketest", GTK4_APPLICATION_FLAGS_NONE)
CALL g_object_unref(app)

PRINT "raw smoke ok"
