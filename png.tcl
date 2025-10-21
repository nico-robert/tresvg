# Copyright (c) 2025 Nicolas ROBERT.
# Distributed under MIT license. Please see LICENSE for details.

namespace eval tresvg {}

proc tresvg::createChunk {type data} {
    set length [string length $data]
    set chunk_data "$type$data"

    set crc [zlib crc32 $chunk_data]

    set chunk [binary format I $length]
    append chunk $chunk_data
    append chunk [binary format I $crc]

    return $chunk
}

proc tresvg::unpremultiply {data} {
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

proc tresvg::base {data width height} {
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

    set data_png [tresvg::base $data $width $height]

    set fp [open $filename wb]
    puts -nonewline $fp $data_png
    close $fp
    
    return {}
}

proc tresvg::toBase64 {data width height} {

    set data_png [tresvg::base $data $width $height]

    return [binary encode base64 $png_file]
}