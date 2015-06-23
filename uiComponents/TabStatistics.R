# JD for Portr LTD, June 2015
# UI and Graph output for Statistics tab
# 

div(
  # PIE CHARTS
  div(class="statsContainer",
    fluidRow(
      h4("Core Usage Statistics")  # Title
    ),
    # Top row
    fluidRow(
      column(4,
        htmlOutput("sex")  # Sex
      ),
      column(4,
        htmlOutput("luggage")  # Luggage type
      ),
      column(4,
        htmlOutput("journey")  # Single or Return
      )
    ),
    
    # Bottom row
    fluidRow(
      column(4,
        htmlOutput("type")  # Delivery type (Airport, Hotel or Business)
      ),
      column(4,
        htmlOutput("DAY")
      ),
      column(4,
        htmlOutput("ZONE")
      )
    )
  ), #close Div

  # PLOT: AVERAGE PERFORMANCE BY HOUR OF DAY
  div(class = "statsContainer",
    fluidRow(
      h4("Aggregated performance by hour of day")),
    fluidRow(
      htmlOutput("hourPlot")
    )
  ),
  
  fluidRow(p(" ")),
  
  # TABLE: Nationalities
  fluidRow(
    h4("Main user Nationalities"),
    div(class="statsContainer",
      dataTableOutput(outputId="nation")
    )
  ),

  # TABLE: Repeat users
  fluidRow(
    h4(textOutput("reUser")),
    div(class="statsContainer",
      dataTableOutput(outputId="custom")
    )
  ),
  
  fluidRow(p(" ")),
  
  #TABLE: Main destinations
  fluidRow(
    h4("Repeat destinations"),
    div(class="statsContainer",
      dataTableOutput(outputId="loc")
    )
  ),

  fluidRow(p(" ")),
  
  #TABLE: Inbound Flights
  fluidRow(
    h4("Popular Inbound Flights"),
    div(class="statsContainer",
      dataTableOutput(outputId="inFlights")
    )
  ),

  fluidRow(p(" ")),
  
  #TABLE: Outbound Flights
  fluidRow(
    h4("Popular Outbound Flights"),
    div(class="statsContainer",
      dataTableOutput(outputId="outFlights")
    )
  )
)