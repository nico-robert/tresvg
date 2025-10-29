# Copyright (c) 2025 Nicolas ROBERT.
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

proc tresvg::unpremultiply {data} {
    # Unpremultiply image data.
    # See https://en.wikipedia.org/wiki/Alpha_compositing
    #
    # data - image data multiplied.
    #
    # Returns: the data unmultiplied.
    set result {}
    set size [llength $data]

    for {set offset 0} {$offset < $size} {incr offset 4} {
        set r [lindex $data $offset]
        set g [lindex $data [expr {$offset + 1}]]
        set b [lindex $data [expr {$offset + 2}]]
        set alpha [lindex $data [expr {$offset + 3}]]

        if {$alpha != 0 && $alpha != 255} {
            set multiplier [expr {int(round((255.0 / $alpha) * 255))}]
            set r [expr {($r * $multiplier + 127) / 255}]
            set g [expr {($g * $multiplier + 127) / 255}]
            set b [expr {($b * $multiplier + 127) / 255}]
        }

        lappend result $r $g $b $alpha
    }

    return $result
}

proc tresvg::encodePNG {data width height} {
    # Command to generate the PNG image.
    #
    # data     - image data
    # width    - width of the image
    # height   - height of the image
    #
    # Returns: data of the PNG image.

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

    set unpremultiplied_list [tresvg::unpremultiply $data]

    set image_data ""
    set bytes_per_scanline [expr {$width * 4}]
    for {set y 0} {$y < $height} {incr y} {
        # Filtre 0 (None)
        append image_data "\x00"
        set scanline_start [expr {$y * $bytes_per_scanline}]
        set scanline_end [expr {$scanline_start + $bytes_per_scanline - 1}]
        for {set i $scanline_start} {$i <= $scanline_end} {incr i} {
            if {$i < [llength $unpremultiplied_list]} {
                append image_data [binary format c [lindex $unpremultiplied_list $i]]
            } else {
                append image_data "\x00"
            }
        }
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
    # data     - The rendered SVG image data.
    # width    - The width of the image.
    # height   - The height of the image.
    # filename - The path to the file where the image will be saved.
    #
    # Returns: Nothing.

    set data_png [tresvg::encodePNG $data $width $height]

    try {
        set fp [open $filename wb]
        puts -nonewline $fp $data_png
    } on error {result options} {
        error [dict get $options -errorinfo]
    } finally {
        catch {close $fp}
    }

    return {}
}

proc tresvg::toBase64 {data width height} {
    # Convert data to base64 string.
    #
    # data   - image data
    # width  - width of the image
    # height - height of the image
    #
    # Returns base64 string.
    set png_file [tresvg::toPNG $data $width $height]

    set data_png [tresvg::encodePNG $data $width $height]

    return [binary encode base64 $png_file]
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
        #include <math.h>

        #if TCL_MAJOR_VERSION == 8
            #ifndef TCL_SIZE_MAX
                typedef int Tcl_Size;
                # define Tcl_GetSizeIntFromObj Tcl_GetIntFromObj
                # define Tcl_NewSizeIntObj Tcl_NewIntObj
                # define TCL_SIZE_MAX      INT_MAX
                # define TCL_SIZE_MODIFIER ""
            #endif
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
        Tcl_Obj **data;

        if (Tcl_GetIntFromObj(interp, objv[2], &width) != TCL_OK ||
            Tcl_GetIntFromObj(interp, objv[3], &height) != TCL_OK) {
            return TCL_ERROR;
        }

        if (width <= 0 || height <= 0) {
            Tcl_SetResult(interp, "tresvg(error): Calculated dimensions are invalid.", TCL_STATIC);
            return TCL_ERROR;
        }

        if (Tcl_ListObjGetElements(interp, objv[1], &count, &data) != TCL_OK) {
            return TCL_ERROR;
        }

        Tcl_Size expected_count = (Tcl_Size)width * height * 4;
        if (count != expected_count) {
            Tcl_SetObjResult(interp, 
                Tcl_ObjPrintf(
                    "tresvg: Pixmap size mismatch. Need %d values for %dx%d image, got %d", 
                    (int)expected_count, width, height, (int)count
                )
            );
            return TCL_ERROR;
        }

        unsigned char *image = (unsigned char*)Tcl_Alloc(count);

        if (image == NULL) {
            Tcl_SetResult(interp, "tresvg(error): Cannot alloc image buffer.", TCL_STATIC);
            return TCL_ERROR;
        }

        // Unpremultiply
        int alpha, r, g, b;
        for (Tcl_Size i = 0; i < count; i += 4) {
            if (Tcl_GetIntFromObj(interp, data[i + 0], &r) != TCL_OK ||
                Tcl_GetIntFromObj(interp, data[i + 1], &g) != TCL_OK ||
                Tcl_GetIntFromObj(interp, data[i + 2], &b) != TCL_OK ||
                Tcl_GetIntFromObj(interp, data[i + 3], &alpha) != TCL_OK) {
                Tcl_Free((char*)image);
                Tcl_SetResult(interp, "tresvg(error): Invalid pixel data.", TCL_STATIC);
                return TCL_ERROR;
            }
            if (alpha != 0 && alpha != 255) {
                unsigned int multiplier = (unsigned int)round((255.0f / (float)alpha) * 255.0f);
                image[i + 0] = (unsigned char)(((unsigned int)r * multiplier + 127) / 255);
                image[i + 1] = (unsigned char)(((unsigned int)g * multiplier + 127) / 255);
                image[i + 2] = (unsigned char)(((unsigned int)b * multiplier + 127) / 255);
                image[i + 3] = (unsigned char)alpha;
            } else {
                image[i + 0] = (unsigned char)r;
                image[i + 1] = (unsigned char)g;
                image[i + 2] = (unsigned char)b;
                image[i + 3] = (unsigned char)alpha;
            }
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