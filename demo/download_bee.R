# https://github.com/rfordatascience/tidytuesday/blob/master/data/2022/2022-01-11/readme.md
bee_colonies <- read.csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2022/2022-01-11/colony.csv')
write.csv(bee_colonies, file = "demo/bee_colonies.csv")
