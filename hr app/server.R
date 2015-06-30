# server.R

library(hexbin)
library(rje)
library(RColorBrewer)
library(MASS)
library(scatterplot3d)
library(beeswarm)
library(lattice)
library

# load and process hr_data 
hr_data = read.csv("~/Misc Projects/mlb hr/hr_data.csv")
hr_data$X = NULL
hr_data = hr_data[hr_data$dist > 0,] # remove 0 distances (missing data indicator)

shinyServer(
  function(input, output) { 
    
    output$plot = renderPlot({
      
      x = switch(input$x_var,
                 "Speed"=hr_data$speed,
                 "Dist"=hr_data$dist,
                 "Apex"=hr_data$apex)
      y = switch(input$y_var,
                 "Speed"=hr_data$speed,
                 "Dist"=hr_data$dist,
                 "Apex"=hr_data$apex)
      z = switch(input$z_var,
                     "Speed"=hr_data$speed,
                     "Dist"=hr_data$dist,
                     "Apex"=hr_data$apex)
                      
      # determine which plot is displayed
      # base 2d plot
      plot1 = plot(x, y, pch=20, xlab = input$x_var, ylab = input$y_var, col = rgb(0,0,0,.2), 
                   main = paste(input$y_var, "vs.", input$x_var))
      if (input$reg == "Yes"){
      reg2d = lm(y~x)
      abline(reg2d)
      }
      
      # base 1d plot
      if(input$player == "All" & input$y_var == "None" & input$z_var == "None"){
        plot1 = plot(x,y)
      }
      
      # base 3d plot
      if(input$player == "All" & input$y_var != "None" & input$z_var != "None"){
        plot1 = scatterplot3d(x,y,z, color=rgb(0,0,0,.2), pch=20)
        if (input$reg == "Yes"){
          reg3d = lm(y~x + z)
          plot1 = plotPlane(reg3d, plotx1 = "x", plotx2 = "z", pch=20, pcol = rgb(0,0,0,.2),
                            theta = 30, phi = 20, x1lab = input$x_var, x2lab = input$z_var,
                            ylab= input$y_var)
        }
      }
      
      # 2d plot w/ player filter
      if (input$player != "All" & input$z_var == "None"){
        plot1 = plot(x , y, col = ifelse(hr_data$hitter == input$player, rgb(0,0,1), rgb(0,0,0,.2)),
                     pch=20, cex = ifelse(hr_data$hitter == input$player, 2, 1),
                     xlab = input$x_var, ylab = input$y_var, main = paste(input$y_var, "vs.", input$x_var))
        text(quantile(x, .01), quantile(y, .99), input$player, col=rgb(0,0,1))
        if (input$reg == "Yes"){
          reg2d = lm(y~x)
          abline(reg2d, col = "red", lty = 2, lwd = 3)
        }
      }
      
      # 1d plot w/ player filter
      if (input$player != "All" & input$y_var == "None" & input$z_var == "None"){
        if (input$reg == "Yes" | input$reg == "No"){
        plot1 = ggplot(hr_data, aes(x=speed, y=hitter)) + 
          geom_jitter() + theme(axis.text.y=element_blank(), axis.ticks=element_blank())
        }
      }
      
#       # 3d plot w/ player filter
#       if (input$player != "All" & input$y_var != "None" & input$z_var != "None"){
#         plot1 = scatterplot3d(x,y,z, 
#                               color = ifelse(hr_data$hitter == input$player, 
#                                              rgb(0,0,1), rgb(0,0,0,.2)), pch=20, cex.symbols=ifelse(
#                                                hr_data$hitter == input$player, 2, 1))
#         if (input$reg == "Yes"){
#           reg3d = lm(y~x + z)
#           plot1 = plotPlane(reg3d, plotx1 = "x", plotx2 = "z", pch=20, 
#                             pcol = ifelse(hr_data$hitter == input$player, rgb(0,0,1),
#                                           rgb(0,0,0,.2)),
#                             theta = 30, phi = 20, x1lab = input$x_var, x2lab = input$z_var,
#                             ylab= input$y_var, 
#                             pcex= ifelse(hr_data$hitter == input$player, 2, 1))
#         }
#       }
#       # what if Y == "None" and Z != "None"
#         if (input$y_var == "None" & input$z_var != "None"){ 
#           plot1 = plot(1, type="n", axes=F, xlab="", ylab="")
#           text(1,1,"Choose Y", cex = 3)
#      }
      # show the plot
      plot1
    })
    
    output$table = renderDataTable({
      data=NULL
      if (input$player != "All"){
        data = hr_data[hr_data$hitter == input$player,]
      }
      data
    }, options = list(paging=FALSE, searching=FALSE))
    
# 
     output$plot2 = renderPlot({
       
       x2 = switch(input$x_var2,
                   "Speed"=hr_data$speed,
                   "Dist"=hr_data$dist,
                   "Apex"=hr_data$apex)
       
       y2 = switch(input$y_var2,
                   "Speed"=hr_data$speed,
                   "Dist"=hr_data$dist,
                   "Apex"=hr_data$apex)
       
       cscheme = switch(input$colors,
                        "Cubehelix" = colorRampPalette(cubeHelix(101)),
                          "Heat" = colorRampPalette(heat.colors(101)),
                        "Terrain" =colorRampPalette(terrain.colors(101)))
       col = switch(input$colors,
                    "Cubehelix" = cubeHelix(101),
                    "Heat" = heat.colors(101),
                    "Terrain"=terrain.colors(101))
       
       plot2 = hexbinplot(y2~x2, colramp=cscheme, main = paste(input$y_var2, "vs.", input$x_var2), xlab=input$x_var2,
                          ylab=input$y_var2)
       
       if (input$type == "Smoothed"){
       plot2 = image(kde2d(x2, y2, n=250), col = col)
       }
       
       if (input$type == "Combo"){
         h1 <- hist(x2, breaks=30, plot=F)
         h2 <- hist(y2, breaks=30, plot=F)
         top <- max(h1$counts, h2$counts)
         k <- kde2d(x2, y2, n=30)
         
         # margins
         oldpar = par()
         par(mar=c(3,3,1,1))
         layout(matrix(c(2,0,1,3),2,2,byrow=T),c(3,1), c(1,3))
         image(k, col=col) #plot the image
         par(mar=c(0,2,1,0))
         barplot(h1$counts, axes=F, ylim=c(0, top), space=0, col='snow3')
         par(mar=c(2,0,0.5,1))
         plot2=barplot(h2$counts, axes=F, xlim=c(0, top), space=0, col='snow3', horiz=T)
       }
      
      plot2
       
        }, width=600, height=600)
     
     output$downloadData <- downloadHandler(
     
     # This function returns a string which tells the client
     # browser what name to use when saving the file.
     filename = function() {
       paste("hr_data.csv")
     },
     
     # This function should write data to a file given to it by
     # the argument 'file'.
     content = function(file) {
       sep = ","
       
       # Write to a file specified by the 'file' argument
       write.table(hr_data, file, sep = sep,
                   row.names = FALSE)
     }
     )
 
    
  })