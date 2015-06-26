# JD for Portr LTD, June 2015
# List storing all KPI information
#

# KPI always shows the data as reflected 
KPI <- reactive({
  if(is.null(ready())) return(list(NULL))
  
  df  <- sumDate()
  df2 <- bookingsRange()
  
  # booking totals
  bookings <- sum(df$bookings)
  # 
  bags <- sum(df$totalBags)
  netRevenue <- sum(df$netRevenue)
  grossRevenue <- netRevenue*1.2
  avgBags <- round(sum(df$totalBags)/sum(df$bookings), digits = 1)
  netRevBooking <- sum(df$netRevenue)/sum(df$bookings)
  
  preBook <- sum(grepl("prebook",df2$Department))/length(df2$Department)
  
  rtn <- ddply (df2, "Single_return", summarize, count = length(Cancelled))
  rtn$Single_return  <- as.character(rtn$Single_return)
  returnBookings <- paste(rtn[2,2])
  
  ccndBookings <- length(Carousel()$Booking_reference)
  
  # AVG BOOKING TIME
  IP.df <- IPs()[!(IPs()$ip_address %in% ipExclude),]  # exclude certain IPs
  preBookTime  <- median(IP.df$BookingTime, na.rm = T)

  
  return(
    list(
      bookings=bookings,
      bags=bags,
      netRevenue=netRevenue,
      grossRevenue=grossRevenue,
      avgBags=avgBags,
      netRevBooking=netRevBooking,
      preBook=preBook,
      returnBookings=returnBookings,
      ccndBookings=ccndBookings,
      preBookTime=preBookTime))
})