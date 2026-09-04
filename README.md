# eb-gtk4

A GTK4 wrapper library for [eBasic](https://github.com/yann64/ebasic),
managed with `ebpm`.

## Status

Early development. Was Linux-first (untested elsewhere) - confirmed
since to also compile, link, and *run* for real on Haiku (real
`gtk4`/`gtksourceview5`/`glib2` HaikuPorts packages; see `ebasic-editor`'s
own README "Haiku" section for that earlier verification detail, since
that was the actual GUI vehicle it was first proven through). **Directly
reconfirmed since (2026-09-04, v0.11.0)** against this package's own test
suite and examples on real Haiku hardware, zero source changes needed:
`native/CMakeLists.txt`'s `pkg_check_modules` finds real, HaikuPorts-
packaged `gtk4`/`gio-2.0` unmodified, all 8 `ebpm test` cases pass, and
`examples/hello_window`/`examples/menu_toolbar` both render live with
Haiku's own native window decorations (Haiku's GTK4 port uses its own
GDK backend, not X11/Wayland/Broadway, despite reporting a `wl_ips_*`
connection at startup). `eb-gui-gtk4` (the universal GUI adapter built on
this package) was reconfirmed working there too, so no separate
BWindow-native adapter is needed to get eBasic GUI apps running on Haiku
via GTK4. Almost entirely pure
`Extern "C" Lib "..."` FFI over GLib/GObject/GTK4's own stable,
OS-independent C ABI - Windows/macOS remain untried, not expected to be
architecturally harder - **except one small piece of native code**
(`native/shim_timer.h`/`.cpp`, `libebgtk4shim.a`): real GLib has no
persistent, configurable timer object, only a fire-and-forget
`g_timeout_add` primitive whose own callback decides repeat-vs-stop
*reactively* per firing - bridging that to a `Start`/`Stop`/
`SetSingleShot` object model (matching a richer, already-established
convention from a sibling package) needs a real trampoline, since
eBasic itself has no way to call through an arbitrary stored function
pointer, plus one small helper (`native/shim_menu.h`/`.cpp`) that
builds a `"win.<name>"` detailed-action string for `Menu`/`Action`
(real string concatenation - not expressible across the eBasic/C FFI
boundary, not a callback bridge). See "Building" below for the extra
step this adds. Two layers:

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
  `SourceCompletion`/`SourceCompletionWords` (a real, live-as-you-type
  completion popup - no custom GObject-interface implementation needed;
  see `SourceCompletionWordsRegister`'s own doc comment),
  `SubprocessLauncher`/`Subprocess`/`InputStream`/`OutputStream`/
  `DataInputStream`, `HeaderBar`, `Paned`, `ListBox`/`ListBoxRow`,
  `FileChooserNative`, `EventControllerKey`, each `EXTENDS`-chained from a
  common `Obj` base) plus free functions operating on them (`NewButton`,
  `ButtonSetLabel`, `WidgetShow`, `WidgetGrabFocus`, `ObjConnect` for
  signals, `TextBufferGetText`/`SetText`, `SourceBufferSetLanguage`,
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
cmake -S native -B native/build && cmake --build native/build
EBASIC_LIBRARY_PATH=$(pwd)/native/build ebpm build
EBASIC_LIBRARY_PATH=$(pwd)/native/build ebpm test
```

`EBASIC_LIBRARY_PATH` (not `LIBRARY_PATH` - see `ebpm`'s own docs for
why) tells `ebc`/`ebpm` where to find the just-built `libebgtk4shim.a` -
this package's manifest has no field for a real, external native
library's own directory, the same gap `eb-qt6`/`eb-haiku` document for
their own native shims (`GtkTimer`, `timer.bas`, is the only feature
needing this - everything else needs no native step at all).

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

## Window lifecycle

```basic
CALL ApplicationQuit(app)                 ' stop ApplicationRun's main loop

CALL WidgetSetEnabled(myWidget, 0)        ' grayed out, stops accepting input
PRINT WidgetIsEnabled(myWidget)           ' 0 - GTK4 has no window-level
                                           ' "disabled" concept, only per-widget

CALL WindowSetModal(childWin, parentWin)  ' blocks parentWin until childWin closes
CALL WindowClearModal(childWin)
PRINT WindowIsModal(childWin)

SUB OnCloseRequest(win AS GObj PTR, data AS ANY PTR) AS INTEGER
    OnCloseRequest = 1   ' TRUE = veto the close; FALSE = let it proceed
END SUB
CALL ObjConnect(myWindow, "close-request", @OnCloseRequest, 0)
CALL WindowPresent(myWindow)
CALL WindowClose(myWindow)   ' goes through "close-request", unlike WindowDestroy
```

`gtk_window_close()`/`WindowClose` only emits `close-request` on a window
that has already been `WindowPresent`-ed at least once (confirmed via a
standalone, non-interactive test program) - calling it on a
never-presented window is silently a no-op.

## Status bar

```basic
DIM sb AS StatusBar
sb = NewStatusBar()
CALL WindowSetChild(myWindow, sb)   ' or pack it into a Box with other widgets
CALL StatusBarShowMessage(sb, "Ready")
CALL StatusBarClear(sb)
```

Backed by `GtkStatusbar`, deprecated upstream since GTK 4.10 but still
the only concrete statusbar widget GTK4 offers at all. Always uses a
single message context internally (obtained once at construction) -
GtkStatusbar's own multi-context stacking isn't exposed, since nothing
in this package needs more than "show the current message."

## Timer

```basic
DIM t AS GtkTimer
t = NewGtkTimer()
CALL GtkTimerSetInterval(t, 1000)
CALL GtkTimerSetSingleShot(t, 0)   ' 1 = fire once then stop

SUB OnTick(userData AS ANY PTR)
    PRINT "tick"
END SUB
CALL GtkTimerConnectTimeout(t, @OnTick, 0)

CALL GtkTimerStart(t)
PRINT GtkTimerIsActive(t)   ' -1
CALL GtkTimerStop(t)
CALL GtkTimerDestroy(t)     ' not a GObject - has its own destroy, not ObjDestroy
```

Named `GtkTimer`, not `Timer` - eBasic's own stdlib already defines a
top-level `Timer()` function (seconds elapsed) and identifiers are
case-insensitive, so a bare `TYPE Timer` would collide with it.

## Window content sharing: `WindowContentBox`

A plain GTK4 window can only ever have **one** direct child - unlike
Qt's `QMainWindow`, which has independent menu bar/tool bar/central
widget/status bar slots. `WindowContentBox(w)` is the coordination
point that lets a menu bar, a tool bar, your own main content, and a
status bar all coexist in one window: the first time it's called for
`w` (directly, or indirectly via `WindowMenuBar`/`WindowToolBar`), it
creates a plain vertical `Box`, moves whatever was already `w`'s child
into it, installs the box as `w`'s new (and from then on, only) child,
and remembers it (`g_object_set_data`, directly on the window's own
`GObject` - no extra eBasic-side bookkeeping) for every later call to
return the same box.

```basic
DIM contentBox AS Box
contentBox = WindowContentBox(win)
CALL BoxAppend(contentBox, myLabel)   ' your own main content
```

Convention (not enforced): request `WindowMenuBar`/`WindowToolBar`
first if you want both (they each `BoxPrepend` themselves, and
`WindowToolBar` checks whether a menu bar already exists to land just
below it rather than above) - then add your own content, then a status
bar anytime (always `BoxAppend`-ed at the current end).

## Menu

```basic
DIM bar AS MenuBar
bar = WindowMenuBar(win)          ' auto-created, one per window
DIM fileMenu AS Menu
fileMenu = MenuBarAddMenu(bar, "File")

DIM openAction AS Action
openAction = NewAction(win, "open")   ' window-scoped - "win.open" internally

SUB OnOpen(action AS GObj PTR, parameter AS ANY PTR, userData AS ANY PTR)
    PRINT "opened"
END SUB
CALL ObjConnect(openAction, "activate", @OnOpen, 0)

CALL MenuAddAction(fileMenu, openAction, "Open")
CALL ActionSetEnabled(openAction, 1)
```

Real GTK4 removed `GtkMenuBar`/`GtkMenuItem` entirely - there is no
direct equivalent to a Qt-style `QMenuBar`/`QMenu`/`QAction` shape.
This package's own `Menu`/`Action`/`MenuBar` mirror that shape as
closely as GTK4's real, modern architecture allows:

- `Menu` wraps a plain `GMenu` (a `GMenuModel`/`GObject`, **not** a
  `GtkWidget`) - unlike a real `QMenu`, a GTK4 submenu is never
  independently visible; it only ever appears nested inside a
  `MenuBar`'s own popover.
- `Action` wraps a `GSimpleAction`, registered on a **window's** own
  action map (v1 scope: window-scoped actions only, referenced
  internally as `"win.<name>"` via a small native helper -
  app-scoped `"app.<name>"` actions aren't exposed yet). A menu item
  never carries a callback directly - it references an action by
  name, and the action's own real `"activate"` signal (wired via the
  already-generic `ObjConnect` - no new native code needed for this
  part, `GSimpleAction` is an ordinary `GObject`) is what actually
  fires.
- `MenuBar` wraps the real `GtkPopoverMenuBar` widget, auto-created via
  `WindowMenuBar` (see above) - never constructed directly.

`ActionActivate(a)` activates an action programmatically, the same
path a real menu-item click goes through - lets a connected
`"activate"` handler be exercised/tested without needing a real click
(the same role `WindowClose` plays for `"close-request"`).

**Verified**: `examples/menu_toolbar` shows a `MenuBar` + `ToolBar` +
main content + `StatusBar` all in one window, screenshot-confirmed
live, correctly stacked top-to-bottom in that order regardless that
the status bar was the last one requested (real interactive menu
clicking hit the same well-documented `xdotool windowactivate`
flakiness this project has seen throughout, so `examples/menu_verify`
confirms the rest headlessly: `WindowContentBox`/`WindowMenuBar`/
`WindowToolBar` each return the identical handle on repeated calls;
`ActionActivate` genuinely reaches a connected `ObjConnect("activate",
...)` handler, both before and after the same action is also
referenced from a real menu item).

## Toolbar

```basic
DIM t AS ToolBar
t = WindowToolBar(win)   ' auto-created, one per window
DIM btn AS Button
btn = ToolBarAddButton(t, "Save")
CALL ObjConnect(btn, "clicked", @OnSaveClicked, 0)
```

Real GTK4 removed `GtkToolbar` entirely - the modern replacement
pattern upstream itself recommends is exactly this: a plain horizontal
`Box` holding regular `Button`s. No new raw/native bindings needed at
all. A tool bar button has no special connection to the `Action`/menu
system in this package - wire it up with the usual `ObjConnect`, same
as any other button.

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

## Per-child layout constraints (v0.12.0)

```basic
CALL WidgetSetHExpand(myButton, 1)   ' grow to fill extra horizontal space
CALL WidgetSetVAlign(myLabel, GTK_ALIGN_CENTER)
```

GTK4 moved expand/fill from the old Gtk3 `gtk_box_pack_start(child,
expand, fill, padding)` shape onto the CHILD widget itself -
`WidgetSetHExpand`/`WidgetSetVExpand`/`WidgetSetHAlign`/`WidgetSetVAlign`
(`src/raw/gtk_widget.bas`, `src/widget.bas`) work on any `Widget`-derived
handle and take effect the next time that widget is placed in a `Box`/
`Grid` - no separate "attach with constraints" call needed, unlike Qt6/
Haiku's own layout-object-centric APIs. `GTK_ALIGN_FILL`/`START`/`END`/
`CENTER` constants (confirmed against this system's real `gtkenums.h`
values: `FILL=0, START=1, END=2, CENTER=3`) are plain integer `Const`s in
`src/raw/gtk_widget.bas`. Expand is boolean only - real GTK4 has no
fractional-ratio expand between multiple expanding siblings (unlike
Qt6's stretch factor or Haiku's item weight); `GtkGrid` has no
per-column/row weight concept at all, a real absence in GTK4 itself, not
a binding gap (see `eb-gui-gtk4`'s own README for how the universal
`eb-gui` contract's `GuiGridSetColumnWeight`/`SetRowWeight` degrade to a
documented no-op on this backend as a result).

## Layout

- `src/raw/` - the raw FFI layer (see above).
- `src/*.bas` - the idiomatic layer (see above); `src/lib.bas` is the
  package's `#include` aggregator (its own `[lib]` entry point).
- `native/` - this package's small native shims (`shim_timer.h`/`.cpp`,
  `shim_menu.h`/`.cpp`, see "Status"/"Building" above) - not
  `ebpm`/`ebc`-driven, built standalone the same way `eb-qt6`/
  `eb-haiku`'s own native shims are.
- `tests/` - `ebpm test` suite; `tests/manual/` holds checks that need a
  real GTK4 display backend, run by hand rather than automatically.
