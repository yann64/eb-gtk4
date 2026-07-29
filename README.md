# eb-gtk4

A GTK4 wrapper library for [eBasic](https://github.com/yann64/ebasic),
managed with `ebpm`.

## Status

Early development. Linux-first. Currently built: the raw FFI layer
(`src/raw/`) for GLib/GObject/GIO core and GTK4's core widgets
(`GtkApplication`, `GtkWindow`, `GtkBox`, `GtkGrid`, `GtkButton`,
`GtkLabel`, `GtkEntry`). The idiomatic OOP wrapper layer and signal
handling are not built yet - signal handling is blocked on adding
function-pointer support to the eBasic compiler itself (tracked upstream).

## Building

```sh
ebpm build
ebpm test
```

Requires GTK4 development libraries installed and discoverable by the
linker's default search path (works out of the box on Linux; `pkg-config
--libs gtk4` should list `-lgtk-4` among others).

## Using as a dependency

```toml
[target.linux.dependencies]
gtk4 = { git = "https://github.com/yann64/eb-gtk4.git" }
```

```basic
#ifdef __FB_LINUX__
    #include "gtk4.iface.bas"
#endif
```

## Layout

- `src/raw/` - flat `Extern "C" Lib "..."` declarations mirroring the real
  C API 1:1, one file per GLib/GObject/GTK4 subsystem. Internal use only.
- `src/lib.bas` - the package's `#include` aggregator.
- `tests/` - `ebpm test` suite (display-independent only - see
  `tests/manual/` for widget-construction checks that need a real GTK4
  display backend).
