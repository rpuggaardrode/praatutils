.onLoad <- function(...) {
  if ('RETICULATE_PYTHON' %in% Sys.getenv()) {
    curenv <- Sys.getenv('RETICULATE_PYTHON')
    on.exit(Sys.setenv('RETICULATE_PYTHON' = curenv))
  } else {
    on.exit(Sys.unsetenv('RETICULATE_PYTHON'))
  }
  Sys.setenv('RETICULATE_PYTHON' = 'managed')
  reticulate::py_require('praat-parselmouth')
  p <<- reticulate::import('parselmouth', delay_load = TRUE)
}
