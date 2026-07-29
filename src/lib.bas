' eb-gtk4: a GTK4 wrapper library for eBasic.
'
' Aggregates the raw FFI layer and the idiomatic wrapper layer into one
' #include. Consumers only ever #include this file's own generated
' interface (target/gtk4.iface.bas, after `ebpm build`).

#include once "raw/glib.bas"
#include once "raw/gobject.bas"
#include once "raw/gio.bas"
#include once "raw/gtk_core.bas"
#include once "raw/gtk_orientable.bas"
#include once "raw/gtk_widget.bas"
#include once "raw/gtk_window.bas"
#include once "raw/gtk_box.bas"
#include once "raw/gtk_grid.bas"
#include once "raw/gtk_button.bas"
#include once "raw/gtk_label.bas"
#include once "raw/gtk_entry.bas"
#include once "raw/gtk_application.bas"

#include once "widget.bas"
#include once "application.bas"
#include once "window.bas"
#include once "box.bas"
#include once "grid.bas"
#include once "button.bas"
#include once "label.bas"
#include once "entry.bas"
