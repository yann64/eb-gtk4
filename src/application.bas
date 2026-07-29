' Idiomatic layer: GtkApplication (a GApplication - never a GtkWidget, so
' this extends Obj directly, not Widget).

#include once "widget.bas"
#include once "raw/gio.bas"
#include once "raw/gtk_application.bas"

TYPE Application EXTENDS Obj
END TYPE

FUNCTION NewApplication(application_id AS ZSTRING) AS Application
    DIM app AS Application
    app.handle = SinkHandle(gtk_application_new(application_id, GTK4_APPLICATION_FLAGS_NONE))
    NewApplication = app
END FUNCTION

FUNCTION ApplicationRun(app AS Application) AS INTEGER
    ApplicationRun = g_application_run(app.handle, 0, 0)
END FUNCTION
