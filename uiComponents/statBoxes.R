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
          div(h2(textOutput("netRev")),
          p("net revenue (excl. VAT)"),
          class = "box")
      ),

      column(2,
        div(
          h2(textOutput("avgBags")),
          p("bags/booking"),
          class = "box")
      ),
      
      column(2,
          div(h2(textOutput("avgGrossBookingRev")),
          p("gross rev/Bkg"),
          class = "box")
      )
    ),
    
    # fluidRow(
    #   div(style='margin=5px',
    #     p(' ')
    #   )
    # ),
    
    # # SECONDARY FINANCIAL BOXES
    # fluidRow(
    #   column(3,
    #     div(
    #       h4(textOutput("bookValue")),
    #       p("total gross value of bookings"),
    #       class = "minibox")
    #   ),
      
    #   column(3,
    #     div(
    #       h4(textOutput("bookPromos")),
    #       p("promo discounts"),
    #       class = "minibox")
    #   ),
      
    #   column(3,
    #     div(
    #       h4(textOutput("bookDiscounts")),
    #       p("other price adjustments"),
    #       class = "minibox")
    #   ),

    #   column(3,
    #     div(
    #       h4(textOutput("grossRev")),
    #       p("gross revenue (inc. VAT)"),
    #       class = "minibox")
    #   )
        
    # ),

    fluidRow(
      div(style='margin=5px',
        p(' ')
      )
    ),
    
    # TERTIARY BOXES
    fluidRow(
      column(2,
        div(
          h4(textOutput("preBook")),
          p("pre-bookings"),
          class = "minibox")
      ),

      column(2,
        div(
          h4(textOutput("preBookLeadTime")),
          p("avg lead time for pre-bookings"),
          class = "minibox")
      ),
      
      column(2,
        div(
          h4(textOutput("journeyDirection")),
          p("journeys from Location to Airport"),
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
      
      # Careful, the following is still being tested
      column(2,
        div(
          h4(textOutput("completeBookTime")),
          p("Median Online Booking Time"),
          class = "minibox")
      )
        
    )
  )
)