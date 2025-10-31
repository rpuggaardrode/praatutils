#' Combine data frames with signal information and TextGrid labels
#'
#' Given a data frame with signal information and a data frame with TextGrid
#' labels, combine the two such that the TextGrid labels for each time step
#' is appended to the signal data.
#'
#' @param signal A data frame with signal data, e.g. formants or pitch,
#' generated with the corresponding `praatutils` functions.
#' @param TextGrid A data frame with TextGrid data generated with
#' `readTextGrid()`.
#' @param soundExt String giving the file extension of the audio files used
#' to generate `signal`; default is `.wav`. This is used to match file
#' names across the two input data frames.
#' @param tgExt String giving the file extension of the TextGrid files used
#' to generate `TextGrid`; default is `.TextGrid`. This is used to match file
#' names across the two input data frames.
#'
#' @returns A data frame with column names corresponding to `signal` and
#' `TextGrid`, and row numbers corresponding to `signal`.
#' @export
#'
#' @examples
#' datapath <- system.file('extdata', package='praatutils')
#' soundFile <- paste0(datapath, '/1.wav')
#' tgFile <- paste0(datapath, '/1.TextGrid')
#' pit <- pitchRawAC(soundFile, output = 'df')
#' tg <- readTextGrid(tgFile)
#' res <- addTextGridLabels(pit, tg)
addTextGridLabels <- function(signal, TextGrid,
                              soundExt = '.wav', tgExt = '.TextGrid') {

  files <- unique(TextGrid$file)
  tiers <- unique(TextGrid$tier)

  for (f in files) {
    sigFile <- signal[which(signal$file == gsub(tgExt, soundExt, f)),]
    tgFile <- TextGrid[which(TextGrid$file == f),]
    for (x in tiers) {
      sigFile[,x] <- NA
      idCol <- paste0(x, '_id')
      sigFile[,idCol] <- NA
      filt <- tgFile[which(tgFile$tier == x),]
      for (i in 1:nrow(filt)) {
        sigFile[which(sigFile$t >= filt$tmin[i] &
                        sigFile$t <= filt$tmax[i]),x] <-
          filt$text[i]
        sigFile[which(sigFile$t >= filt$tmin[i] &
                        sigFile$t <= filt$tmax[i]),idCol] <-
          filt$id[i]
      }
    }
    if ('out' %in% ls()) {
      out <- rbind(out, sigFile)
    } else {
      out <- sigFile
    }
  }

  return(out)

}
