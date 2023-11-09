library(tidyverse)

# load in the cleaned data
load('data/all_processed.RData')

# these are the samples to loop through
samps = unique(ps_df$Study_ID)
samps = samps[1:5]

# loop through the samples
for (samp in samps){
    
    # Find this sample's four most-abundant families
    ps_this = filter(ps_df, Study_ID == samp)
    ps_top = (ps_df
              %>% filter(Study_ID == samp, Family != 'Other')
              %>% group_by(Family)
              %>% summarize(Total = sum(Abundance))
              %>% arrange(desc(Total))
              %>% head(n = 4))
    top_fams = ps_top$Family
    top_fams = paste('Families/', top_fams, '.Rmd', sep = '')
    
    # generate the Rmd text from the template and the sample
    rmd = readLines('Template.Rmd')
    for (i in 1:length(rmd)){
        rmd[i] = sub('REPLACEME', samp, rmd[i])
        rmd[i] = sub('FAM1', top_fams[1], rmd[i])
        rmd[i] = sub('FAM2', top_fams[2], rmd[i])
        rmd[i] = sub('FAM3', top_fams[3], rmd[i])
        rmd[i] = sub('FAM4', top_fams[4], rmd[i])
    }
	rmd_fn = paste(samp, '.Rmd', sep = '')
    writeLines(rmd, rmd_fn)
    rmarkdown::render(rmd_fn, encoding = 'UTF-8', 
                      knit_root_dir = './', clean =	TRUE,
                      output_dir = './Pdfs/')
}
