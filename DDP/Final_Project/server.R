library(shiny)
library(ggplot2)
library(tidyr)
library(dplyr)
library(grid)
library(gridExtra)

shotlog <- read.csv("~/11. Coursework/1. Data Science Specialization/9. Developing Data Products/4. Submission/NBA Shot Log Analyzer/Data/shot_logs.csv")


shinyServer(function(input, output) {
   
                output$pl1 <- renderText({
                paste("You have selected", input$player, "as your player of interest\n")
        
                })
        
  output$shotchart1 <- renderPlot({
    # generate data
          shotmvm <- shotlog %>%
                  group_by(player_name, SHOT_RESULT, LOCATION) %>%
                  summarize(countmm = n()) %>%
                  mutate(prop = countmm/sum(countmm))%>%
                  filter(player_name == input$player)
          shotmvm <- as.data.frame(shotmvm)
          colnames(shotmvm) <- c("Player", "Shot_Result","Location","Shot_Count","Shot_Pct")
          shotmvm$Location <- with(shotmvm, factor(Location, levels = rev(levels(Location))))
         
          
          
    # generate shots taken (made vs. missed)

         ggplot(shotmvm, aes(x = Shot_Result, y = Shot_Pct)) + facet_grid(.~ Location) +
                  ggtitle(paste("%Shots Made vs. Missed by ", unique(input$player),"\n Home vs Away Games" , sep = "")) +
                  geom_bar(stat = "identity", fill = "orange", alpha = 0.8) +
                  xlab("Shots Made vs. Missed") + ylab("% Shots")
    
  })
  output$shotchart2 <- renderPlot({
          # generate data
          shotmvmw <- shotlog %>%
                  group_by(player_name, SHOT_RESULT, W) %>%
                  summarize(countmm = n()) %>%
                  mutate(prop = countmm/sum(countmm))%>%
                  filter(player_name == input$player)
          shotmvmw <- as.data.frame(shotmvmw)
          colnames(shotmvmw) <- c("Player", "Shot_Result","WL","Shot_Count","Shot_Pct")
          shotmvmw$WL <- with(shotmvmw, factor(WL, levels = rev(levels(WL))))
          
          
          # generate shots taken (made vs. missed)
          
          ggplot(shotmvmw, aes(x = Shot_Result, y = Shot_Pct)) + facet_grid(.~ WL) +
                  ggtitle(paste("%Shots Made vs. Missed by ", unique(input$player),"\n Win vs.Loss Games", sep = "")) +
                  geom_bar(stat = "identity", fill = "orange", alpha = 0.8) +
                  xlab("Shots Made vs. Missed") + ylab("% Shots")
          
  })
  
  output$datatab <- DT::renderDataTable({
          # generate data
          shotdist <- shotlog %>%
                  filter(player_name == input$player)
          shotdist <- as.data.frame(shotdist)
          shotdist$distrange <- cut(shotdist$SHOT_DIST, c(0,5,10,15,20,25,30,50))
          levels(shotdist$distrange) <- c("Less Than 5Ft","5-9Ft","10-14Ft","15-19Ft","20-24Ft","25-29Ft","30+Ft")
          shotdist <- shotdist[,c(2:4,6:8,10:14,18,20,22)]
          # generate shots taken (made vs. missed)
          shotdist <- shotdist %>%
                  group_by(player_name, distrange, SHOT_RESULT) %>%
                  summarize(Count = n())
          shotdist <- data.frame(shotdist,Value = TRUE)
          shotdist <- reshape(shotdist, idvar = c("player_name","distrange"),
                              timevar = "SHOT_RESULT", direction = "wide")
          shotdist <- shotdist[,c(1,2,3,5)]
          colnames(shotdist) <- c("Player Name", "Distance Range","Shots Made", "Shots Missed")
                  
          DT::datatable(shotdist, options = list(pageLength = 10), rownames = FALSE)
          
  })
  output$shotchart4 <- renderPlot({
          # generate data
          shotdef <- shotlog %>%
                  filter(player_name == input$player)%>%
                  group_by(player_name, CLOSEST_DEFENDER, SHOT_RESULT) %>%
                  summarize(Count = n())
                
          shotdef <- as.data.frame(shotdef)
          shotdef <- data.frame(shotdef,Value = TRUE)
          shotdef <- reshape(shotdef, idvar = c("player_name","CLOSEST_DEFENDER"),
                              timevar = "SHOT_RESULT", direction = "wide")
          shotdef <- shotdef[,c(1,2,3,5)]
          colnames(shotdef) <- c("Player Name", "Defender","Shots Made", "Shots Missed")
          
          Bestdef <- shotdef %>%
                  arrange(desc(`Shots Missed`))
          Bestdef <- Bestdef[1:10,]       
          
          Worstdef <- shotdef %>%
                  arrange(desc(`Shots Made`))
          Worstdef <- Worstdef[1:10,]
          
          g1 <- ggplot(Bestdef, aes(reorder(Defender,-`Shots Missed`), `Shots Missed`)) +
                  geom_bar(stat = "identity", fill = "orange", alpha=0.8) + 
                  xlab("Defender Name") + 
                  ylab("# Shots Missed") + ylim(0,15) + 
                  ggtitle(paste("Best Defenders Guarding ",input$player)) +
                  theme(axis.text.x = element_text(angle = 90, hjust = 1))
          g2 <- ggplot(Worstdef, aes(reorder(Defender,-`Shots Made`), `Shots Made`)) +
                  geom_bar(stat = "identity", fill = "orange", alpha=0.8) + 
                  xlab("Defender Name") + 
                  ylab("# Shots Made") +  ylim(0,15) + 
                  ggtitle(paste("Worst Defenders Guarding ",input$player)) +
                  theme(axis.text.x = element_text(angle = 90, hjust = 1))
          grid.arrange(g1, g2, ncol=2)
          
  })
})
