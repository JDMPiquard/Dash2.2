#  JD for Portr, June 2015
#  Defines core User selector/manipulations for internal dahsboard


div(  
  #  TITLE BAR
  fluidRow(
    column(2, 
      img(src="logo2.png", width = 70, height = 70, style = "border-radius: 50%; float = bottom")
    ),
    column(6,
      h1("Portr Dash Two")
    ),
    column(4,
      fileInput("file", label = " ")  #  file input    
    )
    ),
  
  #  TOP INPUT BOX
  div(class="topBox",
    fluidRow(
      column(6,
        fluidRow(
          column(11,
            fluidRow(
              h5("Analyse Portr booking data using simple interface"),
              p("Choose appropriate date range to see in action (see options right).
                Ignore any errors until a bookings.csv file has been uploaded, can be found at ", 
                a(href="https://booking.portr.com/Partner/ViewBookings", target ="_blank", "booking.portr.com"))
            )
          ),
          column(1,
            p(" ")
          )
        ),
        fluidRow(  #  Report mode checkbox - filters out irrelevant stuff
          h6("Reporting options"),
          column(6,
            checkboxInput("reportMode", label="activate report mode")
          ),
          column(6,
            checkboxInput("showAll", label = "exclude 0GBP bookings", value = F)
          )
        )
      ),
          
          
      column(6,
        column(4,
          checkboxGroupInput("checkAirport", label= "filter by airport",
                                           choices = c("LHR", "LGW", "LCY", "STN", "Storage"),
                                           selected = c("LHR", "LGW", "LCY", "STN", "Storage"))
        ),
        column(8,  
          fluidRow(
            radioButtons("radio", label = "analysis mode (date selection)",
                                       choices = list("All Time" = 1, "Date Range" = 2, "Today Only" = 3), 
                                       selected = 2)
            ),
                        
          fluidRow(
            dateRangeInput("dates",start = as.character(Sys.Date()-6), 
                                         end = as.character(Sys.Date()), 
                                         label = "date range to analyse")
          )
        )
      )
    )
  )
)