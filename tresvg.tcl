# Copyright (c) 2025-2026 Nicolas ROBERT.
# Distributed under MIT license. Please see LICENSE for details.
# tresvg - Tcl SVG rendering

# 21-Oct-2025 : v0.1 Initial release
# 25-Oct-2025 : v0.15 
              # Adds a better support for critcl backend.
              # Adds others commands for tcl-cffi backend.
              # Adds gitHub Actions workflow to build resvg binaries.
              # Cosmetic changes.
# 29-Oct-2025 : v0.17
              # Uses `critcl` if present to replace the `tresvg::encodePNG` command for tcl-cffi backend,   
              # by using `stbi_write_png_to_mem` function from `stb_image_write.h` header file if also exists.
              # Cosmetic changes.
# 05-Nov-2025 : v0.19
              # Extends resvg C-API with 2 new commands `resvg_tree_to_xml` and `resvg_version_string`.
              # Includes `<limits.h>` header in `crit.tcl` file +
              # fixes some problems with `critcl` and `Tk9`, thanks @andreas-kupries.
              # Adds gitHub Actions workflow to extend resvg C-API.
              # Adds a release with binaries for macOS (ARM + Intel), Windows and Linux.
# 30-Jan-2026 : v0.21
              # Some functions are not part of the resvg API, use `-ignoremissing` parameter to avoid generating errors.
              # Gives priority to platform files in the lib resvg search for `unix` platform.
              # Fix `resvg_parse_tree_from_data` procedure was not defined.
              # Bump resvg version to `0.46.0`.


package require Tcl 8.6-
package require platform

namespace eval tresvg {
    variable version          0.21
    variable packageDirectory [file dirname [file normalize [info script]]]
    variable platform         [::platform::generic]
    variable libDirectory     [file join $packageDirectory $platform]
    variable resvgMinVersion  "0.45.1"
}

package provide tresvg $::tresvg::version