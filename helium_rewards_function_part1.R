rewards <- function(full_url){
  # get data from api url
  rf <- GET(full_url)
  rfc <- content(rf)
  
  # unlist json data
  json_file <- sapply(rfc, function(x) {
    x[sapply(x, is.null)] <- NA
    unlist(x)
    as.data.frame(t(x))
  })
  
  # creating data frame with extracted values
  df_helium_account <- data.table::rbindlist(json_file, fill = TRUE)
  
  
  return(df_helium_account)
}
