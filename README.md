# Palette Trike

Create complete colour palettes for your projects.

## Usage

You may think of each strip of colours as a separate material. Each strip is defined by 3 colours - 3 points in colour space that define a curve from which all the shades are picked.

Once happy with your set of colours you can export a .png and import it as reference into your image editor.

## Maths used

Curves:
- Bezier - the curve does not go through the mid point.
- Quadratic - the curve does cross the mid point.
- Resampled - this mode tries to pick points in equal distance along the curve. Useful when values seem too focused around the same shade or do not flow smoothly from edge to edge.

Colours are interpolated in the oklab space.

## Future

No further releases planned.
