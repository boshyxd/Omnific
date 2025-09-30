# ASCII Shader Integration - Kenny FPS

## Overview
The ASCII shader has been successfully integrated into the Kenny FPS game project. This shader converts the game's 3D graphics into an ASCII art style post-processing effect, similar to Acerola's ASCII shader implementation.

## Files Added

### Shader Files
- `shaders/ascii_shader.gdshader` - Main ASCII shader (Godot 4.3 compatible)

### Textures
- `textures/ascii/fillASCII.png` - ASCII character texture (80x8 pixels)
- `textures/ascii/edgesASCII.png` - Edge detection ASCII texture
- Import files for both textures

### Scripts
- `scripts/ascii_shader_toggle.gd` - Script to toggle the ASCII effect on/off

## Scene Integration
The ASCII shader has been added to `scenes/main.tscn` as a post-processing effect:
- **ASCIIPostProcess** MeshInstance3D node with a fullscreen quad mesh
- ShaderMaterial configured with the ASCII shader
- Toggle script attached to the Main node

## How It Works

The shader implements the following technique:

1. **Fullscreen Quad**: Creates a 2x2 quad mesh that covers the entire screen
2. **Downsampling**: Makes each screen pixel 8x8 to match ASCII character size
3. **Luminosity Calculation**: Computes pixel brightness using YUV formula (0.2126*R + 0.7152*G + 0.0722*B)
4. **Quantization**: Maps luminosity to 10 discrete levels matching the number of ASCII characters
5. **Character Mapping**: Maps each 8x8 pixel block to an appropriate ASCII character based on brightness
6. **Color Application**: Multiplies the downsampled texture color with the ASCII mask

## Usage

### Toggle the ASCII Effect
Press **F1** (ui_select action) to toggle the ASCII shader on/off

### Shader Parameters
You can adjust these parameters in the ShaderMaterial:
- `_char_size`: Size of each ASCII character (default: 8.0)
- `_char_count`: Number of different ASCII characters used (default: 10.0)
- `_ascii_tex`: The ASCII character texture
- `_ascii_edge_tex`: The edge detection texture (for future enhancements)

### Customization
To adjust the visual style:
1. Open `scenes/main.tscn`
2. Select the **ASCIIPostProcess** node
3. In the Inspector, expand **Material Override → Shader Parameters**
4. Adjust `_char_size` for larger/smaller ASCII characters
5. Adjust `_char_count` to use more/fewer character variations

## Technical Details

- **Engine**: Godot 4.3
- **Shader Type**: Spatial (unshaded)
- **Render Mode**: Uses reverse Z depth buffer (Godot 4.3 feature)
- **Screen Space**: Post-processing effect using hint_screen_texture

## Credits

- **Original Shader Author**: Daniel Bologna (AbstractBorderStudio)
- **Inspiration**: Acerola's "I Tried Turning Games Into Text" video
- **Repository**: https://github.com/AbstractBorderStudio/Ascii_Shader
- **Godot Shaders**: https://godotshaders.com/author/dan/

## Notes

- The shader is currently configured to show the colored ASCII output
- To switch to black & white mode, change line 93 in the shader from `ALBEDO = col;` to `ALBEDO = vec3(ascii);`
- Edge detection is not yet implemented (future enhancement)
- Performance impact is minimal as this is a simple post-processing effect

## Troubleshooting

If the shader doesn't appear:
1. Make sure you're running Godot 4.3 or later
2. Check that the texture import files are correctly configured
3. Verify the ASCIIPostProcess node is visible
4. Try pressing F1 to toggle the effect on

If you see white/black screen:
1. Check that the ASCII textures are properly imported
2. Verify the texture paths in the ShaderMaterial
3. Open the .import files and confirm the source_file paths are correct