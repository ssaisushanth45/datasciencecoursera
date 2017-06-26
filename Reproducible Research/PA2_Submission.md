# Analysis of US NOAA Storm Data to Study Most Harmful Events Affecting Population Health and Economy
Sai S Sampathkumar (github: ssaisushanth45)  
23 June 2017  



## Synopsis

Storms and other severe weather events can cause both public health and economic problems for communities and municipalities. Many severe events can result in fatalities, injuries, and property damage, and preventing such outcomes to the extent possible is a key concern.

This project involves exploring the U.S. National Oceanic and Atmospheric Administration's (NOAA) storm database. This database tracks characteristics of major storms and weather events in the United States, including when and where they occur, as well as estimates of any fatalities, injuries, and property damage. 


### *Objective*

The objective of this project is to better understand which types of severe weather events, across the US, are the most harmful to population health and have greatest economic consequences.

### *Data *

The data for this project can be downloaded from <https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2FStormData.csv.bz2>. For more information on the data and how variables are defined, please visit:

- National Weather Service Storm Data Documentation <https://d396qusza40orc.cloudfront.net/repdata%2Fpeer2_doc%2Fpd01016005curr.pdf>
- National Climatic Data Center Storm Events FAQ <https://d396qusza40orc.cloudfront.net/repdata%2Fpeer2_doc%2FNCDC%20Storm%20Events-FAQ%20Page.pdf>

### *Data Challenges*

- Legacy Mapping of Event Types
- Damage Figures in Multiple Columns (figure + exp)

## Data Processing

We first download the data and read it into R software for processing and anlysis. 


```r
setwd("C:/Users/ssais/Documents/11. Coursework/1. Data Science Specialization/5. Reproducible Research/2. Data/")
stormdata <- read.csv("./repdata%2Fdata%2FStormData.csv.bz2")
dim(stormdata)
```

```
## [1] 902297     37
```

Data has 902297 observtaions and 37 variables of events from April 1950 - November 2011. Please note, according to NWS and based on how the data is collated from verified and unverified sources, users of this data need to exercise caution as NWS DOES NOT guarantee the accuracy or validity of the information.  

### *Preliminary Exploration*


```r
# call necessary R packages
suppressPackageStartupMessages(suppressWarnings(library(lubridate)))
suppressPackageStartupMessages(suppressWarnings(library(dplyr)))
suppressPackageStartupMessages(suppressWarnings(library(ggplot2)))
suppressPackageStartupMessages(suppressWarnings(library(grid)))
suppressPackageStartupMessages(suppressWarnings(library(gridExtra)))

# adding a variable date (same as Begin Date but formatted as date not as factor); we want to see how much data was collected by year to understand anomalies in data collection 

stormdata$Date <- as.Date(stormdata$BGN_DATE, "%m/%d/%Y")
stormdata$Year <- year(stormdata$Date)

# Count number of events by year, descending sort and calculate % contribution of each year of Total number of events in the data set

countev <- stormdata %>%
                group_by(Year) %>%
                summarize(count = n())%>%
                        mutate(prop = count/sum(count))

countev$cummprop<- countev$prop
for (i in 2:length(countev$Year))
countev$cummprop[i] <- countev$cummprop[i-1] + countev$prop[i]

# Based on number of events by year, look at % Year Over Year Jump to detect any anomalies in data.

countev$yoyjump <- 0
for (i in 2:length(countev$Year))
countev$yoyjump[i] <- ((countev$count[i]/countev$count[i-1])-1)* 100
tail(countev,20)
```

```
## # A tibble: 20 × 5
##     Year count       prop  cummprop     yoyjump
##    <dbl> <int>      <dbl>     <dbl>       <dbl>
## 1   1992 13534 0.01499950 0.2078684   8.0817761
## 2   1993 12607 0.01397212 0.2218405  -6.8494163
## 3   1994 20631 0.02286498 0.2447055  63.6471801
## 4   1995 27970 0.03099866 0.2757041  35.5726819
## 5   1996 32270 0.03576428 0.3114684  15.3736146
## 6   1997 28680 0.03178554 0.3432539 -11.1248838
## 7   1998 38128 0.04225660 0.3855105  32.9428173
## 8   1999 31289 0.03467705 0.4201876 -17.9369492
## 9   2000 34471 0.03820361 0.4583912  10.1697082
## 10  2001 34962 0.03874777 0.4971390   1.4243857
## 11  2002 36293 0.04022290 0.5373619   3.8069904
## 12  2003 39752 0.04405645 0.5814183   9.5307635
## 13  2004 39363 0.04362533 0.6250436  -0.9785671
## 14  2005 39184 0.04342694 0.6684706  -0.4547418
## 15  2006 44034 0.04880211 0.7172727  12.3775010
## 16  2007 43289 0.04797644 0.7652491  -1.6918745
## 17  2008 55663 0.06169033 0.8269395  28.5846289
## 18  2009 45817 0.05077818 0.8777176 -17.6885903
## 19  2010 48161 0.05337599 0.9310936   5.1160050
## 20  2011 62174 0.06890636 1.0000000  29.0961566
```

A table of counts of events per year in the dataset reveals an interesting pattern. The table shows just last 20 years (between 1992-2011) of data reveals 80% of data collected. That led to the discovery that from 1950 - 1955, only Tornadoes were recorded. From 1955 -1992, only Tornadoes, Thunderstorm Wind, Hail events were published and digitized. From 1992-1995, only Tornadoes, Thunderstorm Wind, Hail events were extracted. From 1996, all 48 event types have been recorded. see link for more information: <https://www.ncdc.noaa.gov/stormevents/details.jsp?type=eventtype>


Based on the data documentation, Fatalities and Injuries (Direct, Indirect and Delayed) are shown in separate columns. We will first process the data for preparing the input for a panel plot by Fatalities and Injuries across event Types. 

### *DC 1 - Legacy Mapping of Event Types*
Creating a summary table (FAT_INJ_EVTYPE) of sum of fatalities and injuries by event type shows that there are 985 levels of event type. However, this needs to reflect only 48 official event name types as shown in the documentation links above. So, we need to figure out some way of reducing the number of historical events into the official ones post 1996. 


```r
Fat_Inj_Evtype <- stormdata %>%
                        group_by(EVTYPE)%>%
                        summarize(Fsum = sum(FATALITIES),Isum = sum(INJURIES))%>%
                        arrange(desc(Fsum),desc(Isum))

names(Fat_Inj_Evtype)
```

```
## [1] "EVTYPE" "Fsum"   "Isum"
```

```r
dim(Fat_Inj_Evtype)
```

```
## [1] 985   3
```


First, to keep manual mapping to a minimum, we re-create the summary table FAT_INJ_EVTYPE which shows only 220 event types of 985 have atleast 1 injury or fatality. We then create and read a commma separated text table containing 48 event names from section 2.1.1 of current NWS directive - NWS 10 - 1605 (link given above).


```r
Fat_Inj_Evtype <- stormdata %>%
                        group_by(EVTYPE)%>%
                        summarize(Fsum = sum(FATALITIES),Isum = sum(INJURIES))%>%
                        arrange(desc(Fsum),desc(Isum)) %>%
                        filter(Fsum >0 | Isum > 0)
dim(Fat_Inj_Evtype)
```

```
## [1] 220   3
```

From the 220 event types, we notice that manually mapping top 70 event types (some already in correct mapping) covers about 94% of the Fatalities & 98% of Injuries data and ensures we obtain top 30 events causing Most Fatalities and top 30 events causing Most Injuries.


```r
setwd("C:/Users/ssais/Documents/11. Coursework/1. Data Science Specialization/5. Reproducible Research/2. Data/")

# Manual Mapping of 70/220 event types capture 94% of total Fatalities and 98% of Total Injuries - which is pretty encompassing for minimal manual effort.
write.csv(Fat_Inj_Evtype,"./Fat_Inj_Evtype.csv")

Evtype_MapP <- read.csv("./event_mapping_prop.csv", header = TRUE)
dim(Evtype_MapP)
```

```
## [1] 70  2
```

```r
# Evtype_MapP table shows the mapping
head(Evtype_MapP,70)
```

```
##                        EVTYPE                  Off_Map
## 1                   AVALANCHE                Avalanche
## 2                    AVALANCE                Avalanche
## 3                    BLIZZARD                 Blizzard
## 4    COASTAL FLOODING/EROSION            Coastal Flood
## 5               COASTAL FLOOD            Coastal Flood
## 6            Coastal Flooding            Coastal Flood
## 7            COASTAL FLOODING            Coastal Flood
## 8                        COLD          Cold/Wind Chill
## 9             COLD/WIND CHILL          Cold/Wind Chill
## 10              COLD AND SNOW          Cold/Wind Chill
## 11               COLD WEATHER          Cold/Wind Chill
## 12                       Cold          Cold/Wind Chill
## 13                  COLD WAVE          Cold/Wind Chill
## 14           Cold Temperature          Cold/Wind Chill
## 15                 COLD/WINDS          Cold/Wind Chill
## 16                  LANDSLIDE              Debris Flow
## 17                        FOG                Dense Fog
## 18                  DENSE FOG                Dense Fog
## 19                    DROUGHT                  Drought
## 20     DROUGHT/EXCESSIVE HEAT                  Drought
## 21                 DUST STORM               Dust Storm
## 22             EXCESSIVE HEAT           Excessive Heat
## 23                  HEAT WAVE           Excessive Heat
## 24               EXTREME HEAT           Excessive Heat
## 25               EXTREME COLD Extreme Cold/ Wind Chill
## 26    EXTREME COLD/WIND CHILL Extreme Cold/ Wind Chill
## 27          EXTREME WINDCHILL Extreme Cold/ Wind Chill
## 28               Extreme Cold Extreme Cold/ Wind Chill
## 29                FLASH FLOOD              Flash Flood
## 30             FLASH FLOODING              Flash Flood
## 31          FLASH FLOOD/FLOOD              Flash Flood
## 32       FLASH FLOODING/FLOOD              Flash Flood
## 33               FLASH FLOODS              Flash Flood
## 34                      FLOOD                    Flood
## 35          FLOOD/FLASH FLOOD                    Flood
## 36                   FLOODING                    Flood
## 37         FLOOD & HEAVY RAIN                    Flood
## 38          FLOOD/RIVER FLOOD                    Flood
## 39                       HAIL                     Hail
## 40                       HEAT                     Heat
## 41                 HEAVY RAIN               Heavy Rain
## 42                 HEAVY SNOW               Heavy Snow
## 43                  HIGH SURF                High Surf
## 44       HEAVY SURF/HIGH SURF                High Surf
## 45                  HIGH WIND                High Wind
## 46                 HIGH WINDS                High Wind
## 47          HURRICANE/TYPHOON      Hurricane (Typhoon)
## 48                  HURRICANE      Hurricane (Typhoon)
## 49          Hurricane Edouard      Hurricane (Typhoon)
## 50 HURRICANE-GENERATED SWELLS      Hurricane (Typhoon)
## 51             HURRICANE ERIN      Hurricane (Typhoon)
## 52             HURRICANE OPAL      Hurricane (Typhoon)
## 53            HURRICANE EMILY      Hurricane (Typhoon)
## 54  HURRICANE OPAL/HIGH WINDS      Hurricane (Typhoon)
## 55            HURRICANE FELIX      Hurricane (Typhoon)
## 56                  ICE STORM                Ice Storm
## 57                  LIGHTNING                Lightning
## 58               RIP CURRENTS              Rip Current
## 59                RIP CURRENT              Rip Current
## 60                STRONG WIND              Strong Wind
## 61                  TSTM WIND        Thunderstorm Wind
## 62          THUNDERSTORM WIND        Thunderstorm Wind
## 63         THUNDERSTORM WINDS        Thunderstorm Wind
## 64                    TORNADO                  Tornado
## 65             TROPICAL STORM           Tropical Storm
## 66                    TSUNAMI                  Tsunami
## 67                   WILDFIRE                 Wildfire
## 68           WILD/FOREST FIRE                 Wildfire
## 69               WINTER STORM             Winter Storm
## 70             WINTER WEATHER           Winter Weather
```

```r
# Merge summary table to official event types

Fat_Inj_Evtype <- merge(Fat_Inj_Evtype, Evtype_MapP, by = "EVTYPE")
dim(Fat_Inj_Evtype)
```

```
## [1] 70  4
```

```r
# Create Top 30 Most Harmful Events to Population Health Summary 

Fat_Inj_Evtype <- Fat_Inj_Evtype %>%
                        group_by(Off_Map)%>%
                        summarize(Fsum = sum(Fsum),Isum = sum(Isum))%>%
                        select(Off_Map,Fsum,Isum)
dim(Fat_Inj_Evtype)
```

```
## [1] 30  3
```


### *DC 2 - Damage Figures in Multiple Columns*
Before creating a summary table (PRP_CROP_EVTYPE) of sum of property and crop damage by event type, we need to address the issue of multiplying the damage figures by the appropriate denomination (exp). There are two variable "PROPDMGEXP" and "CROPDMGEXP" that need to be first cleaned up and then multiplied with "PROPDMG" and "CROPDMG" figures. 

There are 19 unique levels for PROPDMGEXP and 9 levels for CROPDMGEXP. Section 2.7 of the PD01016005 directive shows only 3 valid levels for EXP variables. K for thousand, M for million and B for billion. To get some clues on what these other mysterious character were, I took a look at characters by year (temp,temc) they were keyed in to find that all mysterious characters (other than K,M,B or k,m,b) for EXP variables show up during 1993-1995 period - this was when data were extracted from unformatted text files. Without clear documentation on what these characters mean, it would be unwise to use them for our analysis.

```r
unique(stormdata$PROPDMGEXP)
```

```
##  [1] K M   B m + 0 5 6 ? 4 2 3 h 7 H - 1 8
## Levels:  - ? + 0 1 2 3 4 5 6 7 8 B h H K m M
```

```r
unique(stormdata$CROPDMGEXP)
```

```
## [1]   M K m B ? 0 k 2
## Levels:  ? 0 2 B k K m M
```

```r
# Temporary tables for further investigation of characters
temp <- stormdata %>% 
 group_by(Year, PROPDMGEXP) %>%
 summarize(Psum = sum(PROPDMG))
temc <- stormdata %>% 
 group_by(Year, CROPDMGEXP) %>%
 summarize(Psum = sum(CROPDMG))

# adding 4 variables to handle the damage assessment calculations
stormdata$pmultiplier <- 0
stormdata$cmultiplier <- 0
stormdata$totalprop <- 0
stormdata$totalcrop <- 0

# vectorization to speed up computation
kKP <- which(stormdata$PROPDMGEXP %in% c("k","K"))
mMP <- which(stormdata$PROPDMGEXP %in% c("m","M"))
bBP <- which(stormdata$PROPDMGEXP %in% c("b","B"))

# setting pmultiplier (property) to 1000 for K, 1000000 for M, 1000000000 for B
stormdata$pmultiplier[kKP] <- 1000
stormdata$pmultiplier[mMP] <- 1000000 
stormdata$pmultiplier[bBP] <- 1000000000

stormdata$totalprop <- stormdata$pmultiplier * stormdata$PROPDMG

# setting cmultiplier (crop) to 1000 for K, 1000000 for M, 1000000000 for B

kKC <- which(stormdata$CROPDMGEXP %in% c("k","K"))
mMC <- which(stormdata$CROPDMGEXP %in% c("m","M"))
bBC <- which(stormdata$CROPDMGEXP %in% c("b","B"))

stormdata$cmultiplier[kKC] <- 1000
stormdata$cmultiplier[mMC] <- 1000000 
stormdata$cmultiplier[bBC] <- 1000000000

stormdata$totalcrop <- stormdata$cmultiplier * stormdata$CROPDMG
```

We have cleaned up the property and crop damage figures into actual $ figures. We now have to redo a similar clean up for event types coding as we did before to create a summary table of Prop_Crop_Evtype. We come back to our 985 event types. We reduce this to 426 event types with either property or crop damage > 0.


```r
Prop_Crop_Evtype <- stormdata %>%
                        group_by(EVTYPE) %>%
                        summarize(Psum = sum(totalprop), Csum = sum(totalcrop)) %>%
                        arrange(desc(Psum),desc(Csum)) 
dim(Prop_Crop_Evtype)
```

```
## [1] 985   3
```

```r
Prop_Crop_Evtype <- stormdata %>%
                        group_by(EVTYPE)%>%
                        summarize(Psum = sum(totalprop),Csum = sum(totalcrop))%>%
                        arrange(desc(Psum),desc(Csum)) %>%
                        filter(Psum > 0 | Csum > 0)
dim(Prop_Crop_Evtype)
```

```
## [1] 426   3
```

From the 426 event types, we notice that manually mapping top 113 event types (some already in correct mapping) ensures we obtain top 30 events causing Most Economic Damage


```r
setwd("C:/Users/ssais/Documents/11. Coursework/1. Data Science Specialization/5. Reproducible Research/2. Data/")

write.csv(Prop_Crop_Evtype,"./Prop_Crop_Evtype.csv")
# Manual Mapping of 113/426 event types

Evtype_MapC <- read.csv("./event_mapping_crop.csv", header = TRUE)
dim(Evtype_MapC)
```

```
## [1] 113   2
```

```r
# Evtype_Map table shows the mapping
head(Evtype_MapC,113)
```

```
##                         EVTYPE                 Off_Map
## 1                    TSTM WIND       Thunderstorm Wind
## 2          AGRICULTURAL FREEZE            Frost/Freeze
## 3       ASTRONOMICAL HIGH TIDE        Storm Surge/Tide
## 4                     BLIZZARD                Blizzard
## 5    COASTAL  FLOODING/EROSION           Coastal Flood
## 6                COASTAL FLOOD           Coastal Flood
## 7                Coastal Flood           Coastal Flood
## 8             COASTAL FLOODING           Coastal Flood
## 9     COASTAL FLOODING/EROSION           Coastal Flood
## 10     COLD AND WET CONDITIONS         Cold/Wind Chill
## 11             COLD/WIND CHILL         Cold/Wind Chill
## 12                COOL AND WET         Cold/Wind Chill
## 13             DAMAGING FREEZE            Frost/Freeze
## 14             Damaging Freeze            Frost/Freeze
## 15                   DENSE FOG               Dense Fog
## 16                     DROUGHT                 Drought
## 17                  DUST STORM              Dust Storm
## 18                 Early Frost            Frost/Freeze
## 19          Erosion/Cstl Flood           Coastal Flood
## 20              EXCESSIVE HEAT          Excessive Heat
## 21           EXCESSIVE WETNESS              Heavy Rain
## 22                EXTREME COLD Extreme Cold/Wind Chill
## 23                Extreme Cold Extreme Cold/Wind Chill
## 24     EXTREME COLD/WIND CHILL Extreme Cold/Wind Chill
## 25                EXTREME HEAT          Excessive Heat
## 26           EXTREME WINDCHILL Extreme Cold/Wind Chill
## 27                 FLASH FLOOD             Flash Flood
## 28           FLASH FLOOD/FLOOD             Flash Flood
## 29              FLASH FLOODING             Flash Flood
## 30                FLASH FLOODS             Flash Flood
## 31                       FLOOD                   Flood
## 32          FLOOD & HEAVY RAIN                   Flood
## 33           FLOOD/FLASH FLOOD                   Flood
## 34            FLOOD/RAIN/WINDS                   Flood
## 35                    FLOODING                   Flood
## 36                         FOG               Dense Fog
## 37                FOREST FIRES                Wildfire
## 38                      FREEZE            Frost/Freeze
## 39                      Freeze            Frost/Freeze
## 40               FREEZING RAIN                   Sleet
## 41                       FROST            Frost/Freeze
## 42                FROST/FREEZE            Frost/Freeze
## 43                        HAIL                    Hail
## 44                   HAILSTORM                    Hail
## 45                 HARD FREEZE            Frost/Freeze
## 46                        HEAT                    Heat
## 47                   HEAT WAVE                    Heat
## 48                  HEAVY RAIN              Heavy Rain
## 49        Heavy Rain/High Surf              Heavy Rain
## 50   HEAVY RAIN/SEVERE WEATHER              Heavy Rain
## 51                 HEAVY RAINS              Heavy Rain
## 52                  HEAVY SNOW              Heavy Snow
## 53        HEAVY SURF/HIGH SURF               High Surf
## 54                   HIGH SURF               High Surf
## 55                   HIGH WIND               High Wind
## 56                  HIGH WINDS               High Wind
## 57             HIGH WINDS/COLD               High Wind
## 58                   HURRICANE     Hurricane (Typhoon)
## 59             HURRICANE EMILY     Hurricane (Typhoon)
## 60              HURRICANE ERIN     Hurricane (Typhoon)
## 61              HURRICANE OPAL     Hurricane (Typhoon)
## 62   HURRICANE OPAL/HIGH WINDS     Hurricane (Typhoon)
## 63           HURRICANE/TYPHOON     Hurricane (Typhoon)
## 64                         ICE               Ice Storm
## 65            ICE JAM FLOODING               Ice Storm
## 66                   ICE STORM               Ice Storm
## 67            LAKE-EFFECT SNOW        Lake Effect Snow
## 68                   LANDSLIDE             Debris Flow
## 69                   LIGHTNING               Lightning
## 70                 MAJOR FLOOD                   Flood
## 71                       OTHER                   Other
## 72                        RAIN              Heavy Rain
## 73                 RECORD COLD Extreme Cold/Wind Chill
## 74                 RIVER FLOOD                   Flood
## 75              River Flooding                   Flood
## 76              RIVER FLOODING                   Flood
## 77              River Flooding                   Flood
## 78         SEVERE THUNDERSTORM       Thunderstorm Wind
## 79   SEVERE THUNDERSTORM WINDS       Thunderstorm Wind
## 80        SEVERE THUNDERSTORMS       Thunderstorm Wind
## 81                  SMALL HAIL                    Hail
## 82                        SNOW              Heavy Snow
## 83                 STORM SURGE        Storm Surge/Tide
## 84            STORM SURGE/TIDE        Storm Surge/Tide
## 85                 STRONG WIND             Strong Wind
## 86                STRONG WINDS             Strong Wind
## 87                THUNDERSTORM       Thunderstorm Wind
## 88           THUNDERSTORM WIND       Thunderstorm Wind
## 89          THUNDERSTORM WINDS       Thunderstorm Wind
## 90                     TORNADO                 Tornado
## 91  TORNADOES, TSTM WIND, HAIL                 Tornado
## 92              TROPICAL STORM          Tropical Storm
## 93        TROPICAL STORM JERRY          Tropical Storm
## 94                   TSTM WIND       Thunderstorm Wind
## 95              TSTM WIND/HAIL       Thunderstorm Wind
## 96                     TSUNAMI                 Tsunami
## 97                     TYPHOON     Hurricane (Typhoon)
## 98           Unseasonable Cold         Cold/Wind Chill
## 99           UNSEASONABLY COLD         Cold/Wind Chill
## 100            UNSEASONAL RAIN              Heavy Rain
## 101                URBAN FLOOD                   Flood
## 102       URBAN/SML STREAM FLD                   Flood
## 103                 WATERSPOUT              Waterspout
## 104         WATERSPOUT/TORNADO              Waterspout
## 105                 WILD FIRES                Wildfire
## 106           WILD/FOREST FIRE                Wildfire
## 107                   WILDFIRE                Wildfire
## 108                  WILDFIRES                Wildfire
## 109                       WIND             Strong Wind
## 110                      WINDS             Strong Wind
## 111               WINTER STORM            Winter Storm
## 112    WINTER STORM HIGH WINDS            Winter Storm
## 113             WINTER WEATHER          Winter Weather
```

```r
# Merge summary table to official event types

Prop_Crop_Evtype <- merge(Prop_Crop_Evtype, Evtype_MapC, by = "EVTYPE")
dim(Prop_Crop_Evtype)
```

```
## [1] 113   4
```

```r
# Create Top 34 Most Harmful Events to Population Health Summary 

Prop_Crop_Evtype <- Prop_Crop_Evtype %>%
                        group_by(Off_Map)%>%
                        summarize(Psum = sum(Psum),Csum = sum(Csum))%>%
                        select(Off_Map,Psum,Csum)
Prop_Crop_Evtype$Psum <- Prop_Crop_Evtype$Psum / (10^6)
Prop_Crop_Evtype$Csum <- Prop_Crop_Evtype$Csum / (10^6)

# 34 event types in order to cover Top 30 for Property and Top 30 for Crop data 
dim(Prop_Crop_Evtype)
```

```
## [1] 34  3
```



## Results

A simple line plot of proportion of events by year shows the jump in data collection right around the time after the "Storm of the Century / The Blizzard" (March 1993). Events like Hurricane Andrew and The Blizzard might have been the triggers to bring about the revamp in the NOAA database (from 1992-1996).


```r
g <- ggplot(countev, aes(x = Year, y = prop))
g + geom_line() +
        xlab("Year") + ylab("%Proportion of Total Events") +
        ggtitle("% Number of Events by Year in NOAA Storm Database") +
        theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
        annotate("text", x=1993, y=0.022, label= "The Blizzard - March 1993")
```

![](PA2_Submission_files/figure-html/unnamed-chunk-9-1.png)<!-- -->


The following shows two main plots:

- First plot shows Top 30 Most Harmful Events - Population Health (Fatalities & Injuries)
- Second plot hows an exploratory analysis  of most harmful events in terms of economic damage (Property + Crops)


```r
g1 <- ggplot(Fat_Inj_Evtype, aes(reorder(Off_Map,-Fsum), Fsum)) +
        geom_bar(stat = "identity", fill = "black") + 
        ylab("# Fatalities") + xlab("") +
        theme(axis.text.x = element_text(angle = 90, hjust = 1)) 
        

g2 <- ggplot(Fat_Inj_Evtype, aes(reorder(Off_Map,-Isum), Isum)) +
        geom_bar(stat = "identity", fill = "orange") + 
        ylab("# Injuries") + xlab("") +
        theme(axis.text.x = element_text(angle = 90, hjust = 1))
grid.arrange(g1, g2, ncol=2, top = ("Top 30 Most Harmful Events - Population Health"), bottom = ("Event Type")) 
```

![](PA2_Submission_files/figure-html/unnamed-chunk-10-1.png)<!-- -->

```r
g3 <- ggplot(Prop_Crop_Evtype, aes(reorder(Off_Map,-Psum), Psum)) +
        geom_bar(stat = "identity", fill = "brown") + 
        ylab("# Property Damage (in Mill)") + xlab("") +
        theme(axis.text.x = element_text(angle = 90, hjust = 1)) 
        

g4 <- ggplot(Prop_Crop_Evtype, aes(reorder(Off_Map,-Csum), Csum)) +
        geom_bar(stat = "identity", fill = "green") + 
        ylab("$ Crop Damage (in Mill") + xlab("") +
        theme(axis.text.x = element_text(angle = 90, hjust = 1))
grid.arrange(g3, g4, ncol=2, top = ("Top 30 Most Harmful Events - Economic Damage"), bottom = ("Event Type")) 
```

![](PA2_Submission_files/figure-html/unnamed-chunk-10-2.png)<!-- -->

Top 5 most harmful events causing most fatalities are: 

- Tornado, Excessive Heat, Flash Flood, Heat (heat wave) and Lightning

Top 5 most harmful events causing most injuries are:

- Tornado, Thunderstorm Wind, Excessive Heat, Flood and Lightning

Top 5 most harmful events causing greatest property damage are:

- Flood, Hurricane, Tornado, Storm Surge/Tide, and Flash Flood 

Top 5 most harmful events causing greatest crop damage are:

- Drought, Flood, Hurricane, Ice Storm and Hail

Hope this helps!! Thank you for your time and effort looking through this report. Good luck!

Sai S Sampatkumar June 2017
