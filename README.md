# tresvg - Tcl SVG rendering

Tcl wrapper around [resvg](https://github.com/linebender/resvg)

From **resvg** repository :  
***resvg** is an [SVG](https://en.wikipedia.org/wiki/Scalable_Vector_Graphics) rendering library.*  
*It can be used as a Rust library, as a C library, and as a CLI application to render static SVG files.*  
*The core idea is to make a fast, small, portable SVG library with the goal to support the whole SVG spec.*

## Compatibility :
- [Tcl](https://www.tcl.tk/) 8.6 or higher
> [!NOTE]  
> [Tk](https://www.tcl.tk/) is optional for rendering SVG image to [photo](https://www.tcl-lang.org/man/tcl8.6/TkCmd/photo.htm) command.

## Dependencies :

- [tcl-cffi](https://github.com/apnadkarni/tcl-cffi) >= 2.0 and/or [critcl](https://andreas-kupries.github.io/critcl/)
> [!NOTE]  
> [critcl](https://andreas-kupries.github.io/critcl/) is optional for rendering SVG image to **photo** command and limited for the time being.

## Cross-Platform :
- Windows, Linux, macOS support.
> [!NOTE]  
> Primary testing has been conducted on Windows and macOS. Linux compatibility is expected but may require additional validation.

## Example :
### tcl-cffi demo :
```tcl
package require tresvg

set svg hello.svg

# Initialize log (optional)
tresvg::initLog

# Create options
set opt [tresvg::optionsCreate]

# Parse svg file
set tree [tresvg::parseTreeFromFile $svg $opt]

# Apply transform
set transform [tresvg::transformIdentity]

# Get image size
set size [tresvg::getImageSize $tree]
set width  [expr {int([dict get $size width])}]
set height [expr {int([dict get $size height])}]

# Render
set pixmap [tresvg::render $tree $transform $width $height]

# Save to PNG
tresvg::toPNG $pixmap $width $height "/Users/nico/temp/output.png"

# Cleanup
tresvg::optionsDestroy $opt
tresvg::treeDestroy $tree
```
### Critcl demo :
```tcl
# Note : Critcl is very limited for the time being

package require Tk ; # Important to load Tk before 'tresvg' package.
package require tresvg

set svg hello.svg
set img [image create photo]

tresvg::toTkImg $svg $img

label .l -image $img
pack .l
```

## Building from Source

To build the resvg C library from source:
```sh
cargo build --release
```
This will produce dynamic libraries in `target/release/`, copy them to the **tresvg** package directory in platform-specific subdirectories or in the system default search path. Below are the supported **platform-specific** subdirectories:
- For Linux such as `your/path/to/lib/tresvg/linux-x86_64`
- For Windows such as `your/path/to/lib/tresvg/win32-x86_64`
- For macOS such as `your/path/to/lib/tresvg/macosx-x86_64`

#### ⚠️ Compilation under Windows to work with critcl: :
```bash
# Rust toolchain with GNU target
rustup target add x86_64-pc-windows-gnu
cargo build --release --target x86_64-pc-windows-gnu
```
This will produce dynamic libraries in `/target/x86_64-pc-windows-gnu/release`

## License : 
**tresvg** is covered under the terms of the [MIT](LICENSE) license.

## Acknowledgments :
To [RazrFalcon](https://github.com/RazrFalcon), the author of **resvg**, who helped me understand his library a few years ago.

## TODO :
- [ ] Add better support for critcl backend.

## Release :
*  **21-Oct-2025** : 0.1
    - Initial release.
