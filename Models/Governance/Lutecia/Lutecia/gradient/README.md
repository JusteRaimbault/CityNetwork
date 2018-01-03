# NetLogo gradient extension

This package contains the NetLogo color gradient extension.

## Using

The following reporter is provided:

 * `gradient:scale` _rgb-colors_ _number_ _range1_ _range2_
  * Reports an RGB color proportional to _number_ along a gradient.
  * _rgb-colors_ should be a list of two RGB colors. An RGB color is a list containing three values between 0 and 255; see the [Programming Guide](http://ccl.northwestern.edu/netlogo/5.0/docs/programming.html) for details.
  * If _range1_ is less than _range2_, the color will be directly mapped to gradient colors. While, if _range2_ is less than _range1_, the color gradient is inverted. If _number_ is less than _range1_, then the first color of is  _rgb-colors_ is chosen. If _number_ is greater than _range2_, then the last color of is _rgb-colors_ is chosen.

Example usage:

    ask patches [ set pcolor gradient:scale [[255 0 0] [0 0 255]] pxcor min-pxcor max-pxcor ]`

See also the included Gradient Example model.

## Building

Use the NETLOGO environment variable to tell the Makefile which NetLogo.jar to compile against.  For example:

    NETLOGO=/Applications/NetLogo\\\ 5.0 make

If compilation succeeds, `gradient.jar` will be created.

## Credits

This extension is a subset of the [palette extension](http://ccl.northwestern.edu/extensions/palette/) written by Daniel Kornhauser.  The palette extension includes more primitives for working with color.  It works with NetLogo 4.0, but has not been updated to support more recent NetLogo versions.

## Terms of Use

For more info about the MIT license refer to: http://www.opensource.org/licenses/mit-license.php

Copyright (c) 2007 Daniel Kornhauser

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
