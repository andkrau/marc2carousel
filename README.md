# marc2carousel
This is a utility that converts bibligraphic (MAchine Readable Cataloging) records to HTML carousels.

These tags are required to create the carousel:

 * 245a (Title)
 * 846u with indictator 40 (HTTP resource)
 * 846u with indictator 42 (HTTP Related resource)

This was written to handle records from Hoopla but should be compatible with a variety of eMedia records.

## How

Dragging a `.mrc` file over the executable is the easiest way to generate the carousel.
Command line usage, such as through a batch file, is also supported.

## Example

<a target="_blank" href="https://andkrau.github.io/marc2carousel/example.html"><img src="https://raw.githubusercontent.com/andkrau/marc2carousel/master/example.jpg"></a>