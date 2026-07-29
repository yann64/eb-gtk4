' Idiomatic layer: GtkGrid.

#include once "widget.bas"
#include once "raw/gtk_grid.bas"

''' A GtkGrid - a row/column layout container.
TYPE Grid EXTENDS Widget
END TYPE

''' Creates a new, empty GtkGrid.
FUNCTION NewGrid() AS Grid
    DIM g AS Grid
    g.handle = SinkHandle(gtk_grid_new())
    NewGrid = g
END FUNCTION

''' Places a child widget at (column, row), spanning (width, height)
''' cells.
SUB GridAttach(grid AS Grid, child AS Widget, column AS INTEGER, row AS INTEGER, width AS INTEGER, height AS INTEGER)
    CALL gtk_grid_attach(grid.handle, child.handle, column, row, width, height)
END SUB

''' See WrapWidget's own doc comment.
FUNCTION WrapGrid(h AS ANY PTR) AS Grid
    DIM g AS Grid
    g.handle = h
    WrapGrid = g
END FUNCTION
