#' Save sound file as WAV
#'
#' Save a sound file of any Praat-readable format as a wave file, optionally
#' converting to mono and/or resampling to a different frequency.
#'
#' @param file_in String giving the path to a sound file that can be read by
#' Praat.
#' @param file_out String giving the output path. Default is `NULL`, in which
#' case the output path will be identical to `file_in` except with the `.wav`
#' extension.
#' @param mono Logical; should the sound file be converted to mono? Default
#' is `FALSE`.
#' @param resamplingFrequency Numeric; if the file should be resample, which
#' sampling frequency should be used? Default is `NULL`, in which case the
#' sound is not resampled.
#' @param resamplingPrecision Numeric; interpolation depth for resampling in
#' units of samples. Default is `50`.
#'
#' @returns Used for side effects
#' @export
#'
#' @examples
#' \dontrun{
#' datapath <- system.file('extdata', package='praatutils')
#' soundFile <- paste0(datapath, '/1.mp3')
#' saveAsWav(soundFile, '1_asWav.wav')
#' }
saveAsWav <- function(file_in, file_out = NULL, mono = FALSE,
                      resamplingFrequency = NULL, resamplingPrecision = 50) {
  if (is.null(file_out)) {
    filetype <- unlist(strsplit(file_in, '\\.'))[2]
    file_out <- gsub(paste0('\\.', filetype), '\\.wav', file_in)
  }

  p <- reticulate::import('parselmouth')
  org <- p$read(file_in)
  if (mono) org <- org$convert_to_mono()
  if (!is.null(resamplingFrequency)) org <-
    org$resample(resamplingFrequency, as.integer(resamplingPrecision))
  org$save(file_out, 'WAV')
}
