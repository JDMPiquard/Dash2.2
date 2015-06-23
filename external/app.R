#  JD for Portr Ltd, June 2015
#  Main back end file, sourcing functions and most output generations from other files
#


#  source reactive expressions and other code
source('external/appSourceFiles/reactives.R', local=T)  #  reactives

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

#######TAB1#######################################################################################

##Detailed Day Plot########################################################

output$dayPlot <- renderGvis({
  if (is.null(ready())) return(NULL)
  
  sumBookings <- sumDate()
  
  timeMax <- range()[2]
  timeMin <- range()[1]
  allDates  <- seq(timeMin,timeMax,by="day")
  
  allDates.frame <- data.frame(list(date=allDates))
  
  mergeDates <- merge(allDates.frame,sumBookings,all=T)
  
  mergeDates$bookings[which(is.na(mergeDates$bookings))] <- 0
  mergeDates$netRevenue[which(is.na(mergeDates$netRevenue))] <- 0
  
  #df <- mergeDates
  df <- contDate()
  
  Combo <- gvisComboChart(df, xvar="date",
                          yvar=c("netRevenue", "bookings"),
                          #options=list(seriesType="bars",series='{1: {type:"line"}}')
                          options=list(series="[{
                                       type:'line', targetAxisIndex:0
},{
                                       type:'line', targetAxisIndex:1
}]",
                                       vAxes="[{title:'net revenue in GBP'}, {title:'number of bookings'}]",
                                       title= "daily bookings and net revenue",
                                       width = 800
                          )
  )
})

##GENERATING TABLES!!##############################################

#SUMMARY TABLE (TAB 1: SUMMARY)
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

########TAB2##################################################




##DELIVERIES/COLLECTIONS BY HOUR############################
output$hourPlot <- renderGvis({
  if (is.null(ready())) return(NULL)
  
  allData <- bookingsRange()
  
  allData$Collection.Slot  <- strftime(strptime(allData$Outward_Journey_Luggage_Collection_time, format="%H:%M"), "%H")
  allData$Delivery.Slot  <- strftime(strptime(allData$Outward_Journey_Luggage_drop_off_time, format="%H:%M"), "%H")
  allData$Created.Time  <- strftime(strptime(allData$Booking_time, format="%H:%M"), "%H")
  
  time1.df <- ddply (allData, c("Collection.Slot"), summarize, collections = length(Cancelled))
  #time1.df$collectionsPCT <- time1.df/length(allData$Cancelled)*100
  names(time1.df)[1] <- "time"
  time2.df <- ddply (allData, c("Delivery.Slot"), summarize, deliveries = length(Cancelled))
  #time2.df$collectionsPCT <- time2.df/length(allData$Cancelled)*100
  names(time2.df)[1] <- "time"
  time3.df <- ddply (allData, c("Created.Time"), summarize, created = length(Cancelled))
  #time2.df$collectionsPCT <- time2.df/length(allData$Cancelled)*100
  names(time3.df)[1] <- "time"
  
  timeMin <- strptime("00:00", format="%H")
  timeMax <- strptime("23:00", format="%H")
  allTime  <- strftime(seq(timeMin,timeMax,by="hour"), "%H")
  
  allTime.df <- data.frame(list(time=allTime))
  
  Times <- merge(allTime.df,time1.df, all=T)
  Times <- merge(Times,time2.df, all=T)
  Times <- merge(Times,time3.df, all=T)
  Times$collections[which(is.na(Times$collections))] <- 0
  Times$deliveries[which(is.na(Times$deliveries))] <- 0
  Times$created[which(is.na(Times$created))] <- 0
  Times$time <- strftime(strptime(Times$time, format="%H"), "%H:%M")
  
  gvisLineChart(Times, options=list(
    title='Deliveries, collections and bookings created by hour slot', height=400, vAxis="{title:'no of bookings'}",
    hAxis="{title:'hour slot'}"))
  
})


#NATIONALITIES TABLE (TAB 2: STATISTICS)

output$nation  <- renderDataTable({
  if (is.null(ready())) return(NULL)
  
  allData <- bookingsRange()
  
  nat.df <- ddply (allData, "country_origin", summarize, bookings = length(Cancelled), totalBags = sum(Total_luggage_No), meanBags = round(mean(Total_luggage_No),digits=1), netRevenue = round(sum(Transaction_payment)/1.2))
  nat.df$avgRevenue <- round(nat.df$netRevenue/nat.df$bookings, digits=2)
  nat.df <- nat.df[with(nat.df,order(-bookings,-avgRevenue)), ]
  rownames(nat.df) <- NULL
  
  nat.df
}, options = list(pageLength = 5))

#REPEAT CUSTOMERS TABLE (TAB 2: STATISTICS)
reUser <- reactive({
  allData <- bookingsRange()
  #   if(grep("bagstorage@portr.com",allData$customer_email)){
  #     allData <- allData[- grep("bagstorage@portr.com",allData$customer_email), ]
  #   }
  
  reUser.df <- ddply (allData, "customer_email", summarize, bookings = length(Cancelled), totalBags = sum(Total_luggage_No), meanBags = round(mean(Total_luggage_No),digits=1), netRevenue = round(sum(Transaction_payment)/1.2))
  reUser.df$avgRevenue <- round(reUser.df$netRevenue/reUser.df$bookings, digits=2)
  reUser.df <- reUser.df[with(reUser.df,order(-bookings,-avgRevenue)), ]
  reUser.df <- reUser.df[reUser.df$bookings>1,]
  rownames(reUser.df) <- NULL
  
  reUser.df
  
})

output$reUser  <- renderText({
  if (is.null(ready())) return(NULL)
  
  allData <- bookingsRange()
  
  reUser.df <- reUser()
  
  reUser <- length(reUser.df$bookings)
  reUserpct <- round(reUser/length(allData$Cancelled),digits=3)*100
  paste("Repeat Users: ", reUser, "total, so about ",reUserpct,"%")
  
})

output$custom <- renderDataTable({
  if (is.null(ready())) return(NULL)
  
  reUser()
  
}, options = list(pageLength = 5))

#TABLE MAIN DELIVERY DESTINATIONS

output$loc <- renderDataTable({
  if (is.null(ready())) return(NULL)
  
  allData <- bookingsRange()
  
  loc.df <- ddply (allData, "Outward_Journey_Luggage_drop_off_location_Name", summarize, bookings = length(Cancelled), totalBags = sum(Total_luggage_No), meanBags = round(mean(Total_luggage_No),digits=1), netRevenue = round(sum(Transaction_payment)/1.2))
  loc.df$avgRevenue <- round(loc.df$netRevenue/loc.df$bookings, digits=2)
  loc.df <- loc.df[with(loc.df,order(-bookings,-avgRevenue)), ]
  #loc.df <- loc.df[loc.df$bookings>1,]
  loc.df <- loc.df[loc.df$netRevenue>0,]
  #loc.df <- loc.df[- grep("Residential",loc.df$Outward_Journey_Luggage_drop_off_location_Name), ]
  #loc.df <- loc.df[- grep("Airportr",loc.df$Outward_Journey_Luggage_drop_off_location_Name), ]
  rownames(loc.df) <- NULL
  
  loc.df
  
}, options = list(pageLength = 10))

#Inbound Flights data table
output$inFlights <- renderDataTable({
  if (is.null(ready())) return(NULL)
  
  bookings <- bookingsRange()
  
  df <- ddply (bookings, "In.bound_flt_code", summarize, bookings = length(Cancelled), totalBags = sum(Total_luggage_No), meanBags = round(mean(Total_luggage_No),digits=1), netRevenue = round(sum(Booking_value_gross_total)/1.2))
  df <- df[with(df, order(bookings, decreasing=T)),]
  
}, options = list(pageLength = 10))

#Inbound Flights data table
output$outFlights <- renderDataTable({
  if (is.null(ready())) return(NULL)
  
  bookings <- bookingsRange()
  
  df <- ddply (bookings, "Out.bound_flt_code", summarize, bookings = length(Cancelled), totalBags = sum(Total_luggage_No), meanBags = round(mean(Total_luggage_No),digits=1), netRevenue = round(sum(Booking_value_gross_total)/1.2))
  df <- df[with(df, order(bookings, decreasing=T)),]
  
}, options = list(pageLength = 10))

########TAB3##################################################


#TABLE CC&D BOOKINGS
output$CCnD <- renderDataTable({
  if (is.null(ready())) return(NULL)
  
  bookings <- Carousel()
  
  CC <- bookings[, c("Booking_reference", "Hand_luggage_No","Hold_luggage_No",
                     "Total_luggage_No","Customer_Firstname","customer_surname","country_origin", 
                     "Outward_Journey_Luggage_Collection_date", "Transaction_payment","In.bound_flt_code","Origin")]
  rownames(CC) <- NULL
  names(CC) <- c("Booking","Hand","Hold","Total","Name","Surname","Nat","Date","Value","Flight","Origin")
  
  CC
})
#Download Button
output$downloadCCnD <- downloadHandler(
  filename = function() { paste("CCnD",range()[1]," to ",range()[2], '.csv', sep='') },
  content = function(file) {
    write.csv(CarouselShort(), file)
  }
)