## Version 0.0.7
* Now with global delayed loading of `parselmouth`.

## Version 0.0.6
* Improved, safer handling of global environment variables on load.
* `saveAsWav()` now allows for other file edits, such as sampling rate and
conversion to mono.

## Version 0.0.5
* The data frame output from `readTextGrid()` now contains an `id` column, 
which is also transfered to data frames created with `addTextGridLabels()`.

## Version 0.0.4
* Improved handling of file output name in `saveAsWav()`, so there is now a 
sensible default which simply copies the input file name with `.wav` extension.

## Version 0.0.3
* Added function `saveAsWav()` for saving any Praat-readable sound file as a WAV 
file.

## Version 0.0.2

* Fix to `addTextGridLabels()`, which didn't work properly for bulk processing
in previous version.

## Version 0.0.1

First release!
