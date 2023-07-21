###Para primera corrida es necesario instalar las librerias requeridas
install.packages("plyr")
install.packages("stringi")
install.packages("foreign")
install.packages("rvest")
install.packages("dplyr")
install.packages("data.table")
install.packages("quanteda")

###Cargo librerias necesarias##
library(plyr)
library(stringi)
library(foreign)
library(rvest)
library(dplyr)
library(data.table)

#Seleccione la pagina que quiere descargar
link = "https://www.imdb.com/search/title/?year=2021&amp;title_type=feature"
page = read_html(link)

#CSS selectors of the HTML elements you want to scrape. You can use the Selector Gadget chrome extension for this process. 

name = page %>% html_nodes(".lister-item-header a") %>% html_text()
year = page %>% html_nodes(".text-muted.unbold") %>% html_text()
runtime = page %>% html_nodes(".runtime") %>% html_text()
genre = page %>% html_nodes(".genre") %>% html_text()
synopsis = page %>% html_nodes(".ratings-bar+ .text-muted") %>% html_text()
rating = page %>% html_nodes(".ratings-imdb-rating strong") %>% html_text()
votes = page %>% html_nodes(".sort-num_votes-visible span:nth-child(2)") %>% html_text()
movie_list =  data.frame(name, year, runtime, genre, synopsis, rating, votes,  stringsAsFactors = FALSE)
View(movie_list)
write.csv(movie_list, "Pelis2021.csv")


movie_links = page %>% html_nodes(".lister-item-header a") %>% html_attr("href") %>% paste("https://www.imdb.com", ., sep = "")

get_cast = function(movie_link) {
    movie_page = read_html(movie_link)
    movie_cast = movie_page %>% html_nodes(".primary_photo+ td a") %>% html_text() %>% paste(collapse = ",")
    return(movie_cast)
}

movie_list = data.frame()

for (page_result in seq(from = 1, to = 101, by = 50)){
    link = paste0("https://www.imdb.com/search/title/?title_type=feature&year=2020-01-01,2020-12-31&start=", page_result , "&ref_=adv_nxt")
    page = read_html(link)
    name = page %>% html_nodes(".lister-item-header a") %>% html_text()
    movie_links = page %>% html_nodes(".lister-item-header a") %>% html_attr("href") %>% paste("https://www.imdb.com", ., sep = "")
    year = page %>% html_nodes(".text-muted.unbold") %>% html_text()
    runtime = page %>% html_nodes(".runtime") %>% html_text()
    genre = page %>% html_nodes(".genre") %>% html_text()
    synopsis = page %>% html_nodes(".ratings-bar+ .text-muted") %>% html_text()
    rating = page %>% html_nodes(".ratings-imdb-rating strong") %>% html_text()
    votes = page %>% html_nodes(".sort-num_votes-visible span:nth-child(2)") %>% html_text()
    cast = sapply(movie_links, FUN = get_cast, USE.NAMES = FALSE)
    movie_list = rbind(movie_list, data.frame(name, year, runtime, genre, synopsis, rating, votes, cast, stringsAsFactors = FALSE))
    print(paste("Page : ", page_result))
}

write.csv(movie_list, "Feature Films(2020-01-01 and 2020-12-31).csv")