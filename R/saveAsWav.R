#' Save sound file as WAV
#'
#' Save a sound file of any Praat-readable format as a wave file.
#'
#' @param file_in String giving the path to a sound file that can be read by
#' Praat.
#' @param file_out String giving the output path. Default is `NULL`, in which
#' case the output path will be identical to `file_in` except with the `.wav`
#' extension.
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
saveAsWav <- function(file_in, file_out = NULL) {
  if (is.null(file_out)) {
    filetype <- unlist(strsplit(file_in, '\\.'))[2]
    file_out <- gsub(paste0('\\.', filetype), '\\.wav', file_in)
  }

  p <- reticulate::import('parselmouth')
  org <- p$read(file_in)$save(file_out, 'WAV')
}
