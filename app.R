#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinythemes)
library(DT)
library(vroom)

library(httr)
library(jsonlite)

# load functions
source("./retry.R")
source("./helium_rewards_function_2.R")
source("./helium_rewards_function_part1.R")

#library(bslib)
#library(thematic)
#thematic::thematic_shiny(font = "auto")
ui = tagList(
  
  navbarPage(
    theme = shinythemes::shinytheme("flatly"),  # <--- To use a theme, uncomment this
    HTML("<a href=\"http://EcoMyne.com\">EcoMyne.com</a>"),
    tabPanel("HNT reward report",
             sidebarPanel(
               p("Replace Wallet/Account ID!", style = "color:#08B439"),
               textInput("wallet_ID", "Account/Wallet ID:", "13fT8LBGiz6MtXe6AsP7jiqe7oR4YoGzCTfGiswBRFgJeKWifce"),
               HTML("<br> <br> <br>"),
               p(" Define time range for report.", style = "color:#08B439"),
               # Default start and end is the current date in the client's time zone
               #dateRangeInput("daterange2", "Please choose a date reange you want to have a report for:"),
               dateInput("date1", "Date to start the report from:",value = "2021-12-01", min = "2020-01-01", max = "2021-12-01"),
               dateInput("date2", "Date to end the report with:",value = "2021-12-01", min = "2020-01-01", max = "2021-12-01"),
               HTML("<br> <br> <br>"),
               p("Your reward for the choosen time range:", style = "color:#4d4d4d"),
               verbatimTextOutput("verb", placeholder = TRUE),
               verbatimTextOutput("usd", placeholder = TRUE),
               downloadButton("download", "Download report as .tsv", style = "background-color:##4d4d4d")
               #airDatepickerInput("input_var_name",
              #                    label = "Start month",
              #                    value = "2015-10-01",
              #                    maxDate = "2016-08-01",
              #                    minDate = "2015-08-01",
              #                    view = "months", #editing what the popup calendar shows when it opens
              #                    minView = "months", #making it not possible to go down to a "days" view and pick the wrong date
               #                   dateFormat = "yyyy-mm"
               #)
             ),
             mainPanel(
               tabsetPanel(
                 tabPanel("Table of reward",
                          p(),
                          DTOutput("table")
                 )
               )
             )
    ),
    #tabPanel("About", "This panel is intentionally left blank")
  )
)


server = function(input, output, session) {
  
  # load data
  df_exchange_1 <- readRDS("./data_frame_exchange_hnt_eur_usd_210101_211210.rds")
  
  

  data <- reactive({
    
    #-----------------------#
    #----Data to run the loop ------------#
    #------------------------#
    
    # user have to enter this variables
    account = input$wallet_ID
    time1 = input$date1
    time2 = input$date2
    
    df <- helium_rewards(account = account,
                         time1 = time1,
                         time2 = time2)
    
    # load data frame with historical data

    df_exchange_1$date <- as.character(df_exchange_1$date)
    # subset data frame to time range
    df_exchange_1_subset <- df_exchange_1[df_exchange_1$date %in% df$date,]
    #insert exchange rates and rewards per day
    df$Exchange_rate_EUR <- df_exchange_1_subset$HNT_to_eur
    df$Exchange_rate_USD <- df_exchange_1_subset$HNT_to_usd
    
    df$reward_in_EUR <- as.numeric(df$total_HNT)*as.numeric(df$Exchange_rate_EUR)
    df$reward_in_USD <- as.numeric(df$total_HNT)*as.numeric(df$Exchange_rate_USD)
    
    
    df$total_HNT <- round(as.numeric(df$total_HNT), digits = 2)
    df$Exchange_rate_EUR <- round(as.numeric(df$Exchange_rate_EUR), digits = 2)
    df$Exchange_rate_USD <- round(as.numeric(df$Exchange_rate_USD), digits = 2)
    df$reward_in_EUR <- round(as.numeric(df$reward_in_EUR), digits = 2)
    df$reward_in_USD <- round(as.numeric(df$reward_in_USD), digits = 2)
    df <- as.data.frame(df)
  })
  
  
  output$table <- DT::renderDataTable({
    DT::datatable(data(), options = list(searching=FALSE,
                                         pageLength = 15
    ),
    rownames = FALSE)#%>% DT::formatStyle(columns = names(cars), color="white")
  })
  
  #-------#
  #--sum rewards output --#
  #----------------#
  
  output$verb <- renderText({
    
    df_sum <- as.data.frame(data())
    df_sum <- sum(as.numeric(df_sum$reward_in_EUR))
    df_sum <- as.numeric(df_sum)
    df_sum <- round(df_sum, digits = 2)
    paste0(df_sum, " EUR")
    
    
  })
  
  output$usd <- renderText({
    
    df_sum <- as.data.frame(data())
    df_sum <- sum(as.numeric(df_sum$reward_in_USD))
    df_sum <- as.numeric(df_sum)
    df_sum <- round(df_sum, digits = 2)
    paste0(df_sum, " USD")
    
    
  })
  
  
  #------------------#
  #---download report --------#
  #----------------#
  
  output$download <- downloadHandler(
    filename = function() {
      paste0("report", ".tsv")
    },
    content = function(file) {
      vroom::vroom_write(data(), file)
    }
  )
  
  
  
}


# Run the application 
shinyApp(ui = ui, server = server)

