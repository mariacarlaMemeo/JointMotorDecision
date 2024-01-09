bind_all_excel <- function(data_directory) {

all_excel = list.files(data_directory, pattern='*.xlsx', full.names=TRUE)

df.list <- lapply(all_excel, read_excel, col_names=TRUE)
# we should only include columns 1-1061
#df.list <- lapply(all_excel, read_excel(data_directory,sheet = "Sheet1",range=cell_cols(1:1061)),col_names=TRUE)

df <- bind_rows(df.list, .id = NULL)

}
