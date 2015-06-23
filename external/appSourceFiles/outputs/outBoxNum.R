# JD for Portr LTD, June 2015
# Boxed Number Outputs
#

#bookings
output$W  <- renderText({
  if(is.null(ready())) return(NULL)
  
  df <- sumDate()
  sum(df$bookings)
})
#bags
output$X  <- renderText({
  if(is.null(ready())) return(NULL)
  
  df <- sumDate()
  sum(df$totalBags)
})
#net revenue
output$Y  <- renderText({
  if(is.null(ready())) return(NULL)
  
  df <- sumDate()
  paste(round(sum(df$netRevenue*1.2)),"GBP")
})
#avg bags
output$mX  <- renderText({
  if(is.null(ready())) return(NULL)
  
  df <- sumDate()
  round(sum(df$totalBags)/sum(df$bookings), digits = 1)
})
#net revenue per booking
output$mY  <- renderText({
  if(is.null(ready())) return(NULL)
  
  df <- sumDate()
  paste(round(sum(df$netRevenue)/sum(df$bookings)*1.2, digits = 2),"GBP")
})
#ne
output$preBook <- renderText({
  if(is.null(ready())) return(NULL)
  
  df <- bookingsRange()
  preBook <- round(sum(grepl("prebook",df$Department))/length(df$Department), digits=2)*100
  paste(preBook,"%")
})

#Return Journeys
output$txtRtn <- renderText({
  if(is.null(ready())) return(NULL)
  
  allData <- bookingsRange()
  
  tit <- ddply (allData, "Single_return", summarize, count = length(Cancelled))
  tit$Single_return  <- as.character(tit$Single_return)
  paste(tit[2,2])
})

#Carousel Collections
output$txtCCnD <- renderText({
  if(is.null(ready())) return(NULL)
  
  df <- Carousel()
  paste(length(df$Booking_reference))
})