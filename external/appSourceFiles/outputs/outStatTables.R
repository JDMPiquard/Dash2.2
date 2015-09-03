# JD for Portr LTD
# Main table outputs used in the statistics tab
#

# define default page length for tables
table.default = 5

# REFERRAL LINKS
  # Table
  output$refLink  <- renderDataTable({
    if (is.null(ready())) return(NULL)
    
    # summarize by country of origin
    ref.df <- summarizeMI(bookingsRange(), "Booking_refferal_source_url", pretty=T)
    #
    ref.df
  }, options = list(pageLength = table.default))

# USER NATIONALITIES
  # Table
  output$nation  <- renderDataTable({
    if (is.null(ready())) return(NULL)
    
    # summarize by country of origin
    nat.df <- summarizeMI(bookingsRange(), "country_origin", pretty=T)
    #
    nat.df
  }, options = list(pageLength = table.default))

# REPEAT CUSTOMERS
  # TITLE: % REPEAT USERS (inc calculation of % re-user)
  output$reUser  <- renderText({
    if (is.null(ready())) return(NULL)
    
    # NOTE: the following has severe limitations, requiring the use of an all time KPI to correctly compute/identify repeat customers

    allData <- bookingsRange()
    
    reUser.df <- reUser()
    
    reUser <- length(reUser.df$bookings)
    reUserpct <- round(reUser/length(allData$Cancelled),digits=3)*100
    paste("Repeat Users: ", reUser, "total, so really about ",reUserpct,"%")
    
  })
  

  # TABLE: REPEAT CUSTOMERS
  output$custom <- renderDataTable({
    if (is.null(ready())) return(NULL)
    
    reUser()
    
  }, options = list(pageLength = table.default))


# TABLE: MAIN DELIVERY DESTINATIONS
output$loc <- renderDataTable({
  if (is.null(ready())) return(NULL)
  
  # For some reason the pretty option is breaking the 
  loc.df <- summarizeMI(bookingsRange(), "Outward_Journey_Luggage_drop_off_location_Name", pretty=F)

  # allData <- bookingsRange()
  
  # loc.df <- ddply (allData, "Outward_Journey_Luggage_drop_off_location_Name", summarize,
  #   bookings = length(Cancelled), totalBags = sum(Total_luggage_No),
  #   meanBags = round(mean(Total_luggage_No),digits=1),
  #   netRevenue = round(sum(Booking_value_gross_total)/1.2))
  # loc.df$avgRevenue <- round(loc.df$netRevenue/loc.df$bookings, digits=2)
  # loc.df <- loc.df[with(loc.df,order(-bookings,-avgRevenue)), ]
  #loc.df <- loc.df[loc.df$bookings>1,]
  loc.df <- loc.df[loc.df$netRevenue>0,]
  rownames(loc.df) <- NULL
  
  loc.df
  
}, options = list(pageLength = table.default))

# FLIGHTS
  # Inbound Flights data table
  output$inFlights <- renderDataTable({
    if (is.null(ready())) return(NULL)
    
    df <- summarizeMI(bookingsRange(),"In.bound_flt_code", pretty=T)
    # df <- df[with(df, order(bkgs, decreasing=T)),]
    
  }, options = list(pageLength = table.default))
  
  # Outbound Flights data table
  output$outFlights <- renderDataTable({
    if (is.null(ready())) return(NULL)
    
    df <- summarizeMI(bookingsRange(),"Out.bound_flt_code", pretty=T)
    # df <- df[with(df, order(bookings, decreasing=T)),]
    
  }, options = list(pageLength = table.default))

  # AIRLINES
  # inbound
  output$inAirlines <- renderDataTable({
    if (is.null(ready())) return(NULL)
    
    df <- summarizeMI(bookingsRange(),"inAirline", pretty=T)

  }, options = list(pageLength = table.default))

  # outbound
  output$outAirlines <- renderDataTable({
    if (is.null(ready())) return(NULL)
    
    df <- summarizeMI(bookingsRange(),"outAirline", pretty=T)

  }, options = list(pageLength = table.default))

