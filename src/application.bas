' Idiomatic layer: GtkApplication (a GApplication - never a GtkWidget, so
' this extends Obj directly, not Widget).

#include once "widget.bas"
#include once "raw/gio.bas"
#include once "raw/gtk_application.bas"

''' A GtkApplication (owns the app's main loop and lifecycle - see
''' ApplicationRun).
TYPE Application EXTENDS Obj
END TYPE

''' Creates a new GtkApplication with the given application ID (a
''' reverse-DNS-style string, e.g. "io.github.you.yourapp").
FUNCTION NewApplication(application_id AS ZSTRING) AS Application
    DIM app AS Application
    app.handle = SinkHandle(gtk_application_new(application_id, GTK4_APPLICATION_FLAGS_NONE))
    NewApplication = app
END FUNCTION

''' Runs the application's main loop until it exits - connect to the
''' "activate" signal (via ObjConnect) first to build your UI.
FUNCTION ApplicationRun(app AS Application) AS INTEGER
    ApplicationRun = g_application_run(app.handle, 0, 0)
END FUNCTION

''' See WrapWidget's own doc comment - same idea, for the "activate"
''' signal handler's own `app AS ANY PTR` parameter.
FUNCTION WrapApplication(h AS ANY PTR) AS Application
    DIM app AS Application
    app.handle = h
    WrapApplication = app
END FUNCTION
