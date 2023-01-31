##3
library(rvest)
library(tidyverse)
proj_url <- 'https://ceqanet.opr.ca.gov/Project/2010102018'
proj_html <- proj_url %>% read_html() 

proj_html %>% html_nodes('td') %>% html_table()
