#  JD for Portr, June 2015
#  UI for summary statistics boxes
# 

div(
  fluidRow(
    column(9,
      h4(textOutput("sumStats")))
  ),
  
  # MAIN BOXES
  div(style="margin:0 auto, text-align:center",
    fluidRow(
      column(2,
        div(
          h2(textOutput("W")),
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
    
    fluidRow(
      div(style='margin=5px',
        p(' ')
      )
    ),
    
    # SECONDARY BOXES
    fluidRow(
      column(2,
        div(
          h4(textOutput("mX")),
          p("avg bags per booking"),
          class = "minibox")
      ),
      
      column(2,
        div(
          h4(textOutput("mY")),
          p("avg booking value"),
          class = "minibox")
      ),
      
      column(2,
        div(
          h4(textOutput("preBook")),
          p("pre-bookings"),
          class = "minibox")
      ),
      
      column(2,
        div(
          h4(textOutput("txtRtn")),
          p("Return Journeys"),
          class = "minibox")
      ),
      
      column(2,
        div(
          h4(textOutput("txtCCnD")),
          p("Carousel Collections"),
          class = "minibox")
      ),
      
      # Careful, the following is hard coded
      column(2,
        div(
          h4('Not Yet'),
          p("Swift Check-Ins"),
          class = "minibox")
      )
        
    )
  )
)