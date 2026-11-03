# Copyright (c) 2025-2026 Nicolas ROBERT.
# Distributed under MIT license. Please see LICENSE for details.

namespace eval tresvg {}

proc tresvg::createChunk {type data} {
    # Create a PNG chunk.
    #
    # type    - string, type of the chunk. Must be "IHDR", "IDAT", "IEND".
    # data    - string, data of the chunk.
    #
    # Returns: string, the created chunk.
    set length [string length $data]
    set chunk_data "$type$data"

    set crc [zlib crc32 $chunk_data]

    set chunk [binary format I $length]
    append chunk $chunk_data
    append chunk [binary format I $crc]

    return $chunk
}

proc tresvg::encodePNG {data width height} {
    # Command to generate the PNG image.
    #
    # data     - image data (premultiplied RGBA byte array)
    # width    - width of the image
    # height   - height of the image
    #
    # Returns: data of the PNG image.

    if {$width <= 0 || $height <= 0} {
        error "tresvg(error): Calculated dimensions are invalid."
    }

    set bytes_per_scanline [expr {$width * 4}]
    set expected [expr {$bytes_per_scanline * $height}]
    if {[string length $data] != $expected} {
        error "tresvg: Pixmap size mismatch. Need $expected bytes\
               for ${width}x${height} image, got [string length $data]"
    }

    # Signature PNG
    set png_sig "\x89PNG\r\n\x1a\n"

    set ihdr_data [binary format I $width]
    append ihdr_data [binary format I $height]
    append ihdr_data "\x08" ;# Bit depth: 8 bits
    append ihdr_data "\x06" ;# Color type: 6 = RGBA
    append ihdr_data "\x00" ;# Compression method
    append ihdr_data "\x00" ;# Filter method
    append ihdr_data "\x00" ;# Interlace method
    set ihdr_chunk [tresvg::createChunk "IHDR" $ihdr_data]

    set image_data ""
    for {set y 0} {$y < $height} {incr y} {
        binary scan $data "@[expr {$y * $bytes_per_scanline}]cu$bytes_per_scanline" row
        set out {}
        foreach {r g b a} $row {
            if {$a != 0 && $a != 255} {
                set half [expr {$a / 2}]
                set r [expr {($r * 255 + $half) / $a}]
                set g [expr {($g * 255 + $half) / $a}]
                set b [expr {($b * 255 + $half) / $a}]
            }
            lappend out $r $g $b $a
        }
        append image_data "\x00" [binary format c* $out]
    }

    set compressed_data [zlib compress $image_data]
    set idat_chunk [tresvg::createChunk "IDAT" $compressed_data]

    set iend_chunk [tresvg::createChunk "IEND" ""]

    set data_png $png_sig
    append data_png $ihdr_chunk
    append data_png $idat_chunk
    append data_png $iend_chunk

    return $data_png
}

proc tresvg::toPNG {data width height filename} {
    # Save the rendered SVG image to a PNG file.
    #
    # data     - The rendered SVG image data (premultiplied RGBA byte array).
    # width    - The width of the image.
    # height   - The height of the image.
    # filename - The path to the file where the image will be saved.
    #
    # Returns: Nothing.
    set data_png [tresvg::encodePNG $data $width $height]
    set fp [open $filename wb]

    try {
        puts -nonewline $fp $data_png
    } on error {result options} {
        error [dict get $options -errorinfo]
    } finally {
        close $fp
    }

    return {}
}

proc tresvg::toBase64 {data width height} {
    # Convert data to base64 string.
    #
    # data   - image data (premultiplied RGBA byte array)
    # width  - width of the image
    # height - height of the image
    #
    # Returns base64 string.
    set data_png [tresvg::encodePNG $data $width $height]

    return [binary encode base64 $data_png]
}

# Check if 'critcl' package is available and if 'stb_image_write.h' file exists.
# If true, we use 'critcl' package to build tresvg::base command.
# If not, we fall back to using pure 'tcl' procedure.
#
# 'stb_image_write.h' file is a header file from 'stb' library.
# It is used as procedure to write PNG to memory.
# Public domain - http://nothings.org/stb/ Sean Barrett 2010-2015
#
if {
    ![catch {package require critcl}] &&
    [file exists [file join $::tresvg::libDirectory include stb_image_write.h]]
} {

    # Tcl version
    if {[package vsatisfies [package provide Tcl] 8.6] &&
        ([package vcompare [package provide critcl] "3.3"] < 0)
    } {
        critcl::tcl 8.6
    }

    if {[package vsatisfies [package provide Tcl] 9.0-] &&
        ([package vcompare [package provide critcl] "3.3"] < 0)
    } {
        error "'critcl' version 3.3 or higher is required with Tcl9."
    }

    if {[package vsatisfies [package provide Tcl] 9.0-]} {
        critcl::tcl 9
    }

    critcl::config I [list [file join $::tresvg::libDirectory include]]

    if {![critcl::compiling]} {
        error "tresvg(error): Unable to build project, no proper compiler found."
    }

    critcl::ccode {
        #define STB_IMAGE_WRITE_IMPLEMENTATION
        #include "stb_image_write.h"
        #include <stdlib.h>

        #ifndef TCL_SIZE_MAX
            #include <limits.h>
            typedef int Tcl_Size;
            # define Tcl_GetSizeIntFromObj Tcl_GetIntFromObj
            # define Tcl_NewSizeIntObj Tcl_NewIntObj
            # define TCL_SIZE_MAX      INT_MAX
            # define TCL_SIZE_MODIFIER ""
        #endif

    }

    rename tresvg::encodePNG ""

    critcl::ccommand tresvg::encodePNG {cd interp objc objv} {

        if (objc != 4) {
            Tcl_WrongNumArgs(interp, 1, objv, "pixmap width height");
            return TCL_ERROR;
        }

        int width, height;
        Tcl_Size count;

        if (Tcl_GetIntFromObj(interp, objv[2], &width) != TCL_OK ||
            Tcl_GetIntFromObj(interp, objv[3], &height) != TCL_OK) {
            return TCL_ERROR;
        }

        if (width <= 0 || height <= 0) {
            Tcl_SetResult(interp, "tresvg(error): Calculated dimensions are invalid.", TCL_STATIC);
            return TCL_ERROR;
        }

        size_t img_len = (size_t)width * (size_t)height * 4;

        if (img_len > TCL_SIZE_MAX) {
            Tcl_SetResult(interp, "tresvg(error): Image too large.", TCL_STATIC);
            return TCL_ERROR;
        }

        // The pixmap is a Tcl byte array: premultiplied RGBA, 4 bytes per pixel.
        unsigned char *pixmap = Tcl_GetByteArrayFromObj(objv[1], &count);

        if ((size_t)count != img_len) {
            Tcl_SetObjResult(interp,
                Tcl_ObjPrintf(
                    "tresvg: Pixmap size mismatch. Need %d bytes for %dx%d image, got %d",
                    (int)img_len, width, height, (int)count
                )
            );
            return TCL_ERROR;
         }

        // Tcl values can be shared: unpremultiply into a private buffer, never in place.
        // (Tcl_Alloc panics on failure, it does not return NULL.)
        unsigned char *image = (unsigned char*)Tcl_Alloc(img_len);

        // Unpremultiply, rounded to nearest: (c * 255 + a / 2) / a
        for (size_t i = 0; i < img_len; i += 4) {
            unsigned int alpha = pixmap[i + 3];
            if (alpha != 0 && alpha != 255) {
                unsigned int half = alpha / 2;
                for (int k = 0; k < 3; k++) {
                    unsigned int v = ((unsigned int)pixmap[i + k] * 255 + half) / alpha;
                    image[i + k] = (unsigned char)(v > 255 ? 255 : v);
                }
            } else {
                image[i + 0] = pixmap[i + 0];
                image[i + 1] = pixmap[i + 1];
                image[i + 2] = pixmap[i + 2];
            }
            image[i + 3] = (unsigned char)alpha;
        }

        int len;
        unsigned char *png = stbi_write_png_to_mem(image, width * 4, width, height, 4, &len);
        Tcl_Free((char*)image);

        if (png == NULL) {
            Tcl_SetResult(interp, "tresvg(error): PNG encoding failed.", TCL_STATIC);
            return TCL_ERROR;
        }

        Tcl_Obj *result = Tcl_NewByteArrayObj(png, (Tcl_Size)len);
        free(png);

        Tcl_SetObjResult(interp, result);
        return TCL_OK;

    }

}