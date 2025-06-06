#' Read TextGrid file
#'
#' Read TextGrid file generated by Praat in data frame format.
#'
#' @param filename String giving the path to a TextGrid file or a directory
#' of TextGrid files. Alternatively a vector of strings giving the paths to
#' TextGrid files.
#' @param ext String giving the file extension for TextGrid files; default is
#' `.TextGrid`. Only used if `filename` is a directory.
#'
#' @returns A data frame
#' @export
#'
#' @examples
#' datapath <- system.file('extdata', package='praatutils')
#' tgFile <- paste0(datapath, '/1.TextGrid')
#' tg <- readTextGrid(tgFile)
readTextGrid <- function(filename, ext = '.TextGrid') {

  if (any(dir.exists(filename))) filename <-
      list.files(filename, pattern = ext)

  p <- reticulate::import('parselmouth')

  out <- data.frame(file = NULL, tmin = NULL, tier = NULL,
                    text = NULL, tmax = NULL)

  for (f in filename) {
    tg <- p$read(f)
    tmp <- p$praat$call(tg, 'List', 0, 3, 1, 0) |>
      utils::read.table(text = _, header = TRUE, sep = '\t')
    tmp <- cbind(file = rep(f, nrow(tmp)), tmp)
    out <- rbind(out, tmp)
  }

  return(out)

}
