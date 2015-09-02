#  JD for Portr Ltd, June 2015
#  Main back end file, sourcing functions and most output generations from other files
#


#  source major functions
source('external/functions.R', local=T)

#  source reactive expressions and other code
source('external/appSourceFiles/reactives.R', local=T)  #  reactives
source('external/appSourceFiles/reactKPI.R', local=T)

# INDICATIVE TEXT/TITLES
  # show selected date range in title
  output$textDates  <- renderText({
    paste("Summary for",range()[1]," to ",range()[2])
  })

  # show selected airports
  output$selectedAirports <- renderText({
    paste("Portr Ltd Performance Dashboard for ",paste(input$checkAirport,collapse=" + "))
  })

  output$sumStats  <- renderText({
    if(input$radio==1){
      return("All time Summary")
    }
    else if(input$radio==2){
      return(paste("Summary for",range()[1]," to ",range()[2]))
    }
    else if(input$radio==3){
      return("Data for today only")
    }
  })

# MAIN GRAPH OUTPUT
source('external/appSourceFiles/outputs/outMainGraph.R',local=T)

# BOXED OUTPUTS
source('external/appSourceFiles/outputs/outBoxNum.R',local=T)

# MAP OUTPUT
source('external/appSourceFiles/outputs/outMap.R',local=T)

# PIE CHARTS
source('external/appSourceFiles/outputs/outPie.R',local=T)

# STAT TABLES
source('external/appSourceFiles/outputs/outStatTables.R',local=T)

# CONTINUOUS TIME GRAPHS
# includes hour by hour avg deliveries and day by day
source('external/appSourceFiles/outputs/outTimePlots.R',local=T)







# SUMMARY TABLE (TAB 1: SUMMARY)
  output$contents  <- renderDataTable({
    if (is.null(ready())) return(NULL)
    
    sumBookings  <- contDate()
    #manipulating for prettyness
    #   sumBookings$Outward_Journey_Luggage_drop_off_date <- NULL
    #   sumBookings$meanBags  <- round(sumBookings$meanBags,1)
    #   sumBookings$netRevenue <- round(sumBookings$netRevenue,2)
    #   sumBookings$meanNetRevenue <- round(sumBookings$meanNetRevenue,2)
    
    sumBookings
    
  }, options = list(pageLength = 10))

# SUMMARY REPORTS (Tab 3)
  
  # A.C.E. PERFORMANCE REPORTS
  

  output$ACE <- renderDataTable({
    if (is.null(ready())) return(NULL)

    ACE <- summarizeMI(bookingsRange(), "User_name", pretty=T)

  }, options = list(pageLength = 10))

  output$downloadACE <- downloadHandler(

    filename = function() { paste("ACE Report",range()[1]," to ",range()[2],
        '.csv', sep='') },
    content = function(file) {
        write.csv(summarizeMI(bookingsRange(), "User_name", pretty=T), file)
      }
    )

  # CC&D TABLE
  output$CCnD <- renderDataTable({
    if (is.null(ready())) return(NULL)
    
    bookings <- Carousel()
    
    CC <- bookings[, c("Booking_reference", "Hand_luggage_No","Hold_luggage_No",
                       "Total_luggage_No","Customer_Firstname","customer_surname","country_origin", 
                       "Outward_Journey_Luggage_Collection_date", "Booking_value_gross_total","In.bound_flt_code","Origin")]
    rownames(CC) <- NULL
    names(CC) <- c("Booking","Hand","Hold","Total","Name","Surname","Nat","Date","Value","Flight","Origin")
    
    CC
  })
  # Download Button
    output$downloadCCnD <- downloadHandler(
      filename = function() { paste("CCnD",range()[1]," to ",range()[2],
        '.csv', sep='') },
      content = function(file) {
        write.csv(CarouselShort(), file)
      }
    )

# LGW EPOS REPORT
  # Summary Table
	output$EPOS <- renderDataTable({
	  if (is.null(ready())) return(NULL)
	  lgwEPOS()
	}, options = list(pageLength = 5))

  # Download Button
    output$downloadEPOS <- downloadHandler(
      filename = function(){paste("eposLGW",range()[1]," to ",range()[2],
        '.csv') },
      content = function(file){
        write.table(lgwEPOS(), file, sep='|', row.names=F)
      }
    )

# Debug REPORT
  # Summary Table


  # Download Button
    output$downloadDEBUG <- downloadHandler(
      filename = function(){paste("bookingsDebug",paste(filter(),sep='-'),range()[1]," to ",range()[2],
        '.csv', sep='') },
      content = function(file){
        write.csv(bookingsRange(), file)
      }
    )

