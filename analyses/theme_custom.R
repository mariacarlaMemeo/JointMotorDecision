## Save custom theme as a function ##
theme_custom <- function() {
  theme_bw() + # note ggplot2 theme is used as a basis
    theme(plot.title = element_text(face="bold", size=18, hjust = 0.5),
          axis.title.x = element_text(face="bold", size=14,vjust=0.1),
          axis.title.y = element_text(face="bold", size=14,vjust=2),
          axis.text.y = element_text(size=12),
          axis.text.x = element_text(size=12),
          panel.border = element_blank(),
          axis.line = element_line(color = 'black', linewidth=0.1),
          legend.title=element_blank(),
          legend.text = element_text(size=14),
          legend.position=c(0.2,0.85))
}

