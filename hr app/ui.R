# ui.R
library(shinythemes)

hr_data = read.csv("~/Misc Projects/mlb hr/hr_data.csv")
hr_data$X = NULL
hr_data = hr_data[hr_data$dist > 0,] # remove 0 distances (missing data indicator)
today = format(Sys.Date(), format="%B %d %Y")
#attach(hr_data)

shinyUI(navbarPage("Data Viz", theme = shinytheme("spacelab"),
  tabPanel("About",
    p("p creates a paragraph of text."),
    code('install.packages("shiny")'),
    p(paste("Last Updated:", today))
  ),
  navbarMenu("MLB HR",                 
    tabPanel("Scatter Plots",
      sidebarLayout(
        sidebarPanel(
          h4("Select Variables"),
          selectInput("x_var", "X", c("Speed", "Dist", "Apex"), selected = "Speed"),
          selectInput("y_var", "Y", c("None", "Speed", "Dist", "Apex"), selected = "Dist"),
          selectInput("z_var", "Z", c("None", "Speed", "Dist", "Apex"), selected = "None"),
          h4("Filter by Player"),
          selectInput("player", "Player", c("All", unique(as.character(sort(hr_data$hitter))))),
          br(),
          radioButtons("reg", "Regression Line/Plane?", c("Yes", "No"), select = "No")
          ),
        mainPanel(
          plotOutput('plot'),
          dataTableOutput("table")
        )
      )
    ),
    tabPanel("Histograms",
      sidebarLayout(
        sidebarPanel(
          h4("Select Variables"),
          selectInput("x_var2", "X", choices=c("Speed", "Dist", "Apex"), selected = "Speed"),
          selectInput("y_var2", "Y", c("Speed", "Dist", "Apex"), selected = "Dist"),
          h4("Select Plot Preferences"),
          radioButtons("colors", "Color Scheme", c("Cubehelix", "Heat", "Terrain")),
          radioButtons("type", "Appearance", c("Hexagons", "Smoothed", "Combo"))
        ),
        mainPanel(
          plotOutput(outputId='plot2')
        )
      )
    ),
    tabPanel("Info",
             p("The Home Run data featured in this application is made available by the", a("ESPN Stats & Information
               Group", href="http://espn.go.com/blog/statsinfo/category/_/name/mlb-2", target="_blank"),
               "and was scraped from", a("hittrackeronline.com", href="http://www.hittrackeronline.com/",
                                              target="_blank"),"."),
             p("The data can be downloaded directly as a csv file by and clicking the Download Button below."),
             br(),
             downloadButton("downloadData", "Download")
             )
  ),
  navbarMenu("NBA Shooting",
    tabPanel("Scatter Plots",
      sidebarLayout(
        sidebarPanel(
          helpText("Plots of advanced team shooting statistics."),
          selectInput("x112", label = "Choose a variable to display", choices = c("t", "y")),
          selectInput("y1122", label = "Choose a variable to display", choices = c("C&S PTS", "C&")),
          sliderInput("slider1", label="", min=1, max=30, value=15)
        ),
        mainPanel(
          plotOutput("plot22"),
          br(),
          plotOutput("plot2222", width = "40%")
        )
      )
    )
  )
))
                    
            
                    
                  #   fluidRow(
                  #     column(3,
                  #            h4("Select Variables"),
                  #            selectInput("x_var", "X", c("Speed", "Dist", "Apex")),
                  #            selectInput("y_var", "Y", c("Speed", "Dist", "Apex"))
                  #     ),
                  #     column(3,
                  #            h4("Select Plot Preferences"),
                  #            radioButtons("colors", "Color Scheme", c("cubeHelix", "Heat")),
                  #            radioButtons("type", "Type", c("Hexagons", "Smoothed", "Scatter"))
                  #     ),
                  #     column(3,
                  #            h4("Filter by Player"),
                  #            selectInput("player", "Player", c("All", 
                  #                                              unique(as.character(sort(hr_data$hitter)))))
                  #     )
                  #   )
                  # ))
                  #                         
                             
                  #    ),
                  #    column(4, offset = 1,
                  #           selectInput('x', 'X'),
                  #           selectInput('y', 'Y'),
                  #           selectInput('color', 'Color')
                  #    ),
                  #    column(4,
                  #           selectInput('facet_row', 'Facet Row', c(None='.', names(dataset))),
                  #           selectInput('facet_col', 'Facet Column', c(None='.', names(dataset)))
