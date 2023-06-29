bind_all_excel <- function(data_directory) {
all_excel = list.files(DataDir, pattern='*.xlsx',full.names=TRUE)
df.list <- lapply(all_excel, read_excel,col_names=TRUE)
df <- bind_rows(df.list, .id = NULL)
df
}
  