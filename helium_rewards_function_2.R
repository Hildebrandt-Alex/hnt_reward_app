helium_rewards <- function(account, time1, time2){
  
  
  
  #calculation of days for hnt api
  df_days <- data.frame(end = time2, start = time1)
  df_days$days <- as.Date(as.character(df_days$end))-
    as.Date(as.character(df_days$start))
  df_days$days
  
  #calculation of days for coin gecko api
  days_2 <- seq(as.Date(time1), as.Date(time2), by="days")
  days_2 <- format(days_2, "%d-%m-%Y")
  # create vector of all days
  seq(as.Date(time1), as.Date(time2), by="days")
  
  # create empty data frame to fill in the for loop
  df_summary <- data.frame(matrix(ncol = 6, nrow = df_days$days +1))
  names(df_summary) <- c("date", "total_HNT", "Exchange_rate_EUR", "Exchange_rate_USD", "reward_in_EUR", "reward_in_USD")
  # inster all days in data frame
  days_1 <- seq(as.Date(time1), as.Date(time2), by="days")
  days_1 <- format(days_1, "%Y-%m-%d")
  df_summary$date <- days_1
  
  #-----------------------#
  #----for loop HELIUM rewards------------#
  #------------------------#
  for (i in 1:nrow(df_summary)) {
    # Base URL path
    base_url = "https://api.helium.io/v1/accounts/"
    url_2 = "/rewards/sum?min_time="
    url_3 = "T00:00:01Z&max_time="
    url_4 = "T23:59:59Z"
    full_url = paste0(base_url, account, url_2, df_summary$date[i], url_3, df_summary$date[i], url_4)
    
    # rewards fuction
    rewards <- retry(rewards(full_url=full_url), maxErrors = 100, sleep = 2)
    # put data in data frame summary
    df_summary[i,2] <- rewards[2,3]
  }
  return(df_summary)
}