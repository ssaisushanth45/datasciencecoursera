

library(shiny)

setwd("~/11. Coursework/1. Data Science Specialization/9. Developing Data Products/4. Submission/NBA Shot Log Analyzer")
shotlog <- read.csv("~/11. Coursework/1. Data Science Specialization/9. Developing Data Products/4. Submission/NBA Shot Log Analyzer/Data/shot_logs.csv")


# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("NBA Shot Logs Analyzer"),
  titlePanel(img(src="SmallLogo.png", height = 100, width = 167, align = "top",
                 style="float:left")),
  
  # Sidebar with a select input for choosing player
  fluidRow(
    column(3, wellPanel(
            helpText("Please select the player whose shot logs you
                        wish to see (NBA Season 2014-15) and click 'Swoosh'"),
            selectInput("player", 
                        label = "Player",
                        choices = sort(unique(shotlog$player_name)),
                        selected = "LEBRON JAMES"),
            submitButton("Swoosh")
    )),
    
    # Show a plot of the generated distribution
    column(6, wellPanel(
            textOutput("pl1"),
            plotOutput("shotchart1",width = 600, height = 400),
            plotOutput("shotchart2",width = 600, height = 400),
            DT::dataTableOutput("datatab"),
            plotOutput("shotchart4",width = 600, height = 400),
            h2("Documentation"),
            p("This is an app I've developed hoping to use as part of my SPANSTATZ (start-up) portfolio."),
            h3("What data am I looking at?"),
            p("NBA Shot Logs Scraped from NBA STATS API Posted on Kaggle by DanB"),
            p("Data on shots taken during the 2014-2015 season."),
            h3("How to use this App?"),
            p("All you have to do is choose the player of interest and hit 'Swoosh'.
                The app should generate the charts based on the shot logs data based
              on the 2014-15 NBA season"),
            h2("Aknowledgements"),
            p("Thanks for the inspiration:"),
            p("Eduardo Maia - thedatagame.com.au"),
            p("Todd W Schneider - BallR Shiny app - Interactive Shot Tracker"),
            p("DanB from Kaggle"),
            p("My next step is to build an actual shot charts visualizer like a lite-version of BallR"),
            h4("This is an R Shiny App developed by Sai S Sampathkumar (github:ssaisushanth45) July 2017")
            )
            
  )
)))
