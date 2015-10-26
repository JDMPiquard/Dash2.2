# JD for Portr LTD, June 2015
# Boxed Number Outputs
#

# bookings
output$W  <- renderText({
  KPI()$bookings
})
# bags
output$X  <- renderText({
  KPI()$bags
})
# Gross revenue
output$grossRev  <- renderText({
  toCurrency(KPI()$grossRevenue, round=0)
})
# Net revenue
output$netRev <- renderText({
  toCurrency(KPI()$netRevenue, compact=F)
})
# Total Poptential Booking Value
output$bookValue <- renderText({
  toCurrency(KPI()$potentialBookValue)
})
# Other Discounts
output$bookDiscounts <- renderText({
  toCurrency(KPI()$otherDiscounts)
})
# Promo Discounts
output$bookPromos <- renderText({
  toCurrency(KPI()$promoDiscounts)
})
# avg bags
output$avgBags  <- renderText({
  KPI()$avgBags
})
# gross revenue per booking
output$avgGrossBookingRev  <- renderText({
  toCurrency(KPI()$netRevBooking*1.2, round=1)
})
# Pre-bookings
output$preBook <- renderText({
  toPct(KPI()$preBook)
})
# Pre-booking Lead Time
output$preBookLeadTime <- renderText({
  paste(round(KPI()$preBookLeadTime, digits=2),"days")
})
# Central London Collections
output$journeyDirection <- renderText({
  toPct(KPI()$directionToApt)
})
# Return Journeys
output$txtRtn <- renderText({
  toPct(KPI()$reUserPct)
})
# Carousel Collections
output$txtCCnD <- renderText({
  paste(KPI()$ccndBookings)
})
# Pre Booking Time, excluding Airport and office IP addresses
output$completeBookTime <- renderText({
  paste(KPI()$completeBookTime,"mins")
})
# HTML Report output - financial summary of transactions
output$copyPasteReport <- renderUI({
  list(
    p("Summary tansactions for ", strong(paste(filter(), collapse=" + ")),
      " between ",strong(range()[1])," and ",strong(range()[2]),":"),
    p("Transactions: ", KPI()$bookings),
    p("Gross Revenue:", strong(toCurrency(KPI()$grossRev))),
    p("Net Revenue (excl. VAT):", toCurrency(KPI()$netRevenue))
  )  
})
