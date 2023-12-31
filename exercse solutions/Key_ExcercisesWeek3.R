##Key for R excercises week 3

########################################

library(tidyverse)
library(ggpubr)
library(wesanderson)
########################################

###
# 1.    Read in the LDWFBayAnchovy2007.csv and create a column that calculates the catch per unit effort (CPUE) for Bay anchovy within the dataframe.
###

#LDWFBayAnchovy2007 is on the workshop github. Download and save in targeted working directory

#Uploading file
fish_LA = read_csv("./data/LDWFBayAnchovy2007.csv")

#Creating new column for CPUE = Catch per unit effort (Catch/effort)
fish_LA = fish_LA |> 
  mutate(CPUE = num/seines)

###
# 2.    Create a dataframe or tibble that contains the basin names for the LDWFBayAnchovy2007.csv dataset (Barataria, Terrebonne, Ponchartrain, Vermilion-Teche, and Calcasieu) and the and abbreviation for each basin as a new column. 
###

#Version 1 - Manual entry
basins = tibble(basin = c("Barataria", "Calcasieu", "Pontchartrain", "Terrebonne", "Vermilion-Teche"),
                    basin_short = c("Bar", "Cal", "Pon", "Terr", "Ver"))

#Version 2 - Wrangling and using the original data with R base and tidyr functions
basins = tibble(basin = c(unique(fish_LA$basin)),
                basin_short = c(abbreviate(unique(fish_LA$basin))))

###
# 3.    Merge the dataframe/tibbles from exercises 1 and 2. 
###

fish_LA = fish_LA |> 
  left_join(basins, by ="basin")

# 4.    Plot the CPUE for each basin both over time and as a summary of the entire year using a different color for each basin. 

#Using tidyr
# fish_LA = fish_LA |> 
#   separate_wider_delim(date, "-", names = c("year", "month", "day"))
# 
# YRmean_fish = fish_LA |> 
#   group_by(basin_short, year) |> 
#   summarise(CPUE_mean = mean(CPUE, na.rm = TRUE)) 
# 
# fig_ex1 = ggplot(YRmean_fish, aes(year, CPUE_mean, color = basin_short))+
#   geom_point()+
#   geom_line()

#CPUE over time
CPUE_ts = ggplot(fish_LA, aes(x = date, y = num, color = basin_short))+
  geom_point()+
  geom_line()+
  scale_x_date(limits = c(lubridate::ymd('2007-01-01'), lubridate::ymd('2007-12-01')))+
  labs(x = 'Date', y = 'Bay anchovy CPUE')+
  theme_classic()+
  theme(axis.title = element_text(size = 14),
        axis.text = element_text(size = 12),
        legend.position = 'bottom',
        legend.title = element_blank())

YR_summary = ggplot(fish_LA, aes(x = basin, y = CPUE, fill = basin_short))+
  geom_boxplot()+
  labs(x = NULL, y = '# of seines', fill = "Basins")+
  theme_bw()

# plot combined
final_fig_ex2 = ggarrange(CPUE_ts, YR_summary,
          labels = c('a)','b)'),
          ncol = 1)
final_fig_ex2

#A good function to save figures for pubs
ggsave("final_fig_ex2.pdf", width = 7, height = 7, unit = "in", dpi = 300)
