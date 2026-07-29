' Manual verification only - NOT run by `ebpm test`.
'
' Exercises real widget construction (gtk_window_new and friends), which
' needs a working GTK4 display backend. Confirmed (2026-07-29, GTK 4.22.4)
' that gtk_window_new() segfaults even from a minimal, hand-written C
' program in the sandbox this package was developed in - a real GTK4
' display-backend/environment limitation there, not a defect in this
' package's bindings (compile+link of every declared symbol below still
' succeeds either way). Run this by hand on a real desktop to verify.

#include once "../../src/lib.bas"

DIM win AS GObj PTR
win = gtk_window_new()
CALL gtk_window_set_title(win, "smoke")
CALL gtk_window_set_default_size(win, 320, 240)

DIM box AS GObj PTR
box = gtk_box_new(GTK_ORIENTATION_VERTICAL, 6)

DIM lbl AS GObj PTR
lbl = gtk_label_new("hello")
PRINT gtk_label_get_text(lbl)

DIM btn AS GObj PTR
btn = gtk_button_new_with_label("click me")
PRINT gtk_button_get_label(btn)

DIM entry AS GObj PTR
entry = gtk_entry_new()
CALL gtk_editable_set_text(entry, "text")
PRINT gtk_editable_get_text(entry)

DIM grid AS GObj PTR
grid = gtk_grid_new()
CALL gtk_grid_attach(grid, lbl, 0, 0, 1, 1)

CALL gtk_box_append(box, lbl)
CALL gtk_box_append(box, entry)
CALL gtk_box_append(box, btn)
CALL gtk_window_set_child(win, box)

CALL gtk_window_present(win)
CALL gtk_window_destroy(win)

PRINT "widget construction ok"
