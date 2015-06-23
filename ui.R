#  JD for Portr, June 2015
#  Shiny UI page for Internal Dashboard
#  

require(shiny)
require(rCharts)
require(plyr)
require(lubridate)
require(ggmap)
require(ggplot2)
require(googleVis)

shinyUI(fluidPage(
  
  tags$head(
  	# set tab title
    HTML("<title>Portr Operations Dash</title>"),
    # add custom CSS
    tags$link(rel="stylesheet", type="text/css", href="stylePortr.css")
  ),
  
  div(class="mainBody", 
      
      # INPUTS BOX
      source("uiComponents/inputsBox.R",local=T)$value,
      
      # MAIN TOP CHARTS
      source("uiComponents/mainGraphBox.R",local=T)$value,

      # SUMMARY OUTPUT
      

      fluidRow(
        column(9,
               h4(textOutput("sumStats")))
      ),
      
      div(style="margin:0 auto, text-align:center",
          fluidRow(
            
            column(2,
                   div(h2(textOutput("W")),
                       p("bookings"),
                       class = "box")
            ),
            
            column(2,
                   div(h2(textOutput("X")),
                       p("bags"),
                       class = "box")
            ),
            
            column(4,
                   div(h2(textOutput("Y")),
                       p("gross revenue (inc. VAT)"),
                       class = "box")
            )
          ),
          
          fluidRow(div(style='margin=5px',
                       p(' '))),
          
          fluidRow(
            
            column(2,
                   div(h4(textOutput("mX")), p("avg bags per booking"),
                       class = "minibox")
            ),
            
            column(2,
                   div(h4(textOutput("mY")), p("avg booking value"),
                       class = "minibox")
            ),
            
            column(2,
                   div(h4(textOutput("preBook")),
                       p("pre-bookings"),
                       class = "minibox")
            ),
            
            column(2,
                   div(h4(textOutput("txtRtn")),
                       p("Return Journeys"),
                       class = "minibox")
            ),
            
            column(2,
                   div(h4(textOutput("txtCCnD")),
                       p("Carousel Collections"),
                       class = "minibox")
            ),
            
            column(2,
                   div(h4(0),
                       p("Swift Check-Ins"),
                       class = "minibox")
            )
            
          )),
      
      ##LINE BREAK INTO SELECTED PERIOD DATA
      fluidRow(
        p(" ")
      ),
      
      ##TABS!!!
      tabsetPanel(id='main',
                  
                  ##TAB 1: Detailed view
                  tabPanel('Detail',    
                           
                           ##DAY PLOT
                           fluidRow(
                             div(style="text-align:center; margin-top:21px",
                                 htmlOutput("dayPlot")
                             )
                           ),
                           
                           #       ##TEXT SUMMARY AREA
                           
                           
                           ##TABLE
                           fluidRow(
                             div(dataTableOutput(outputId="contents"), style="padding:0px; margin-top:20px")
                           ),
                           
                           ##MAP
                           fluidRow(
                             hr(),
                             div(style="margin:0 auto",
                                 chartOutput('mapContainer','leaflet')
                             )
                           ),
                           
                           fluidRow(
                             div(class="sideBox", style="text-align: left",
                                 p(strong("Delivery Locations Map: "), "click on individual markers to obtain additional information"),
                                 p("click on the button below to show map of delivery locations"),
                                 #show map button
                                 checkboxInput("showMap", label = h6("Show Map"), value = T)
                             )
                           )
                  ),#closing tab panel 1
                  
                  tabPanel('General Statistics',
                           
                           div(class="statsContainer",
                               fluidRow(
                                 h4("Core Usage Statistics")
                               ),
                               fluidRow(
                                 
                                 column(4,
                                        htmlOutput("sex")),
                                 
                                 column(4,
                                        htmlOutput("luggage")),
                                 
                                 column(4,
                                        htmlOutput("journey"))
                                 
                               ),
                               
                               ##Smaller
                               fluidRow(
                                 column(4,
                                        htmlOutput("type")
                                 ),
                                 
                                 column(4,
                                        htmlOutput("DAY")
                                 ),
                                 column(4,
                                        htmlOutput("ZONE")
                                 )
                               )
                           ), #close Div
                           
                           #HOUR PLOT
                           div(class = "statsContainer",
                               fluidRow(
                                 h4("Aggregated performance by hour of day")),
                               fluidRow(
                                 htmlOutput("hourPlot")
                               )
                           ),
                           
                           #Nationalities
                           fluidRow(p(" ")),
                           fluidRow(
                             h4("Main user Nationalities"),
                             div(class="statsContainer",
                                 dataTableOutput(outputId="nation"), style="padding:0px; margin-top:20px; margin-bottom:30px; border-bottom: solid #f6f6f6")
                           ),
                           
                           #Repeat users
                           fluidRow(
                             h4(textOutput("reUser")),
                             div(class="statsContainer",
                                 dataTableOutput(outputId="custom"), style="padding:0px; margin-top:20px")
                           ),
                           
                           #Main destinations
                           fluidRow(p(" ")),
                           fluidRow(
                             h4("Repeat destinations"),
                             div(class="statsContainer",
                                 dataTableOutput(outputId="loc"), style="padding:0px; margin-top:20px")
                           ),
                           
                           #Inbound Flights
                           fluidRow(p(" ")),
                           fluidRow(
                             h4("Popular Inbound Flights"),
                             div(class="statsContainer",
                                 dataTableOutput(outputId="inFlights"), style="padding:0px; margin-top:20px")),
                           
                           #Outbound Flights
                           fluidRow(p(" ")),
                           fluidRow(
                             h4("Popular Outbound Flights"),
                             div(class="statsContainer",
                                 dataTableOutput(outputId="outFlights"), style="padding:0px; margin-top:20px"))
                           
                  ),#closing tab panel 2
                  
                  tabPanel('Product Statistics',
                           div(class="statsContainer",
                               fluidRow(
                                 column(8,
                                        h4("BA Carousel Collections")),
                                 column(4,
                                        downloadButton('downloadCCnD', 'Download extended version'))
                               ),
                               fluidRow(
                                 column(4,
                                        htmlOutput("CC1")
                                 ),
                                 
                                 column(4,
                                        htmlOutput("CC2")
                                 ),
                                 column(4,
                                        htmlOutput("CC3")
                                 )),
                               fluidRow(
                                 dataTableOutput(outputId="CCnD"), style="padding:0px; margin-top:20px"))
                  )#closing Product Tab
                  
      )#closing tabs altogether
  )
))