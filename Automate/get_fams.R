tst = ps_df %>% filter(Family != 'Other') %>% group_by(Study_ID, Family) %>% summarize(Total = sum(Abundance))
head(tst)
n_distinct(tst$Study_ID)
n_distinct(tst$Family)
tst_wide = pivot_wider(tst, names_from = Study_ID, values_from = Total,
                       values_fill = 0)
tst_wide[1:10,1:10]

samps = colnames(tst_wide)[-1]
fams = c()

for(samp in samps){
    df = (tst_wide
          %>% select(Family, {{ samp }})
          %>% rename(Total = {{ samp }})
          %>% arrange(desc(Total))
          %>% head(n = 4))
    fams = unique(c(fams, as.character(df$Family)))
    fams
}
length(fams)
fams
