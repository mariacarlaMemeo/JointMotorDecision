read_all_sheets <- function(filename, grab_name, col_range, tibble = FALSE) {
  # I prefer straight data.frames
  # but if you like tidyverse tibbles (the default with read_excel)
  # then just pass tibble = TRUE
  file = readxl::excel_sheets(filename)
  sheets = which( grepl(grab_name, file))
  x = lapply(sheets, function(s) readxl::read_excel(filename, sheet = s, range = cell_cols(col_range), na = " "))
  
  if(!tibble) x = lapply(x, as.data.frame)
  names(x) = sheets
  x
}
