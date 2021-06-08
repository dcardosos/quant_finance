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
ticks <- map_chr(unq_ticks, ~glue::glue('{.x}.SAO'))


# get data
extern_api <- function(x){
  
  getSymbols(x, src = 'av',
             
             from = as.Date('2010-12-01'), 
             
             to = as.Date('2020-02-01'),
             
             api.key = 'WKILRJ27Z51OABEO',
             
             periodicity='monthly')
  
}

safety_api <- possibly(extern_api, otherwise = NA_real_)

"accepted_ticks <- map_chr(ticks, safety_api)" ## o problema dessa abordagem é não ter o contador


# função que insere o contador para pegar os dados
# get_av_disponible_ticks <- function(ticks_names){
#   
#   count = 0
#   ac = c()
#   
#   for (t in ticks_names) {
#     
#     count <- count + 1
#     
#     if (count %% 5 == 0) {
#       
#       Sys.sleep(65)
#       
#     }
#     
#     ac <- c(ac, safety_api(t))
#   }
# 
#   ac
# }

count = 0
accepted_ticks = c()

for (t in ticks) {
  
  count <- count + 1
  
  if (count %% 5 == 0) {
    
    Sys.sleep(65)
    
  }
  
  accepted_ticks <- c(ac, safety_api(t))
}

# apenas ticks reconhecidos  
accepted_ticks <- get_av_disponible_ticks(ticks)

# saving
file <- file('data/ticks_alpha_vantage.txt')
writeLines(ac, file)    
close(file)


# remove NA
accepted_ticks <- accepted_ticks[!accepted_ticks %in% NA]

# aplicando 
get_av_stock_data <- function(ticks_names){
  
  count = 0
  ac = c()
  
  for (t in ticks_names) {
    
    count <- count + 1
    
    if (count %% 5 == 0) {
      
      Sys.sleep(65)
      
    }
    
   safety_api(t)
  }
}


# getSymbols(accepted_ticks, src = 'av',
#            
#            from='2010-12-01', to='2020-02-01', 
#            
#            api.key = 'WKILRJ27Z51OABEO',
#         
#            periodicity='monthly')



# extract prices
prices <- map(accepted_ticks, ~Ad(get(.x)))

prices <- reduce(prices, merge)  

colnames(prices) <- accepted_ticks
  
# extract volume
volume <- map(accepted_ticks, ~Vo(get(.x)))

volume <- reduce(volume, merge)

colnames(volume) <- accepted_ticks 


# extract data of ^BVSP
getSymbols('^BVSP', src = 'av',
           
           from='2010-12-01', to='2020-02-01', 
           
           api.key = 'WKILRJ27Z51OABEO',
           
           periodicity='monthly')

df_bvsp <- map('BVSP', ~Ad(get(.x)))

df_bvsp <- reduce(df_bvsp, merge)  

# export results
write.zoo(prices, file = 'data/prices.csv', sep = ',')
write.zoo(volume, file = 'data/volume.csv', sep = ',')
write.zoo(df_bvsp, file = 'data/ibov.csv', sep = ',')

