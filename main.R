
library(scholar)
library(tidyverse)

myId <- 'OjKZg9AAAAAJ'

all_publications <- get_publications(myId)

cit <- get_citation_history(myId) %>% 
  mutate(year = factor(year),
         cum_cites = cumsum(cites)) 

# calculate h-index
hIndex <- as.data.frame(table(all_publications$cites)) %>% 
  arrange(desc(Var1)) %>% 
  mutate(cumFreq = cumsum(Freq), 
         Var1=parse_number(as.character(Var1))) %>%
  filter(cumFreq <= Var1) %>% 
  pull(cumFreq) %>% 
  tail(1)

message("downloaded data")

citPlot <- ggplot(cit,aes(x=year,y=cites))+
  geom_bar(stat='identity',colour="#009bc3",fill="#009bc3")+
  theme_minimal() +
  theme(plot.subtitle=element_text(size=11, color="#009bc3"),
        plot.caption=element_text(size=10, color="gray"),
        plot.background = element_rect(fill = "white",colour = "white")) + 
  labs(x = "",
       y = 'Google Scholar citations per year',
       subtitle = paste0("Total citations = ",sum(cit$cites),"\n h-Index = ", hIndex),
       caption = paste("Updated", format(Sys.time(), "%d %b %Y")))


# png(paste0('figure/scholar_citations_',myId,'.png'),width=1200,height=600,res=150) 
# citPlot
# dev.off()

file.remove(paste0('figure/scholar_citations_',myId,'.png'))

ggsave(citPlot, filename = paste0('figure/scholar_citations_',myId,'.png'),
       width = 1200, height = 600, units = "px",dpi = 150)

message("updated plot")
