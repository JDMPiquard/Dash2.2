#  JD for Portr Ltd, June 2015
#  Header file for dashboard
#  intended for use with server.R file for Internal Dashboard 2.2

require(shiny)
require(rCharts)
require(plyr)
#  May need to remove tidyr if it masks other functions
#require(tidyr)
require(lubridate)
require(ggmap)
require(ggplot2)
require(googleVis)
require(httr)


#  can also be used to store global variables, insert them below

# Expressions to exclude in "excludeInternal"
internalAddresses <- c(
  "Portr HQ", 
  "Portr Limited",
  "Portr Ltd")

# Original Start Dates - only LCY currently in use
startDate <- list(
  LCY = "2014-05-22",
  LGW = "2015-07-23",
  LHR = "2015-10-26")

# IPs to exclude
ipExclude <- c(
  '',
  '213.123.58.114',
  '80.87.25.183',
  '81.144.134.68')

# e-mails to exclude, note that the regex should automatically exclude all airportr e-mails
eMailExclude <- c(
  'gwest@portr.com',
  'slewis@portr.com',
  'bagstorage@portr.com',
  'fabiodiola@gmail.com',
  'acarey@portr.com',
  'dpayne@portr.com',
  'dsmith@portr.com',
  'rdarby@portr.com',
  'cwalsh@portr.com',
  'jprior@portr.com',
  'mclalor@portr.com',
  'selina-lewis@hotmail.co.uk',
  '^.*portr.com'
)

# GAL defined properties (EPOS download only)
  retailer <- "*AP*"
  shopCode <- "*ShopCode*"
  shopText <- "*Shop Text*"
  # the following will be product dependent
  catCode <- "*catCode*"
  catText <- "*catText*"
  subCatCode <- "*subCatCode*"
  subCatText <- "*subCatText*"

# Defining the most popular header names as global variables
  # Intention is to easily enable to perform MI export changes to field names
  