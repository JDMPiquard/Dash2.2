# JD for Portr LTD, June 2015
# Describes graph outputs for the main top Summary Box
#

# # Output as a combo chart
# output$MAIN <- renderGvis({
#   if (is.null(ready())) return(NULL)
  
#   df <- sumCum()

#   Combo <- gvisComboChart(df, xvar="rank",
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
#       # title= "bookings net revenue month by month",
#       legend= "none"
#     )
#   )
# })

# Output as a stacked bar chart
output$MAIN <- renderGvis({
  if (is.null(ready())) return(NULL)

  df <- all()
  df$Airport <- gsub("^.*Heathrow.*$","LHR",df$Airport)
  df$Airport <- gsub("^.*Gatwick.*$","LGW",df$Airport)
  df$Airport <- gsub("^.*City.*$","LCY", df$Airport)

  df2 <- summarizeMI(df, c("month", "year", "Airport"))
  df2$rank  <- as.Date(paste0(df2$year,'-',df2$month,'-01'),"%Y-%m-%d")
  df2 <- df2[order(df2$rank),]

  df3 <- data.frame(df2$rank,df2$Airport,df2$netRevenue)
  airportRank  <- reshape(df3,idvar='df2.rank',timevar='df2.Airport',direction='wide')
  airportRank[is.na(airportRank)] <- 0

  names <- colnames(airportRank)
  names <- gsub("df2.","",names)
  names <- gsub("netRevenue.","",names)

  colnames(airportRank) <- names

  Combo <- gvisColumnChart(airportRank, 
    # xvar="rank",
    # yvar=c("netRevenue", "cum"),
    options=list(
      height=300,
      isStacked='true',
      legend= 'top',
      vAxis="{title:'GBP/month'}"
      # ,
      # title= "bookings net revenue month by month (colours show main airport assign to booking)"
    )
  )
})

output$yearCum <- renderGvis({
  if (is.null(ready())) return(NULL)
  
  df <- all()
  df2 <- summarizeMI(df, c("month", "year"))
  df2$rank  <- as.Date(paste0(df2$year,'-',df2$month,'-01'),"%Y-%m-%d")
  df2 <- df2[order(df2$month),]

  df3 <- data.frame(df2$month,df2$year,df2$netRevenue)
  cumRank  <- reshape(df3,idvar='df2.month',timevar='df2.year',direction='wide')
  cumRank[is.na(cumRank)] <- 0

  names <- colnames(cumRank)
  for(i in 2:length(names)){
    cumRank[i]  <- lapply(cumRank[i],cumsum)
  }

  names <- colnames(cumRank)
  names <- gsub("df2.","",names)
  names <- gsub("netRevenue.","",names)

  colnames(cumRank) <- names

  #  df <- sumCum()

  charty <- gvisLineChart(cumRank, 
    # xvar="rank",
    # yvar=c("cum"),
    options=list(
      # title= "cummulative revenue",
      height=300,
      legend = 'top',
      vAxis="{title:'cummulative net Revenue (GBP)'}"
    )
  )

})