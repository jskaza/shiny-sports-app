# server.R

library(hexbin)
library(ggplot2)
library(corrplot)

# load and process hr_data 
hr_data_itp = read.csv("data/hr_data_2015.csv") # all hrs, inlcuding itp
hr_data = hr_data_itp[ which(hr_data_itp$class != "ITP/L"), ] # df w/o itp
hr_data_itp$class = NULL # don't need to display this variable, just used for identifying itp
hr_data$class = NULL # don't need to display this variable, just used for identifying itp
# data processing for corrplot
hr = hr_data_itp
hr$hitter = NULL
hr$pitcher = NULL
hr$class = NULL
hr_itp_cor = cor(hr)
hr = hr_data
hr$hitter = NULL
hr$pitcher = NULL
hr$class = NULL
hr_cor = cor(hr)

coaches = read.csv("data/nfl_coaches.csv")
coaches = coaches[coaches$g > 49,]
coaches = coaches[coaches$poff_g > 4,]
coaches$sb[is.na(coaches$sb)] = 0 # change NA to 0


shinyServer(
  function(input, output) {
    
   output$plot = renderPlot({
     
     if (input$itp == TRUE){
       hr_data = hr_data_itp
     } else {
       hr_data = hr_data
     }
      
      x = switch(input$x_var,
                 "Speed"=hr_data$speed,
                 "True Dist"=hr_data$dist,
                 "Apex"=hr_data$apex,
                 "Elev Angle"=hr_data$elev,
                 "Horiz Angle"=hr_data$horiz,
                 "Horiz Angle (Flipped)"=hr_data$horiz_flipped
                 )
      
      y = switch(input$y_var,
                 "Speed"=hr_data$speed,
                 "True Dist"=hr_data$dist,
                 "Apex"=hr_data$apex,
                 "Elev Angle"=hr_data$elev,
                 "Horiz Angle"=hr_data$horiz,
                 "Horiz Angle (Flipped)"=hr_data$horiz_flipped
                 )
      
      # determine which plot is displayed
      # base plot
      plot1 = qplot(x, y, alpha=I(0.1), xlab = input$x_var, ylab = input$y_var, size = I(4)) + 
        theme_bw(base_size = 18) + theme(legend.position="none") #+ scale_x_reverse()
      # plot w/ player filter, no regression
      if (input$player != "All"){
        plot1 = qplot(x, y, alpha=I(ifelse(hr_data$hitter == input$player, .9, .05)), 
                      xlab = input$x_var, ylab = input$y_var, size = I(4)) +
          theme_bw(base_size = 18) + theme(legend.position="none")
      }
      # plot w/ default fit, no player filter
      if (input$smooth == "Default*" & input$player == "All"){
        plot1 = qplot(x, y, alpha=I(0.1),  geom=c("point"), size = I(4), xlab = input$x_var, 
                      ylab = input$y_var, level=input$level) + 
          stat_smooth(linetype=I("longdash"), 
                      level=input$level, size = I(1)) + 
          theme_bw(base_size = 18) + theme(legend.position="none")
      }
      # plot w/ lin regression, no player filter
      if (input$smooth == "Linear" & input$player == "All"){
        plot1 = qplot(x, y, alpha=I(0.1),  geom=c("point"), size = I(4), xlab = input$x_var, 
                      ylab = input$y_var, level=input$level) + 
          stat_smooth(method="lm", formula=y~x, linetype=I("longdash"), 
                      level=input$level, size = I(1)) + 
          theme_bw(base_size = 18) + theme(legend.position="none")
      }
      # plot w/ quad regression, no player filter
      if (input$smooth == "Quadratic" & input$player == "All"){
        plot1 = qplot(x, y, alpha=I(0.1),  geom=c("point"), size = I(4), xlab = input$x_var, 
                      ylab = input$y_var, level=input$level) + 
          stat_smooth(method="lm", formula=y~poly(x,2), linetype=I("longdash"), 
                      level=input$level, size = I(1)) + 
          theme_bw(base_size = 18) + theme(legend.position="none")
      }
      
      plot1
})
   
   
   output$hist_x= renderPlot({
     if (input$itp == TRUE){
       hr_data = hr_data_itp
     } else {
       hr_data = hr_data
     }
     
     x = switch(input$x_hist,
                "Speed"=hr_data$speed,
                "True Dist"=hr_data$dist,
                "Apex"=hr_data$apex,
                "Elev Angle"=hr_data$elev,
                "Horiz Angle"=hr_data$horiz,
                "Horiz Angle (Flipped)"=hr_data$horiz_flipped)
     
     qplot(x, xlab = input$x_hist, ylab = "Frequency", alpha=I(.25), binwidth = input$bins,
           col = I("black")) + 
         theme_bw(base_size = 18) + theme(legend.position="none")
   })
   
   output$corr= renderPlot({
     if (input$itp == TRUE){
       corrplot.mixed(hr_itp_cor, upper="circle", lower="number")
     }
   else {corrplot.mixed(hr_cor, upper="circle", lower="number")
   }
   })
     
     
   
   # table of player home runs
   output$table = renderDataTable({
     if (input$itp == TRUE){
       hr_data = hr_data_itp
     } else {
       hr_data = hr_data
     }
     data=NULL
     if (input$player != "All"){
       data = hr_data[hr_data$hitter == input$player,]
     }
     data
   }, options = list(paging=FALSE, searching=FALSE))  
   # display message if "All" is selected
   output$text = renderUI(
     if (input$player == "All"){
       h3("Select a Player", align = "center")
       }
     )
   
   # download dataset
   output$downloadhrData <- downloadHandler(
     filename = function() {"hr_data.csv"},
     content = function(file) {
       write.csv(hr_data_itp, file)
     }
   )
   
   output$plot1= renderPlot({
     
     coaches$reg_ind = ifelse(coaches$perc >= input$reg_cutoff, 1, 0)
     coaches$play_ind = ifelse(coaches$poff_perc >= input$post_cutoff, 0, 1)
     
     coaches_lab = transform(coaches,
                       reg_ind = factor(reg_ind, levels=c(0,1), 
                                        labels=c("'Reg. Season %' < 'Cutoff'",
                                                 "'Reg. Season %' >= 'Cutoff'")),
                       play_ind = factor(play_ind, levels=c(0,1), 
                                         labels=c("'Postseason %' >= 'Cutoff'",
                                                  "'Postseason %' < 'Cutoff'"))
     )
     
       qplot(perc, poff_perc,
             data = coaches_lab, ylab = "Playoff %", xlab = "Win %",
             label=ifelse(name==input$coach, input$coach, ""),
             alpha=ifelse(name==input$coach, 1, .01),
             #xlim=c(0,1), ylim=c(0,1),
             size=ifelse(sb==4, 10, ifelse(sb==3, 8, ifelse(sb==2, 6, ifelse(sb==1, 4, 2))))) + 
         theme_bw(base_size = 18) + geom_text(size=I(4), vjust=1, hjust=1) +
         scale_size(range = c(3, 10)) + theme(legend.position="none") + 
         facet_grid(facets = play_ind ~ reg_ind, labeller=label_parsed, scales = ifelse(
           input$scales == "Fixed", "fixed", "free"))
     # missing jim harbaugh and george halas overlap
   })
       
   # download dataset
   output$downloadcoachData = downloadHandler(
     filename = function() {"coaches.csv"},
     content = function(file) {
       write.csv(coaches, file)
     }
   )
     
  })