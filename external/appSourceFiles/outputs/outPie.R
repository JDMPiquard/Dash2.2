# JD for Portr LTD
# Pie Chart outputs
#

#pie chart dimensions
WI <- 300 #set width
HI <- 300 #set height

#Sex
output$sex <- renderGvis({
  if (is.null(ready())) return(NULL)
  
  allData <- bookingsRange()
  
  tit <- ddply (allData, "Title", summarize, count = length(Cancelled))
  tit$Title  <- as.character(tit$Title)
  
  doughnut <- gvisPieChart(tit, 
                           options=list(
                             width=WI,
                             height=HI,
                             title='Sex (using title)',
                             legend='none',
                             pieSliceText='label',
                             pieHole=0.5),
                           chartid="doughnutSex")
  return(doughnut)
})

#Luggage Type
output$luggage <- renderGvis({
  if (is.null(ready())) return(NULL)
  
  allData <- bookingsRange()
  
  lug <- as.data.frame(matrix(ncol=2,nrow=2))
  lug[1,1] <- "Hand" 
  lug[1,2]  <- sum(allData$Hand_luggage_No)
  lug[2,1] <- "Hold"
  lug[2,2]  <- sum(allData$Hold_luggage_No)
  
  #inserting % into field name
  temp <- lug
  temp[,2] <- round(lug[,2]/sum(lug[,2]), digits = 2)*100
  temp[,1] <- paste(lug[,1], ': ',temp[,2],'%', sep='')
  lug[,1] <- temp[,1]
  
  doughnut <- gvisPieChart(lug, 
                           options=list(
                             width=WI,
                             height=HI,
                             title='Luggage type',
                             legend='none',
                             pieSliceText='label',
                             pieHole=0.5),
                           chartid="doughnutLug")
  return(doughnut)
})

#Journey Type
output$journey <- renderGvis({
  if (is.null(ready())) return(NULL)
  
  allData <- bookingsRange()
  
  tit <- ddply (allData, "Single_return", summarize, count = length(Cancelled))
  tit$Single_return  <- as.character(tit$Single_return)
  
  #inserting % into field name
  temp <- tit
  temp[,2] <- round(tit[,2]/sum(tit[,2]), digits = 2)*100
  temp[,1] <- paste(tit[,1], ': ',temp[,2],'%', sep='')
  tit[,1] <- temp[,1]
  
  doughnut <- gvisPieChart(tit, 
                           options=list(
                             width=WI,
                             height=HI,
                             title='Journey type',
                             legend='none',
                             pieSliceText='label',
                             pieHole=0.5),
                           chartid="doughnutJourney")
  return(doughnut)
})

#Delivery Type
output$type <- renderGvis({
  if (is.null(ready())) return(NULL)
  
  allData <- bookingsRange()
  
  #NOTE: REVISIT THIS AS IT IS CURRENTLY NOT CORRECT
  
  lug <- as.data.frame(matrix(ncol=2,nrow=3))
  lug[1,1] <- "Home" 
  lug[1,2]  <- sum(allData$Outward_Journey_Luggage_drop_off_location_Type=="Residential")
  lug[2,1] <- "Hotel"
  lug[2,2]  <- sum(allData$Outward_Journey_Luggage_drop_off_location_Type=="Hotel")
  lug[3,1] <- "Biz"
  lug[3,2] <- sum(allData$Outward_Journey_Luggage_drop_off_location_Type=="Business")
  lug[4,1] <- "Apt"
  lug[4,2] <- sum(allData$Outward_Journey_Luggage_drop_off_location_Type=="AirportTerminal")
  
  #inserting % into field name
  temp <- lug
  temp[,2] <- round(lug[,2]/sum(lug[,2]), digits = 2)*100
  temp[,1] <- paste(lug[,1], ':',temp[,2],'%', sep='')
  lug[,1] <- temp[,1]
  
  doughnut <- gvisPieChart(lug, 
                           options=list(
                             width=WI,
                             height=HI,
                             title='Deliveries by type (Airport is faulty)',
                             legend='none',
                             pieSliceText='label',
                             pieHole=0.3),
                           chartid="doughnutType")
  return(doughnut)
})

output$ZONE <- renderGvis({
  if (is.null(ready())) return(NULL)
  
  allData <- bookingsRange()
  
  dat <- ddply (allData, "Zone", summarize, count = length(Cancelled))
  dat$Zone  <- as.character(dat$Zone)
  
  dat2 <- dat
  dat2$count <- round(dat$count/sum(dat$count), digits = 2)*100
  dat2$Zone <- paste(dat$Zone, ': ',dat2$count,'%', sep='')
  dat$Zone <- dat2$Zone
  
  doughnut <- gvisPieChart(dat, 
                           options=list(
                             width=WI,
                             height=HI,
                             title='Zone Breakdown',
                             legend='none',
                             pieSliceText='label',
                             pieHole=0.5),
                           chartid="doughnut")
  return(doughnut)
})

output$DAY <- renderGvis({
  if (is.null(ready())) return(NULL)
  
  allData <- bookingsRange()
  
  dat <- ddply (allData, "day", summarize, count = length(Cancelled))
  #dat <- dat[order(as.Date(dat$day, format="%d"),]
  dat$day <- substring((as.character(dat$day)),1,3) 
  
  #inserting pct into name fields
  dat2 <- dat
  dat2$count <- round(dat$count/sum(dat$count), digits = 2)*100
  dat2$day <- paste(dat$day, ': ',dat2$count,'%', sep='')
  dat$day <- dat2$day
  
  doughnut <- gvisPieChart(dat, 
                           options=list(
                             width=WI,
                             height=HI,
                             title='Day Breakdown',
                             legend='none',
                             pieSliceText='label',
                             pieHole=0.35),
                           chartid="doughnut2")
  
})