# eb-gtk4

A GTK4 wrapper library for [eBasic](https://github.com/yann64/ebasic),
managed with `ebpm`.

## Status

Early development. Linux-first. Two layers:

- **Raw layer** (`src/raw/`) - flat `Extern "C" Lib "..."` declarations
  mirroring GLib/GObject/GIO and GTK4's core widgets 1:1. Internal use
  only.
- **Idiomatic layer** (`src/*.bas`) - the package's real public API: plain
  eBasic `TYPE`s (`Widget`, `Window`, `Box`, `Grid`, `Button`, `Label`,
  `Entry`, `Application`, `TextBuffer`, `TextView`, `ScrolledWindow`,
  `SourceView`/`SourceBuffer` (real `GtkTextView`/`GtkTextBuffer`
  subclasses - `EXTENDS TextView`/`TextBuffer`, so every `TextBuffer`/
  `TextView` function already works on them), `SourceLanguage`/
  `SourceLanguageManager`/`SourceStyleScheme`/`SourceStyleSchemeManager`,
  `SubprocessLauncher`/`Subprocess`/`InputStream`/`OutputStream`/
  `DataInputStream`, `HeaderBar`, `Paned`, `ListBox`/`ListBoxRow`,
  `FileChooserNative`, `EventControllerKey`, each `EXTENDS`-chained from a
  common `Obj` base) plus free functions operating on them (`NewButton`,
  `ButtonSetLabel`, `WidgetShow`, `ObjConnect` for signals,
  `TextBufferGetText`/`SetText`, `SourceBufferSetLanguage`,
  `SubprocessLauncherSpawnv`, `ListBoxAppend`, `ReadFileContents`/
  `WriteFileContents`, ...).

**Free functions, not methods** - an eBasic `TYPE`'s own methods aren't
exported across an `ebpm --lib` package boundary yet (only top-level
`SUB`/`FUNCTION` and plain-data/opaque `TYPE`/`UNION` are), so the public
API is `CALL ButtonSetLabel(myButton, "text")`, not
`myButton.SetLabel("text")`.

**`ZSTRING`, not `STRING`, for text** - a `STRING`-returning top-level
function isn't exported across the same boundary yet either, so every
text-carrying parameter/return in this package's public API uses
`ZSTRING` (a plain `const char*`) instead. This applies even when a
function only *internally* builds a `STRING` before returning it - the
function's own declared return *type* is what's excluded, regardless of
how safely it's computed inside. A real bug from exactly this
(`TextBufferGetText`/`FileChooserGetFilePath`/`DataInputStreamReadLine`/
`Finish` were all originally declared `AS STRING`, silently unusable by
any external consumer - found the moment a real downstream package
(`ebasic-editor`) tried to call one) is now fixed: each returns the raw
`ANY PTR` allocation instead, freed via the newly exported
`FreeGMallocString` once the caller has read it through eBasic's own
ANY-PTR-as-`ZSTRING` bridge.

## Building

```sh
ebpm build
ebpm test
```

Requires GTK4 and GtkSourceView 5 development libraries installed and
discoverable by the linker's default search path (works out of the box on
Linux; `pkg-config --libs gtk4 gtksourceview-5` should list `-lgtk-4` and
`-lgtksourceview-5` among others).

`ebpm test` only exercises display-independent functionality - see
`tests/manual/widget_construction.bas` for a real-widget-construction
check that needs an actual GTK4 display backend to run (verified to
compile cleanly; not run automatically).

## Using as a dependency

```toml
[target.linux.dependencies]
gtk4 = { git = "https://github.com/yann64/eb-gtk4.git" }
```

```basic
#ifdef __FB_LINUX__
    #include "gtk4.iface.bas"
#endif

DIM win AS Window
win = NewWindow()
CALL WindowSetTitle(win, "Hello")
CALL WindowSetDefaultSize(win, 320, 240)

DIM btn AS Button
btn = NewButton("Click me")
CALL WindowSetChild(win, btn)
CALL WindowPresent(win)
```

Requires `ebc`/`ebpm` built from a version including several upstream
fixes this package depends on, all found and fixed while building it (see
[yann64/ebasic](https://github.com/yann64/ebasic)'s roadmap for each):
`@ProcName` (function pointers for signal callbacks); `ebpm` forwarding a
dependency's own `Lib "name"` clauses transitively; `--lib` exporting a
derived (`EXTENDS`) `TYPE` and top-level `CONST`/`ENUM`; `ANY PTR`
correctly casting into a typed `PTR` (what lets this package use a single
opaque `GObj` handle type throughout, restoring real "is this even a
GObject-family pointer" type checking at the raw FFI layer, rather than
`ANY PTR` everywhere accepting any pointer at all); `ANY PTR` bridging to
`ZSTRING` (what lets `TextBufferGetText` safely free
`gtk_text_buffer_get_text`'s `g_malloc`'d return without leaking it - the
first binding here that gets back a string it must free itself, rather
than a borrowed one); and a real dangling-pointer bug where a string
literal assigned to a `ZSTRING` variable/array element outliving its own
statement (e.g. `DIM argv(n) AS ZSTRING` built up across several
statements for `GSubprocess`) used to silently corrupt.

## Signals

```basic
SUB OnClicked(btn AS GObj PTR, data AS ANY PTR)
    PRINT "clicked"
END SUB

CALL ObjConnect(myButton, "clicked", @OnClicked, 0)
```

`@ProcName` (a top-level, non-`Extern`, non-method `SUB`/`FUNCTION`) takes
a real C function pointer, usable as `ObjConnect`'s `handler` argument -
see eBasic's own `@ProcName` docs for the C-ABI-compatibility rules this
implies (no `STRING` parameters/return; use `ZSTRING`).

## Syntax highlighting

```basic
DIM langMgr AS SourceLanguageManager
langMgr = SourceLanguageManagerGetDefault()
DIM lang AS SourceLanguage
lang = SourceLanguageManagerGetLanguage(langMgr, "python3")

DIM buf AS SourceBuffer
buf = NewSourceBufferWithLanguage(lang)
CALL SourceBufferSetHighlightSyntax(buf, 1)
CALL TextBufferSetText(buf, "print(""hello"")")

DIM view AS SourceView
view = NewSourceViewWithBuffer(buf)
CALL SourceViewSetShowLineNumbers(view, 1)
```

`SourceLanguageManagerGetLanguage`/`SourceStyleSchemeManagerGetScheme`
return a value whose `.handle` is `0` if the given id isn't known - check
directly (this language has no OOP encapsulation yet, so every `TYPE`
field is already public). To highlight a language GtkSourceView doesn't
ship built in, add your own `.lang` file's directory via
`SourceLanguageManagerAppendSearchPath` before looking it up.

## Streaming output panels

```basic
DIM outputBuf AS TextBuffer
outputBuf = NewTextBuffer()
CALL TextBufferAppendLine(outputBuf, "$ ebpm build")
CALL TextBufferAppendLine(outputBuf, "   Compiling myapp (bin)")
```

`TextBufferAppendLine` appends a line plus a real trailing newline
without rewriting the buffer's whole content (unlike `TextBufferSetText`)
- the natural fit for a read-only panel showing a spawned tool's output
one line at a time, e.g. reading `ebpm build`'s stdout via
`DataInputStreamReadLineAsync` and appending each line as it arrives.

## Subprocesses

```basic
DIM launcher AS SubprocessLauncher
launcher = NewSubprocessLauncher(G_SUBPROCESS_FLAGS_STDOUT_PIPE)

DIM argv(2) AS ZSTRING
argv(0) = "echo"
argv(1) = "hello"
' argv(2) stays unassigned - a real, correctly NUL-terminated char**
' falls out for free (see raw/gsubprocess.bas's own doc comment). Get
' this element count wrong (e.g. DIM argv(1), leaving no unassigned
' slot at all) and the missing NUL terminator is a real, silent
' out-of-bounds read - confirmed by direct reproduction (a segfault).

DIM sp AS Subprocess
sp = SubprocessLauncherSpawnv(launcher, @argv(0))

DIM outPipe AS InputStream
outPipe = SubprocessGetStdoutPipe(sp)
DIM lineReader AS DataInputStream
lineReader = NewDataInputStream(outPipe)

DIM gotLine AS INTEGER
DIM rawLine AS ANY PTR
rawLine = DataInputStreamReadLine(lineReader, gotLine)   ' blocking - fine for a short-lived command
DIM viaZstring AS ZSTRING
viaZstring = rawLine
DIM line AS STRING
line = viaZstring
CALL FreeGMallocString(rawLine)
PRINT line

CALL SubprocessWait(sp)
PRINT SubprocessGetExitStatus(sp)
```

The one subprocess primitive this package exposes - real, portable
(Linux/macOS/Windows), GLib-main-loop-integrated process spawning via
`GSubprocess`, reused identically whether the child is a short-lived
one-shot command (`ebpm`, `git` - blocking reads via
`DataInputStreamReadLine`/`InputStreamReadAllAsync`+sync-style usage are
fine) or a long-lived server process (an LSP server - use the `*Async`/
`*Finish` pairs instead, so the GTK main loop isn't frozen waiting on it).

## App shell widgets

```basic
DIM bar AS HeaderBar
bar = NewHeaderBar()
CALL HeaderBarSetTitle(bar, "My Editor")
CALL WindowSetTitlebar(win, bar)

DIM sidebar AS ListBox
sidebar = NewListBox()
CALL ListBoxSetActivateOnSingleClick(sidebar, 1)
DIM fileLabel AS Label
fileLabel = NewLabel("main.bas")
CALL ListBoxAppend(sidebar, fileLabel)

DIM split AS Paned
split = NewPaned(GTK_ORIENTATION_HORIZONTAL)
CALL PanedSetStartChild(split, sidebar)
CALL PanedSetEndChild(split, scroller)   ' e.g. a ScrolledWindow around a SourceView
```

`ListBox` (not the newer, model+factory-based `GtkListView`) backs this
package's list needs - a plain, real widget per row (`ListBoxAppend`),
with none of `GListModel`/`GtkListItemFactory`'s virtual-function wiring;
connect `"row-activated"` (via `ObjConnect`) to react to a click.

`FileChooserNative` (not the newer GTK 4.10+ `GtkFileDialog`, for broader
GTK4 version compatibility) is inherently asynchronous - there's no
blocking "show and get the result" call:

```basic
SUB OnResponse(dialog AS GObj PTR, responseId AS INTEGER, data AS ANY PTR)
    DIM fc AS FileChooserNative
    fc = WrapFileChooserNative(dialog)

    IF responseId = GTK_RESPONSE_ACCEPT THEN
        DIM rawPath AS ANY PTR
        rawPath = FileChooserGetFilePath(fc)
        IF rawPath <> 0 THEN
            DIM viaZstring AS ZSTRING
            viaZstring = rawPath
            DIM path AS STRING
            path = viaZstring
            CALL FreeGMallocString(rawPath)
            PRINT path
        END IF
    END IF
    CALL FileChooserNativeDestroy(fc)
END SUB

DIM opener AS FileChooserNative
opener = NewFileChooserNative("Open File", win, GTK_FILE_CHOOSER_ACTION_OPEN, "_Open", "_Cancel")
CALL ObjConnect(opener, "response", @OnResponse, 0)
CALL FileChooserNativeShow(opener)
```

## Diagnostics highlighting + hover tooltips

```basic
DIM errorTag AS ANY PTR
errorTag = TextBufferCreateUnderlineTag(buf, "lsp-error", PANGO_UNDERLINE_ERROR)
CALL TextBufferApplyTagRange(buf, errorTag, 0, 4, 0, 5)   ' underline "x" on line 0
CALL TextBufferClearTag(buf, errorTag)                     ' clear before re-applying

CALL WidgetSetTooltipText(myWidget, "the resolved type/signature")
```

GTK's real property-setting entry points for a `GtkTextTag`'s appearance
(`gtk_text_buffer_create_tag`, `g_object_set`) are variadic C functions -
eBasic has no variadic-call support, so this package instead looks up the
target property's `GType` at runtime (`g_type_from_name`), builds a
`GValue` by hand (`g_value_init`/`g_value_set_enum`/`g_value_unset`, a
heap-allocated opaque blob exactly like `GtkTextIter`), and sets it via
the non-variadic `g_object_set_property`. `gtk_widget_set_tooltip_text`
needed none of this - it's one of the few style-adjacent properties GTK
also exposes as a dedicated, ordinary function.

## Layout

- `src/raw/` - the raw FFI layer (see above).
- `src/*.bas` - the idiomatic layer (see above); `src/lib.bas` is the
  package's `#include` aggregator (its own `[lib]` entry point).
- `tests/` - `ebpm test` suite; `tests/manual/` holds checks that need a
  real GTK4 display backend, run by hand rather than automatically.
