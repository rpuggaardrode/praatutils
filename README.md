
<!-- README.md is generated from README.Rmd. Please edit that file -->

# praatutils

`praatutils` is a developmental R package that aims to provide
relatively hassle-free access to some of the signal processing of
[Praat](https://fon.hum.uva.nl/praat).

There are already tools in R to help interact with Praat. Praat shows up
in five package descriptions on
[CRAN](https://cran.r-project.org/web/packages/available_packages_by_name.html):
[`textgRid`](https://cran.r-project.org/web/packages/textgRid/index.html)
and
[`readtextgrid`](https://cran.r-project.org/web/packages/readtextgrid/index.html)
provide tools for working with the TextGrid annotation format,
[`speakr`](https://cran.r-project.org/web/packages/speakr/index.html)
provides methods for running Praat scripts from R and reading in
results. My library
[`praatpicture`](https://cran.r-project.org/web/packages/praatpicture/index.html)
provides methods for plotting acoustic data, including data from Praat
objects. Finally the package
[`phonfieldwork`](https://cran.r-project.org/web/packages/phonfieldwork/index.html)
provides, among other things, some ways of interacting with Praat
objects.

These are all great tools, but to the extent that they provide access to
Praat’s extensive and excellent signal processing tools, they require
files to be generated and saved in Praat, or they require pre-existing
Praat scripts.
[`speakr`](https://cran.r-project.org/web/packages/speakr/index.html)
calls Praat through a shell, which is a method that I rely on very
often, but which tends to be a bit fragile across operating systems,
which can cause trouble for general-purpose pipelines. I suspect that
what many users *really* want is the ability to call Praat’s source code
from R and get outputs that are interpretable from R – similar to how
the library
[`wrassp`](https://cran.r-project.org/web/packages/wrassp/index.html)
provides direct access to the signal processing library ASSP by calling
the underlying C code.

Python users can do this with the
[`parselmouth`](https://parselmouth.readthedocs.io/en/stable/) library,
which provides a ‘pythonic’ approach to accessing Praat routines through
a direct C/C++ interface with wrapper functions for many routines and an
ability to call any non-wrapped routine through a generic `call()`
function. Arguably a major advantage of `parselmouth` is that it comes
bundled with a specific Praat version, which means that it’s not reliant
on calling an installation of Praat that’s already *somewhere* on the
user’s system. This ability to access all of Praat through a
general-purpose programming language is fantastic, and the approach
probably jives very well with what Python users are looking for. My
sense is that R users are looking for a different approach,
e.g. reducing the steps needed from going from a directory of WAV files
to a nice data frame with derived signal values. (Or that may just be
what **I’m** looking for.)

`praatutils` is an attempt at exactly this: providing functions that
call Praat’s source code directly to do signal processing and return
familiar objects like data frames. This is mainly done via `parselmouth`
and is made possible by the R library
[`reticulate`](https://www.r-bloggers.com/2022/04/getting-started-with-python-using-r-and-reticulate/)
which manages interfaces between R and Python. If nothing fails, this
should mean that the user doesn’t need to point R towards a specific
installation of Python or a specific installation of Praat – when
`praatutils` is first called, `reticulate` makes sure that everything is
installed and can be called, installs anything that’s missing, and this
may take a few seconds, but every subsequent `praatutils` call in the
same session is done with very minimal overhead.

This is just a very first attempt at a durable Praat/R interface that
doesn’t do very much (not yet at least)! If you have ideas about ways to
improve, if you’re missing something, or especially if you’re interested
in contributing, feel free to reach out!

## Installation

You can install the development version of `praatutils` from
[GitHub](https://github.com/) with:

``` r
# install.packages('devtools)
devtools::install_github('rpuggaardrode/praatutils')
```

## Basic usage

I’ll introduce a few basic functions here.

``` r
library(praatutils)
```

The function `readSound()` reads in a sound file. This is arguably
preferable to functions provided by other libraries since Praat is
relatively file type agnostic. The output is a list with some basic
information about the sound file, such as sampling rate, start time, end
time, etc, as well as the signal.

``` r
snd <- readSound('1.wav')
snd$fs; snd$start; snd$end
#> [1] 44100
#> [1] 0
#> [1] 1.439637
plot(snd$t, snd$signal, type = 'l', xlab = 'Time (s)', ylab = '')
```

<img src="man/figures/README-unnamed-chunk-3-1.png" width="100%" />

You can choose to read in just a portion of the sound file:

``` r
snd <- readSound('1.wav', start = 0.6, end = 1)
plot(snd$t, snd$signal, type = 'l', xlab = 'Time (s)', ylab = '')
```

<img src="man/figures/README-unnamed-chunk-4-1.png" width="100%" />

Pitch can be tracked with the functions `pitchRawAC()`, `pitchRawCC()`
or `pitchSHS()`. By default, the output of these functions have a format
similar to the output of `wrassp` functions like `ksvF0()`:

``` r
(pitAC <- pitchRawAC('1.wav'))
#> In-memory Assp Data Object
#> Format: SSFF (binary)
#> 141 records at 100 Hz
#> Duration: 1.410000 s
#> Number of tracks: 1 
#>   F0 (1 fields)
```

(This is useful if you want to use `praatutils` in combination with
`praatpicture`, where these objects can then be plotted by passing them
to the `pitch_ssff` argument:)

``` r
library(praatpicture)
praatpicture('1.wav', frames = c('sound', 'pitch'), start = 0.6, end = 1,
             pitch_freqRange = c(50, 200), pitch_plotType = c('draw', 'speckle'),
             pitch_ssff = pitAC)
```

<img src="man/figures/README-unnamed-chunk-6-1.png" width="100%" />

Alternatively, you can specify different outputs with the `output`
argument. Use `output = 'df'` for a data frame:

``` r
pitAC <- pitchRawAC('1.wav', start = 0.65, end = 1,
                    output = 'df')
head(pitAC)
#>    file    t       f0
#> 1 1.wav 0.67 144.3324
#> 2 1.wav 0.68 145.3309
#> 3 1.wav 0.69 146.7827
#> 4 1.wav 0.70 147.8951
#> 5 1.wav 0.71       NA
#> 6 1.wav 0.72       NA
plot(pitAC$t, pitAC$f0, pch = 20, xlab = 'Time (s)', ylab = 'f0 (Hz)')
```

<img src="man/figures/README-unnamed-chunk-7-1.png" width="100%" />

As the `file` column suggests, these functions can process multiple
files at once:

``` r
pitAC <- pitchRawAC(c('1.wav', '2.wav'), output = 'df')
nrow(pitAC); unique(pitAC$file)
#> [1] 299
#> [1] "1.wav" "2.wav"
```

You can also point these functions towards a directory, in which case
all audio files in the directory are processed:

``` r
list.files('.', pattern = '*.wav')
#> [1] "1.wav" "2.wav" "3.wav"
pitAC <- pitchRawAC('.', output = 'df')
nrow(pitAC); unique(pitAC$file)
#> [1] 439
#> [1] "1.wav" "2.wav" "3.wav"
```

To get a long data frame with information about all pitch candidates,
use `output = 'candidates'`:

``` r
pitAC <- pitchRawAC('1.wav', output = 'candidates')
plot(pitAC$t, pitAC$frequency, pch = 20, 
     xlim = c(0.6, 1.2), ylim = c(50, 200), 
     cex = pitAC$strength * 2,
     xlab = 'Time (s)', ylab = 'f0 (Hz)')
```

<img src="man/figures/README-unnamed-chunk-10-1.png" width="100%" />

Crucially, all the usual pitch tracking parameters can be controlled,
and some of Praat’s post-processing tools can be automatically applied:

``` r
args(pitchRawAC)
#> function (filename, output = "ssff", ext = ".wav", timeStep = NULL, 
#>     start = NULL, end = NULL, times = NULL, floor = 75, ceiling = 600, 
#>     maxNoCandidates = 15, gaussianWindow = FALSE, silenceThreshold = 0.03, 
#>     voicingThreshold = 0.45, octaveCost = 0.01, octaveJumpCost = 0.35, 
#>     voicedUnvoicedCost = 0.14, interpolate = FALSE, smoothingBW = NULL, 
#>     killOctaveJumps = FALSE, toFile = FALSE, outputDir = getwd(), 
#>     outputExt = ".f0") 
#> NULL
```

Formants can be tracked using the `formantBurg()` function:

``` r
fmt <- formantBurg('1.wav', output = 'df', start = 0.6, end = 1.2)
plot(fmt$t, fmt$F1, ylim = c(0, 5000),
     xlab = 'Time (s)', ylab = 'Frequency (Hz)',
     pch = 20, col = 'red')
points(fmt$t, fmt$F2, pch = 20, col = 'blue')
points(fmt$t, fmt$F3, pch = 20, col = 'darkgreen')
points(fmt$t, fmt$F4, pch = 20, col = 'orange')
```

<img src="man/figures/README-unnamed-chunk-12-1.png" width="100%" />

Viterbi tracking can be done on the formants as a built-in
post-processing step. Here we track 3 formants with the default
reference frequencies:

``` r
fmt <- formantBurg('1.wav', output = 'df', start = 0.6, end = 1.2, 
                   track = 3)
plot(fmt$t, fmt$F1, ylim = c(0, 5000),
     xlab = 'Time (s)', ylab = 'Frequency (Hz)',
     pch = 20, col = 'red')
points(fmt$t, fmt$F2, pch = 20, col = 'blue')
points(fmt$t, fmt$F3, pch = 20, col = 'darkgreen')
```

<img src="man/figures/README-unnamed-chunk-13-1.png" width="100%" />

Other signal processing functions currently available are
`harmonicityAC()`, `harmonicityCC()`, `intensity()`, and `spectrogram()`
(which works a little differently). Functions are available for reading
in existing Praat objects stored to disk (`readPitch()`,
`readFormant()`, etc) as data frames.

If you want some quick information about a file you can use the
`printInfo()` function:

``` r
printInfo('1.Intensity')
#> Object id: 1
#> Object type: Intensity
#> Object name: untitled
#> Date: Fri May 23 17:40:27 2025
#> 
#> Time domain:
#>    Start time: 0 seconds
#>    End time: 1.4396371882086167 seconds
#>    Total duration: 1.4396371882086167 seconds
#> Time sampling:
#>    Number of frames: 172
#>    Time step: 0.008 seconds
#>    First frame centred at: 0.03581859410430832 seconds
```

The function `readTextGrid()` can be used to read annotation information
from a TextGrid as a data frame. This TextGrid has one tier “Mary” with
two labels “b”, “a”.

``` r
(tg <- readTextGrid('1.TextGrid'))
#>         file  tmin tier text  tmax
#> 1 1.TextGrid 0.647 Mary    b 0.720
#> 2 1.TextGrid 0.720 Mary    a 0.911
```

The function `addTextGridLabels()` allows for this information to be
matched with signal data:

``` r
fmt <- addTextGridLabels(fmt, tg)
fmt[10:20,]
#>     file     t nformants       F1       F2       F3 Mary
#> 10 1.wav 0.684         3 1102.449 2665.088 3717.182    b
#> 11 1.wav 0.691         3 1107.439 2645.259 3667.984    b
#> 12 1.wav 0.697         3 1131.418 2623.783 3606.976    b
#> 13 1.wav 0.703         3 1118.389 2626.729 3655.853    b
#> 14 1.wav 0.709         3 1696.587 2450.620 3967.632    b
#> 15 1.wav 0.716         3  575.738 1766.780 2421.986    b
#> 16 1.wav 0.722         3  689.415 1626.651 2340.185    a
#> 17 1.wav 0.728         3  660.428 1215.000 2795.875    a
#> 18 1.wav 0.734         3  683.508 1264.819 2899.048    a
#> 19 1.wav 0.741         3  709.209 1307.417 2918.493    a
#> 20 1.wav 0.747         3  730.858 1326.587 2933.454    a
```

This adds a new column with the tier name “Mary” indicating the label at
any given time, making it easy to e.g. filter the object to only
instances covered by the label “a”:

``` r
fmt_a <- fmt[which(fmt$Mary == 'a'),]
plot(fmt_a$t, fmt_a$F1, ylim = c(0, 5000),
     xlab = 'Time (s)', ylab = 'Frequency (Hz)',
     pch = 20, col = 'red')
points(fmt_a$t, fmt_a$F2, pch = 20, col = 'blue')
points(fmt_a$t, fmt_a$F3, pch = 20, col = 'darkgreen')
```

<img src="man/figures/README-unnamed-chunk-17-1.png" width="100%" />
