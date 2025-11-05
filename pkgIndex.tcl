# Copyright (c) 2025 Nicolas ROBERT.
# Distributed under MIT license. Please see LICENSE for details.

package ifneeded tresvg 0.19 [list apply {dir {
    source [file join $dir tresvg.tcl]
    source [file join $dir src ffi.tcl]
    source [file join $dir src crit.tcl]
    source [file join $dir src png.tcl]
}} $dir]