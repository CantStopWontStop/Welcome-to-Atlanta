library(tidyverse)
library(rvest)

getwd()
# Reading in url of for ATL rappers wiki and storing it a rappersSite
url1 <- 'https://en.wikipedia.org/wiki/List_of_hip_hop_musicians_from_Atlanta'
rappersSite <- read_html(url1)

# Selecting only the names of the rappers using the '.column-width a' selector, changing it to text, and turning it into a list
rappersList <- rappersSite %>%
  html_nodes(".column-width a") %>%
  html_text()
rappersList <- as.data.frame(unlist(rappersList))
names(rappersList) <- "Artist"

class(rappersList)

# Importing dataset of top artists/songs from 2016-Now
ListDec2016 <- read_csv("datasets/ListDec2016.csv", skip = 1)
ListJul2017 <- read_csv("datasets/ListJul2017.csv", skip = 1)
ListOct2018 <- read_csv("datasets/ListOct2018.csv", skip = 1)


# Adding the 3 data frames together, one after the other, and only keeping the unique values/removing duplicates
List16to18 <- bind_rows(ListDec2016, ListJul2017, ListOct2018)
List16to18 <- List16to18 %>% 
  select(Artist) %>%
  unique()


# Reading in url of for rap legends and storing it a rappersSite
url2 <- 'https://www.ranker.com/crowdranked-list/best-_90s-rappers'
rappers90s <- read_html(url2)

url3 <- 'https://www.ranker.com/list/best-_00s-rappers/whatevayoulike'
rappers00s <- read_html(url3)

# Selecting only the names of the rappers using the '.column-width a' selector andchanging it to text
rappers90s <- rappers90s %>%
  html_nodes(".listItem__title--link") %>%
  html_text()

# Unlisting data, turning it into a data frame, and naming the sole column
rappers90s <- as.data.frame(unlist(rappers90s), colnames="Artist")
names(rappers90s) <- "Artist"


# Selecting only the names of the rappers using the '.column-width a' selector, changing it to text, and turning it into a data frame
rappers00s <- rappers00s %>%
  html_nodes(".listItem__title--link") %>%
  html_text()

# Unlisting data, turning it into a data frame, and naming the sole column
rappers00s <- as.data.frame(unlist(rappers00s))
names(rappers00s) <- "Artist"

# Adding the 2 data frames together, one after the other, and only keeping the unique values/removing duplicates
rapLegends <- bind_rows(rappers00s, rappers90s)
rapLegends <- rapLegends %>%
  select(Artist) %>%
  unique()

rapLegendsFixed <- str_replace(rapLegends$Artist, "Yung Jeezy", "Young Jeezy")
rapLegendsFixed <- str_replace(rapLegends$Artist, "OutKast", "Outkast")
rapLegendsFixed <- str_replace(rapLegends$Artist, "André 3000", "Andre 3000")

rapLegends <- as.data.frame(unlist(rapLegendsFixed))
names(rapLegends) <- "Artist"

# Created a dataframe with only the rappers from the Atlanta list that were also rapLegends
atlRapLegends <- semi_join(rappersList, rapLegends)

# Created a dataframe with only the rappers from the Atlanta list that were also hot from 2016-2018
atlNewSchool <- semi_join(rappersList, List16to18)

View(rapLegends)
View(atlNewSchool)
View(atlRapLegends)

# Combined the atlRapLegends and atlNewSchool dataframes  
atlRappers <- rbind(atlNewSchool, atlRapLegends)
View(atlRappers)

# Created a csv with the list of atlRappers
write_csv(atlRappers, "/Users/soried/projects/atlRap/datasets/atlRappers.csv")