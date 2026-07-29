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
  `Entry`, `Application`, each `EXTENDS`-chained from a common `Obj` base)
  plus free functions operating on them (`NewButton`, `ButtonSetLabel`,
  `WidgetShow`, `ObjConnect` for signals, ...).

**Free functions, not methods** - an eBasic `TYPE`'s own methods aren't
exported across an `ebpm --lib` package boundary yet (only top-level
`SUB`/`FUNCTION` and plain-data/opaque `TYPE`/`UNION` are), so the public
API is `CALL ButtonSetLabel(myButton, "text")`, not
`myButton.SetLabel("text")`.

**`ZSTRING`, not `STRING`, for text** - a `STRING`-returning top-level
function isn't exported across the same boundary yet either, so every
text-carrying parameter/return in this package's public API uses
`ZSTRING` (a plain `const char*`) instead.

## Building

```sh
ebpm build
ebpm test
```

Requires GTK4 development libraries installed and discoverable by the
linker's default search path (works out of the box on Linux; `pkg-config
--libs gtk4` should list `-lgtk-4` among others).

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

Requires `ebc`/`ebpm` built from a version including the two upstream
fixes this package's real cross-package consumption depends on: `ebpm`
forwarding a dependency's own `Lib "name"` clauses transitively, and
`--lib` exporting a derived (`EXTENDS`) plain-data `TYPE` - both landed in
[yann64/ebasic](https://github.com/yann64/ebasic) alongside `@ProcName`
(function pointers for signal callbacks), all found and fixed while
building this package.

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

## Layout

- `src/raw/` - the raw FFI layer (see above).
- `src/*.bas` - the idiomatic layer (see above); `src/lib.bas` is the
  package's `#include` aggregator (its own `[lib]` entry point).
- `tests/` - `ebpm test` suite; `tests/manual/` holds checks that need a
  real GTK4 display backend, run by hand rather than automatically.
