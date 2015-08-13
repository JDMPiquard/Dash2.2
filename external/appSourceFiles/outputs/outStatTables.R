# JD for Portr LTD
# Main table outputs used in the statistics tab
#

# USER NATIONALITIES
  # Table
  output$nation  <- renderDataTable({
    if (is.null(ready())) return(NULL)
    
    allData <- bookingsRange()
    # summarize by country of origin
    nat.df <- ddply (allData, "country_origin", summarize, bookings = length(Cancelled),
      totalBags = sum(Total_luggage_No), meanBags = round(mean(Total_luggage_No),digits=1),
      netRevenue = round(sum(Booking_value_gross_total)/1.2))
    nat.df$avgRevenue <- round(nat.df$netRevenue/nat.df$bookings, digits=2)
    nat.df <- nat.df[with(nat.df,order(-bookings,-avgRevenue)), ]
    rownames(nat.df) <- NULL
    
    nat.df
  }, options = list(pageLength = 5))

# REPEAT CUSTOMERS
  # TITLE: % REPEAT USERS (inc calculation of % re-user)
  output$reUser  <- renderText({
    if (is.null(ready())) return(NULL)
    
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
    
  }, options = list(pageLength = 5))

# TABLE: MAIN DELIVERY DESTINATIONS
output$loc <- renderDataTable({
  if (is.null(ready())) return(NULL)
  
  allData <- bookingsRange()
  
  loc.df <- ddply (allData, "Outward_Journey_Luggage_drop_off_location_Name", summarize,
    bookings = length(Cancelled), totalBags = sum(Total_luggage_No),
    meanBags = round(mean(Total_luggage_No),digits=1),
    netRevenue = round(sum(Booking_value_gross_total)/1.2))
  loc.df$avgRevenue <- round(loc.df$netRevenue/loc.df$bookings, digits=2)
  loc.df <- loc.df[with(loc.df,order(-bookings,-avgRevenue)), ]
  #loc.df <- loc.df[loc.df$bookings>1,]
  loc.df <- loc.df[loc.df$netRevenue>0,]
  #loc.df <- loc.df[- grep("Residential",loc.df$Outward_Journey_Luggage_drop_off_location_Name), ]
  #loc.df <- loc.df[- grep("Airportr",loc.df$Outward_Journey_Luggage_drop_off_location_Name), ]
  rownames(loc.df) <- NULL
  
  loc.df
  
}, options = list(pageLength = 10))

# FLIGHTS
  # Inbound Flights data table
  output$inFlights <- renderDataTable({
    if (is.null(ready())) return(NULL)
    
    bookings <- bookingsRange()
    
    df <- ddply (bookings, "In.bound_flt_code", summarize, bookings = length(Cancelled),
      totalBags = sum(Total_luggage_No), meanBags = round(mean(Total_luggage_No),digits=1),
      netRevenue = round(sum(Booking_value_gross_total)/1.2))
    df <- df[with(df, order(bookings, decreasing=T)),]
    
  }, options = list(pageLength = 10))
  
  # Outbound Flights data table
  output$outFlights <- renderDataTable({
    if (is.null(ready())) return(NULL)
    
    bookings <- bookingsRange()
    
    df <- ddply (bookings, "Out.bound_flt_code", summarize, 
      bookings = length(Cancelled), totalBags = sum(Total_luggage_No), 
      meanBags = round(mean(Total_luggage_No),digits=1), 
      netRevenue = round(sum(Booking_value_gross_total)/1.2))
    df <- df[with(df, order(bookings, decreasing=T)),]
    
  }, options = list(pageLength = 10))
