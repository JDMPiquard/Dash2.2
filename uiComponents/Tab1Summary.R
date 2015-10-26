#  JD for Portr, June 2015
#  TAB 1 UI: High Level Detail 
#

div(

  fluidRow(
      div(style='margin=5px',
        p(' ')
      )
    ),

  fluidRow(
    div(style='margin=5px',
      p(' ')
    )
  ),

  # DAY PLOT
  # # EXPERIMENTAL options
  # fluidRow(
  #   column(4,
  #     selectInput("graphTimeSelect", label = "Select how to display graph", 
  #       choices = list("day", "week"), 
  #       selected = "day")
  #   )
  # ),

  # Actual Plot
  fluidRow(
    div(style="text-align:center; margin-top:21px",
      htmlOutput("dayPlot")
    )
  ),
  
  # WEEKLY TABLE
  fluidRow(
    div(dataTableOutput(outputId="contents"), style="padding:0px; margin-top:20px")
  ),
  
  # MAP
  fluidRow(
    hr(),
    div(style="margin:0 auto",
        chartOutput('mapContainer','leaflet')
    )
  ),
  # Map instructions
  fluidRow(
    div(class="sideBox", style="text-align: left",
      p(strong("Delivery Locations Map: "), "click on individual markers to obtain additional information"),
      p("click on the button below to show map of delivery locations"),
      
      checkboxInput("showMap", label = h6("Show Map"), value = T) #show map button
    )
  )
)