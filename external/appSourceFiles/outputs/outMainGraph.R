# JD for Portr LTD, June 2015
# Describes graph outputs for the main top Summary Box
#

# Output as a combo chart
output$MAIN <- renderGvis({
  if (is.null(ready())) return(NULL)
  
  df <- sumCum()

  Combo <- gvisComboChart(df, xvar="rank",
    yvar=c("netRevenue", "cum"),
      #options=list(seriesType="bars",series='{1: {type:"line"}}')
    options=list(
      height=300,
      series="[{
        type:'bars',
        isStacked: 'true',
        targetAxisIndex:0
        },{
        type:'line',
        targetAxisIndex:1
        }]",
      vAxes="[{title:'GBP/month'},
        {title:'GBP/cumulative'}]",
      title= "bookings net revenue month by month"
    )
  )
})

# Output as a stacked bar chart
# output$MAIN <- renderGvis({
#   if (is.null(ready())) return(NULL)

#   df <- summarizeMI(all(), c("month", "year", "airport"))
#   sumBooking$rank  <- as.Date(paste0(sumBookings$year,'-',sumBookings$month,'-01'),"%Y-%m-%d")

#   Combo <- gvisColumnChart(df, xvar="rank",
#     yvar=c("netRevenue", "cum"),
#       #options=list(seriesType="bars",series='{1: {type:"line"}}')
#     options=list(
#       height=300,
#       series="[{
#         type:'bars',
#         isStacked: 'true',
#         targetAxisIndex:0
#         },{
#         type:'line',
#         targetAxisIndex:1
#         }]",
#       vAxes="[{title:'GBP/month'},
#         {title:'GBP/cumulative'}]",
#       title= "bookings net revenue month by month"
#     )
#   )
# })