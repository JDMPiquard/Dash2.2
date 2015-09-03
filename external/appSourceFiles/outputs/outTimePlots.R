# JD for Portr LTD
# outpts for continuous time graphs (e.g. day by day or hour by hour)
#

# PLOT: PERFORMANCE BY DATE
output$dayPlot <- renderGvis({
  if (is.null(ready())) return(NULL)
  
  df <- contDate()
  
  Combo <- gvisComboChart(df, 
    xvar="date"
      # ifelse(input$graphTimeSelect=="day","date",
      #   ifelse(input$graphTimeSelect=="week", "weekStart",NULL))
      ,
    yvar=c("netRevenue", "bookings"),
    #options=list(seriesType="bars",series='{1: {type:"line"}}')
    options=list(
      series="[{
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

# PLOT: HOUR BY HOUR AVERAGE DELIVERY AND COLLECTIONS
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