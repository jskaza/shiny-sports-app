# ui.R

library(shinythemes)
library(markdown)

hr_data = read.csv("data/hr_data_2015.csv")
#hr_data = hr_data[hr_data$dist > 0,] # remove 0 distances (missing data indicator)
today = format(Sys.Date(), format="%B %d %Y")
#attach(hr_data)

coaches = read.csv("data/nfl_coaches.csv")
coaches = coaches[coaches$g > 49,]
coaches = coaches[coaches$poff_g > 5,]
coaches$sb[is.na(coaches$sb)] = 0 # change NA to 0

shinyUI(navbarPage("Sports Viz", theme = shinytheme("spacelab"),
  tabPanel("About",
      tags$div(style="float:left; width:40%; margin-left:60px",       
      p("This app contains several visualizations", HTML("&mdash;"), "some of the interactive variety, others of the
      static variety", HTML("&mdash;"), "pertaining to sports data. 
      As of now, graphics included in the app relate to:", 
      tags$div(
        tags$ul(
          tags$li("Home runs in Major League Baseball"),
          tags$li("Coaches in the National Football League")
        )
      ),
      "I hope to add more interesting plots in the future."
    ),
    p("The Sports Viz app was created using",
      a("Shiny", href = "http://shiny.rstudio.com/", target="_blank"), ", a web application
      framework for R.", 
      "Shiny is available on CRAN and can be installed directly in the R console:"),
    p(code('install.packages("shiny")')),
    p("The underlying data used to build the visualizations are both scraped from 
      their respective websites and parsed using Python. I maintain a",
      a("GitHub repository", href = "https://github.com/jskaza/shiny-sports-app", target="_blank"),
      "that contains code used to obtain the data and produce the app."),
    p(tags$em(paste("Last Updated:", today)))
      ),
    tags$div(style= "float:right; width:50%", align="center",
             img(src = "logo.png", width = 400))
  ),
  navbarMenu("MLB",                 
    tabPanel("Home Runs",
      sidebarLayout(
        sidebarPanel(
          conditionalPanel(condition = "input.tabs=='Scatter Plots' | input.tabs =='Table'",
              h4("Select Variables")
          ),
              p(a("Click here", href = "http://www.hittrackeronline.com/glossary.php", target="_blank"), 
                "for variable descriptions"),
          conditionalPanel(
            condition = "input.tabs != 'Info'",
            checkboxInput("itp", "Add inside-the-park home runs", value = FALSE)
          ),
          conditionalPanel(condition = "input.tabs=='Scatter Plots' | input.tabs =='Table'",
              selectInput("x_var", "X", c("Speed", "True Dist", "Apex", "Elev Angle", "Horiz Angle", 
                                          "Horiz Angle (Flipped)"), selected = "Speed"),
              selectInput("y_var", "Y", c("Speed", "True Dist", "Apex", "Elev Angle", "Horiz Angle",
                                          "Horiz Angle (Flipped)"), selected = "True Dist"),
              h4("Filter by Player"),
              selectInput("player", "Player", c("All", unique(as.character(sort(hr_data$hitter))))),
              conditionalPanel(
                condition = "input.player == 'All' & input.tabs == 'Scatter Plots'",
                h4("Add Fit"),
                radioButtons("smooth", "Method", c("None", "Default*", "Linear", "Quadratic"),
                             select = "None"),
              p(tags$div(style="font-size:10px", "* if n < 1,000 loess, otherwise gam. Refer to",
                         a("ggplot2 documentation", href="http://docs.ggplot2.org/0.9.3.1/stat_smooth.html",
                           target="_blank"), "for details."
              )
              )
              ),
              conditionalPanel(
                condition = "input.smooth != 'None' & input.player == 'All'",
                sliderInput("level", "Confidence Level", min=0, max=.99, value=.95)
              )
          ),
          conditionalPanel(
            condition = "input.tabs=='Histograms'",
            h4("Select Variable"),
            selectInput("x_hist", label = NULL, c("Speed", "True Dist", "Apex", "Elev Angle", "Horiz Angle", "Horiz Angle (Flipped)"), selected = "Speed"),
            sliderInput("bins", "Binwidth", min=1, max=20, value=1, step = .5)
          )
        ),
        mainPanel(
          tabsetPanel(id = "tabs",
            tabPanel("Scatter Plots", plotOutput("plot")),
            tabPanel("Table", dataTableOutput("table"), htmlOutput("text")),
            tabPanel("Histograms", plotOutput("hist_x")),
            tabPanel("Correlations", plotOutput("corr")),
            tabPanel("Info",
                     p("The home run data featured in this application correspond to the 2015 season and are made available by the", a("ESPN Stats & Information
               Group", href="http://espn.go.com/blog/statsinfo/category/_/name/mlb-2", target="_blank"),
                       ". They were scraped from", a("hittrackeronline.com", href="http://www.hittrackeronline.com/",
                                                 target="_blank"),"."),
                     p("The data can be downloaded directly as a csv file by clicking the Download Button below."),
                     br(),
                     downloadButton("downloadhrData", "Download")
            )
          )
        )
      )
    )),
  navbarMenu("NFL",
    tabPanel("Coaches",
      sidebarLayout(
        sidebarPanel(
          selectInput("coach", "Coach", unique(as.character(sort(coaches$name)))),
          sliderInput("reg_cutoff", "Regular Season Cutoff", min = 0, max = 1, value = 0.5),
          sliderInput("post_cutoff", "Postseason Cutoff", min = 0, max = 1, value = 0.5),
          radioButtons("scales", "Scales", c("Fixed", "Free"), selected = "Fixed")
        ),
        mainPanel(
          tabsetPanel(
            tabPanel("Plot", plotOutput("plot1"),
                     br(),
                     div(style="align:right")
            ),
            tabPanel("Info",
                     p("The data used to generate the NFL coaches visualization were
                       scraped from", a("pro-football-reference.com", 
                                        href="http://www.pro-football-reference.com/coaches/",
                                                 target="_blank"), "."),
                     p("The data can be downloaded directly as a csv file by clicking the Download Button below."),
                     br(),
                     downloadButton("downloadcoachData", "Download"),
                     br(),
                     br(),
                     p("The plot illustrates the relationship between a coach's regular season record and playoff record. The 
                       layout of the graph allows one to categorize coaches into one of four categories, as outlined below. The size
                       of the marker corresponds to number of Super Bowls won. In order to be included in the plot, coaches must 
                       have coached in at least 50 regular season games and 5 postseason games."),
                     h4('Taxonomy of Coaches'),
                     tags$div(style= "float:center; width:40%", align="left",
                              img(src = "four_boxes.png", width = 300)),
                     p(tags$b('1. The Ken Whisenhunts:'), 'These coaches boast mediocre or even subpar regular season records. 
                        However, if they are able to sneak into the postseason, their teams have proven to be tough outs. 
                       In 2008, Whisenhunt took the 9-7 Cardinals to the Super Bowl.'),
                     p(tags$b('2. The Vince Lombardis:'), 'Coaches at the top of this elite category are recognized as all-time greats. 
                        They simply rack up regular season wins while demonstrating an ability to win in the playoffs. In his 9 years in Green Bay, Lombardi amassed 
                        a .738 regular season winning percentage and a 9-1 postseason record.'),
                     p(tags$b('3. The Herm Edwardses:'), '"You play to win the game!". Unfortunately for Edwards and other coaches in this 
                        category, their teams did not win many games whether it be regular season or postseason.'), 
                     p(tags$b('4. The George Allens:'), 'Coaches in this category boast respectable regular season records but
                       fail to live up to expectations in the playoffs in the eyes of some. George Allen went 116-47 in the regular season
                       during his 12 years in the NFL. However, he boasts a meager 2-7 career playoff record and does 
                       not have a Super Bowl victory to his name.')
            )
          )
        )
      )
    )
  )
))