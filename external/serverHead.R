#  JD for Portr Ltd, June 2015
#  Header file for dashboard
#  intended for use with server.R file for Internal Dashboard 2.2

require(shiny)
require(rCharts)
require(plyr)
require(lubridate)
require(ggmap)
require(ggplot2)
require(googleVis)

#  can also be used to store global variables, insert them below

ipExclude <- c(
  '',
  '213.123.58.114',
  '80.87.25.183',
  '81.144.134.68')
