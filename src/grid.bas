' Idiomatic layer: GtkGrid.

#include once "widget.bas"
#include once "raw/gtk_grid.bas"

TYPE Grid EXTENDS Widget
END TYPE

FUNCTION NewGrid() AS Grid
    DIM g AS Grid
    g.handle = SinkHandle(gtk_grid_new())
    NewGrid = g
END FUNCTION

SUB GridAttach(grid AS Grid, child AS Widget, column AS INTEGER, row AS INTEGER, width AS INTEGER, height AS INTEGER)
    CALL gtk_grid_attach(grid.handle, child.handle, column, row, width, height)
END SUB
