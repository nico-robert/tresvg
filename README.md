# tresvg - Tcl SVG rendering

Tcl wrapper around **resvg**

***resvg** is an [SVG](https://en.wikipedia.org/wiki/Scalable_Vector_Graphics) rendering library.* *It can be used as a Rust library, as a C library, and as a CLI application to render static SVG files.*  
*The core idea is to make a fast, small, portable SVG library with the goal to support the whole SVG spec.*  
> *Source: [resvg](https://github.com/linebender/resvg)*

## Compatibility :
- [Tcl](https://www.tcl.tk/) 8.6 or higher

## Dependencies :

- [tcl-cffi](https://github.com/apnadkarni/tcl-cffi) >= 2.0 and/or [critcl](https://andreas-kupries.github.io/critcl/) (see note below)
> [!NOTE]  
> [critcl](https://andreas-kupries.github.io/critcl/) and [Tk](https://www.tcl.tk/) are optional for rendering SVG image to **photo** command.

## Cross-Platform :
- Windows, Linux, macOS support.

## Example :
### `tcl-cffi` demo :
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
tresvg::toPNG $pixmap $width $height "output.png"

# Extended procedures (not a part of resvg C-API)
set xml [tresvg::getXML $tree] ; # Gets simplified XML
set version [tresvg::libVersion]

# Cleanup
tresvg::optionsDestroy $opt
tresvg::treeDestroy $tree
```
### `critcl` demo :
```tcl
package require Tk ; # Important to load Tk before 'tresvg' package.
package require tresvg

set svg hello.svg
set img [image create photo]

# Others args are optional (see listing commands below)
tresvg::toTkImg $svg $img

# Others examples of 'tresvg::toTkImg' command :
tresvg::toTkImg $svg $img -width 100 -height 50
tresvg::toTkImg $svg $img -scale 2 -dpi 300
tresvg::toTkImg $svg $img -mtx {1 0 0 1 0 0}
tresvg::toTkImg $svg $img -width 100 -height 50 -modeScale "fit"
tresvg::toTkImg $svg $img -initLog "true"

label .l -image $img
pack .l
```

## Commands :

| Tcl/Tk commands | args
| ------          | ------
tresvg::toPNG     | pixmap width height filename
tresvg::toBase64  | pixmap width height     
tresvg::toTkImg   | 'svgFile or svgData' tkImage ?args?`

---
     
### Commands listing :
<div style="overflow-x: auto;">

| resvg-c                                | tcl-cffi                                         | critcl args                      | help
| ---------------------------------------| -------------------------------------------      | ---------------------------------| ----
| resvg_transform_identity               | <code>tresvg::transformIdentity</code>           | default matrix                   | -
| resvg_init_log                         | <code>tresvg::initLog</code>                     | -initLog "bool_value"            | Use it if you want to see any warnings.
| resvg_options_create                   | <code>tresvg::optionsCreate</code>               | -                                | Creates a new #resvg_options object.
| resvg_options_destroy                  | <code>tresvg::optionsDestroy</code>              | -                                | Destroys a #resvg_options object.
| resvg_tree_destroy                     | <code>tresvg::treeDestroy</code>                 | -                                | Destroys a #resvg_tree object.
| resvg_options_set_resources_dir        | <code>tresvg::optionsSetResourcesDir</code>      | -resourcesDir $path              | Sets the path to the resources directory.
| resvg_options_set_dpi                  | <code>tresvg::optionsSetDpi</code>               | -dpi $dpi                        | Sets the DPI of the rendering.
| resvg_options_set_stylesheet           | <code>tresvg::optionsSetStylesheet</code>        | -styleSheet $css                 | Sets the CSS styles used by the SVG rendering.
| resvg_options_set_font_family          | <code>tresvg::optionsSetFontFamily</code>        | -fontFamily $family              | Sets the font family.
| resvg_options_set_font_size            | <code>tresvg::optionsSetFontSize</code>          | -fontSize $size                  | Sets the font size.
| resvg_options_set_serif_family         | <code>tresvg::optionsSetSerifFamily</code>       | -serifFontFamily $family         | Sets the serif font family.
| resvg_options_set_sans_serif_family    | <code>tresvg::optionsSetSansSerifFamily</code>   | -sansSerifFontFamily $family     | Sets the sans-serif font family.
| resvg_options_set_cursive_family       | <code>tresvg::optionsSetCursiveFamily</code>     | -cursiveFontFamily $family       | Sets the cursive font family.
| resvg_options_set_fantasy_family       | <code>tresvg::optionsSetFantasyFamily</code>     | -fantasyFontFamily $family       | Sets the fantasy font family.
| resvg_options_set_monospace_family     | <code>tresvg::optionsSetMonospaceFamily</code>   | -monospaceFontFamily $family     | Sets the monospace font family.
| resvg_options_set_languages            | <code>tresvg::optionsSetLanguages</code>         | -languages $languages            | Sets the languages.
| resvg_options_set_shape_rendering_mode | <code>tresvg::optionsSetShapeRenderingMode</code>| -shapeRenderingMode $mode        | Sets the shape rendering mode.
| resvg_options_set_text_rendering_mode  | <code>tresvg::optionsSetTextRenderingMode</code> | -textRenderingMode $mode         | Sets the text rendering mode.
| resvg_options_set_image_rendering_mode | <code>tresvg::optionsSetImageRenderingMode</code>| -imageRenderingMode $mode        | Sets the image rendering mode.
| resvg_options_load_font_data           | <code>tresvg::optionsLoadFontData</code>         | ❌ not implemented yet            | -
| resvg_options_load_font_file           | <code>tresvg::optionsLoadFontFile</code>         | -loadFontFile $fontfile          | Loads a font file.
| resvg_options_load_system_fonts        | <code>tresvg::optionsLoadSystemFonts</code>      | -loadSystemFonts "bool_value"    | Loads the system fonts.
| resvg_parse_tree_from_file             | <code>tresvg::parseTreeFromFile</code>           | -                                | Parses a SVG file.
| resvg_parse_tree_from_data             | <code>tresvg::parseTreeFromData</code>           | tresvg::toTkImg $svgString       | Parses a SVG data.
| resvg_is_image_empty                   | <code>tresvg::isImageEmpty</code>                | ❌ not implemented yet            | Gets if an image is empty.
| resvg_get_image_size                   | <code>tresvg::getImageSize</code>                | ❌ not implemented yet            | Gets the size of an image.
| resvg_get_object_bbox                  | <code>tresvg::getObjectBbox</code>               | ❌ not implemented yet            | Gets the bounding box of an object.
| resvg_get_image_bbox                   | <code>tresvg::getImageBbox</code>                | ❌ not implemented yet            | Gets the bounding box of an image.
| resvg_node_exists                      | <code>tresvg::nodeExists</code>                  | ❌ not implemented yet            | Gets if a node exists.
| resvg_get_node_transform               | <code>tresvg::getNodeTransform</code>            | ❌ not implemented yet            | Gets the transform of a node.
| resvg_get_node_bbox                    | <code>tresvg::getNodeBBox</code>                 | ❌ not implemented yet            | Gets the bounding box of a node.
| resvg_get_node_stroke_bbox             | <code>tresvg::getNodeStrokeBBox</code>           | ❌ not implemented yet            | Gets the stroke bounding box of a node.
| resvg_tree_destroy                     | <code>tresvg::treeDestroy</code>                 | -                                | Destroys a #resvg_tree object.
| resvg_render                           | <code>tresvg::render</code>                      | <code>tresvg::toTkImg $svg</code>| Renders a SVG file or data to Tk image photo.
| resvg_tree_to_xml (resvg extended)     | <code>tresvg::getXML</code>                      |-                                 | Gets simplified XML.
| resvg_version_string (resvg extended)  | <code>tresvg::liVersion</code>                   |-                                 | Gets resvg version.
| resvg_render_node                      | <code>tresvg::renderNode</code>                  | ❌ not implemented yet            | Renders a node.
| <code>struct</code> resvg_transform    | <code>[list a b c d e f]</code>                  | -mtx {a b c d e f}               | Sets the transform matrix.
| -                                      | -                                                | -width $width                    | Sets the width of the image.
| -                                      | -                                                | -height $height                  | Sets the height of the image.
| -                                      | -                                                | -scale $scale                    | Sets the scale of the image.
| -                                      | -                                                | -modeScale "fit"                 | Sets the mode scale of the image.

</div>

## Building :
You can either **build the library yourself** (if you have Rust installed or if you want to install it), or **use this repository’s GitHub Actions** to automatically build platform-specific binaries for you.

---

### Option 1 — Build locally (Rust required)

If you already have [Rust](https://www.rust-lang.org/tools/install) installed, you can build the C library directly from source:
```bash
cd resvg-X.XX.X/crates/c-api
cargo build --release
```

This command compiles the `resvg` C API and produces the libraries under:
```
target/release/
```

After building, copy the generated dynamic or static libraries into your **tresvg** package directory under one of the following platform-specific folders:

- **Linux:** `your/path/to/lib/tresvg/linux-x86_64`
- **Windows:** `your/path/to/lib/tresvg/win32-x86_64`
- **macOS (Intel):** `your/path/to/lib/tresvg/macosx-x86_64`
- **macOS (ARM):** `your/path/to/lib/tresvg/macosx-arm`

#### ⚠️ Compilation under Windows to work with critcl: :
```bash
# Rust toolchain with GNU target
rustup target add x86_64-pc-windows-gnu
cargo build --release --target x86_64-pc-windows-gnu
```
This will produce dynamic libraries in `/target/x86_64-pc-windows-gnu/release`

---

### Option 2 — Use prebuilt binaries (no Rust required)

If you prefer not to install or compile Rust yourself, you can simply **use this GitHub repository**.   
You have two alternatives:   
- On the **Actions** tab, then on the workflow of your choice, you can automatically download binaries for all supported platforms.
- If you decide to fork it, you can enable the workflow in your own fork to generate them automatically.

> [!TIP]    
> Make sure to match your platform architecture (e.g. `x86_64` vs `arm64`).   
> The header file `resvg.h` is included in each build under the `your_platform/include/` directory + `resvg` licenses in each folder.

## License : 
[MIT](LICENSE).

## Acknowledgments :
To [RazrFalcon](https://github.com/RazrFalcon), the author of **resvg**, who helped me understand his library a few years ago.

## Changes :
*  **21-Oct-2025** : 0.1
    - Initial release.
*  **26-Oct-2025** : 0.15
    - Adds a better support for **critcl** backend.
    - Adds others commands for **tcl-cffi** backend.
    - Adds gitHub Actions workflow to build **resvg** binaries.
    - Cosmetic changes.
*  **29-Oct-2025** : 0.17
    - Uses `critcl` if present to replace the `tresvg::encodePNG` command for **tcl-cffi** backend,   
      by using `stbi_write_png_to_mem` function from `stb_image_write.h` header file if also exists.
    - Cosmetic changes.
*  **05-Nov-2025** : 0.19
    - Extends resvg C-API with 2 new commands `resvg_tree_to_xml` and `resvg_version_string`.
    - Includes `<limits.h>` header in `crit.tcl` file +
      fixes some problems with `critcl` and `Tk9`, thanks @andreas-kupries.
    - Adds gitHub Actions workflow to extend resvg C-API.
    - Adds a release with binaries for **macOS** (ARM + Intel), **Windows** and **Linux**.
*  **30-Jan-2026** : 0.21
    - Some functions are not part of the resvg API, use `-ignoremissing` parameter to avoid generating errors.
    - Gives priority to platform files in the lib resvg search for **unix** platform.
    - Fix `resvg_parse_tree_from_data` procedure was not defined.
    - Bump resvg version to `0.46.0`.