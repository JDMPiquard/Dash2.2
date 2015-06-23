# JD for Portr LTD, June 2015
# Describes graph outputs for the main top Summary Box
#

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