# library
# https://www.codingfinance.com/post/2018-03-27-download-price/
library(tidyquant)
library(tidyverse)
library(glue)

# read file
composition <- read_csv('data/composicao_ibx_mensal.csv')

# get unique ticks
unq_ticks <- unique(unlist(composition[-1]))

# remove na
unq_ticks <- unq_ticks[!unq_ticks %in% NA]

# put '.SA' in ticks 
ticks <- map_chr(unq_ticks, ~glue::glue('{.x}.SA'))


# get data
extern_api <- function(x){
  
  getSymbols(x, src = 'yahoo',
             
             from='2010-12-01', to='2020-02-01', 
             
             periodicity='monthly')
  
}

safety_api <- possibly(extern_api, otherwise = NA_real_)

# apenas ticks reconhecidos  
accepted_ticks <- map_chr(ticks, safety_api)

# remove NA
accepted_ticks <- accepted_ticks[!accepted_ticks %in% NA]


# aplicando 
getSymbols(accepted_ticks, src = 'yahoo',
           
           from='2010-12-01', to='2020-02-01', 
           
           periodicity='monthly')

# extract prices
prices <- map(accepted_ticks, ~Ad(get(.x)))

prices <- reduce(prices, merge)  

colnames(prices) <- accepted_ticks
  
# extract volume

volume <- map(accepted_ticks, ~Vo(get(.x)))

volume <- reduce(volume, merge)

colnames(volume) <- accepted_ticks 


# extract data of ^BVSP

bvsp <- '^BVSP'

getSymbols(bvsp, src = 'yahoo',
           
           from='2010-12-01', to='2020-02-01', 
           
           periodicity='monthly')

df_bvsp <- map('BVSP', ~Ad(get(.x)))

df_bvsp <- reduce(df_bvsp, merge)  

# export results
"""
write.zoo(prices, file = 'data/prices.csv', sep = ',')
write.zoo(volume, file = 'data/volume.csv', sep = ',')
write.zoo(df_bvsp, file = 'data/ibov.csv', sep = ',')
"""
