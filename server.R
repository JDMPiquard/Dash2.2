# JD for Portr LTD, June 2015
# Server Page


#  HEADER FILE
source('external/serverHead.R', local=T)

#  MAIN FILE IS app.R
shinyServer(function(input,output, clientData, session){
  source('external/app.R', local = T)
  })