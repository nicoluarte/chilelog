library(googlesheets)
## gs_ls()
token <- gs_auth(new_user = TRUE)
saveRDS(token, file = "googleSheetsToken.rds")
