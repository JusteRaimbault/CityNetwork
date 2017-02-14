

shinyUI(
  navbarPage("RBD", id="nav",
                   
       tabPanel("Synthetic Exploration",
          selectInput("wdensity", "wdensity", unique(dd$wdensity)),
          selectInput("wcenter", "wcenter", unique(dd$wcenter)),
          selectInput("wroad", "wroad", unique(dd$wroad)),
          
          plotOutput("laggedCorr", height = 300,width=500)
       )
  )
)