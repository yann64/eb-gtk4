' Smoke test: exercises plain-path file I/O (fileio.bas) - display-
' independent (real filesystem access, no GTK/display involved at all),
' so this runs safely under `ebpm test`.

#include once "../src/lib.bas"

DIM path AS STRING
path = "/tmp/eb_gtk4_fileio_smoke_test.txt"

DIM wroteOk AS INTEGER
wroteOk = WriteFileContents(path, "hello from eb-gtk4")
PRINT wroteOk

DIM readOk AS INTEGER
DIM rawContents AS ANY PTR
rawContents = ReadFileContents(path, readOk)
PRINT readOk

DIM viaZstring AS ZSTRING
viaZstring = rawContents
DIM contents AS STRING
contents = viaZstring
CALL FreeGMallocString(rawContents)
PRINT contents

DIM missingOk AS INTEGER
DIM missingContents AS ANY PTR
missingContents = ReadFileContents("/tmp/eb_gtk4_no_such_file_xyz.txt", missingOk)
PRINT missingOk

PRINT "fileio smoke ok"
