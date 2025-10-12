#' Save sound file as WAV
#'
#' Save a sound file of any Praat-readable format as a wave file.
#'
#' @param file_in String giving the path to a sound file that can be read by
#' Praat.
#' @param file_out String giving the output path.
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
saveAsWav <- function(file_in, file_out) {
  p <- reticulate::import('parselmouth')
  org <- p$read(file_in)$save(file_out, 'WAV')
}
