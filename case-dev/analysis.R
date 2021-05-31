#library
library(tidyquant)
library(tidyverse)
library(glue)

#function definition
get_returns <- function(x, type = 'arithmetic',  period = 'monthly'){
  
  periodReturn(get(x)[, glue('{x}.Adjusted')], period = period, subset=NULL, type=type, leading = TRUE)
  
}

# volume
volume <- read_csv('data/volume.csv')

?read_csv
# percent returns 
pct_returns <- map(accepted_ticks, ~get_returns(.x))

# log returns
log_returns <- map(accepted_ticks, ~get_returns(.x, 'log'))


map(accepted_ticks, ~get_returns(.x, period = 'yearly'))

# 10 large volume on month
#apply(volume[,-1], 1, max, na.rm = TRUE)

#do.call(pmax, c(volume[,-1], list(na.rm=TRUE)))

#as_tibble(cbind(nms = names(volume), t(volume)))
