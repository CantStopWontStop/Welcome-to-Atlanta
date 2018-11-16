library(tidyverse)

library(readxl)
library(lubridate)

install.packages("openxlsx")
library(openxlsx)
library(forcats)
# Reads excel file into R by using it's path, selects the sheet "Discography", uses the first row as column names, and stores it into atlRappers
atlRappers <- read_excel("datasets/atlRappers.xlsx", sheet = "Discography", col_names = TRUE)
View(atlRappers)



# Takes atlRappers, converts the excel date/number format to a YYYY-MM-DD format, rearranges the columns (starting with Artist, Title, ReleaseDates, Certification, then everything else), and deletes the ReleaseDate column
atlRappers <- atlRappers %>% 
  mutate(ReleaseDates = convertToDate(ReleaseDate, origin = "1900-01-01")) %>%
  select(Artist, Title, ReleaseDates, Certification, everything()) %>%
  mutate(ReleaseDate = NULL)

# Filters out rows where certification is NA
atlBestSellers <- atlRappers %>%
  filter(!is.na(Certification))

# Silver = .1
# Gold = .5
# Platinum = 1
# 2x Platinum = 2
# 3x Platinum = 3
# 4x Platinum = 4
# 5x Platinum = 5
# 6x Platinum = 6
# 7x Platinum = 7
# 8x Platinum = 8
# 9x Platinum = 9
# Diamond = 10


# Added a new column that gives a numerical value to certifications
atlBestSellers1 <- atlBestSellers %>%
  mutate(CertificationNum = case_when(
  Certification == "Silver" ~ .1,
  Certification == "Gold" ~ .5,
  Certification == "Platinum" ~ 1,
  Certification == "Two Platinum" ~ 2,
  Certification == "Three Platinum" ~ 3,
  Certification == "Four Platinum" ~ 4,
  Certification == "Five Platinum" ~ 5,
  Certification == "Six Platinum " ~ 6,
  Certification == "Seven Platinum" ~ 7,
  Certification == "Eight Platinum" ~ 8,
  Certification == "Nine Platinum" ~ 9,
  Certification == "Diamond" ~ 10)
  )

View(atlBestSellers1)

# Grouped artists together and summed there certifications
atlBestSellersGrouped <- atlBestSellers1 %>%
  group_by(Artist) %>%
  summarise(TotalSales = sum(CertificationNum)) %>%
  arrange(desc(TotalSales))


atlRappersInfo <- read_excel("datasets/atlRappers.xlsx", sheet = "atlRappers", col_names = TRUE)
?left_join()

atlBestSellersGrouped <- left_join(atlBestSellersGrouped, atlRappersInfo, by = "Artist")
ggplot(atlBestSellersGrouped, aes(Artist, TotalSales)) + geom_point()

ggplot(atlBestSellersGrouped, aes(Artist, TotalSales)) + geom_col()

bind_cols(atlBestSellers1, atlRappersInfo)

write_csv(atlBestSellers1, "/Users/soried/projects/atlRap/datasets/atlCertifications.csv")
