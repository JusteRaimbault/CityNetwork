
library(shiny)
library(dplyr)
library(ggplot2)


shinyServer(function(input, output, session) {
  
  observe({
    output$laggedCorr <- renderPlot({
      g=ggplot(dd[dd$wdensity==input$wdensity&dd$wroad==input$wroad&dd$wcenter==input$wcenter,],aes(x=tau,y=corr,colour=vars))
      g+geom_point(size=0.2)+stat_smooth(method="loess",span=0.1)
    })
  })
  
})

