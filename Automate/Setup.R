library(phyloseq)
library(tidyverse)

load('./data/clean_dat.RData')
dat_full_o

# Trim low-read samples
dat_trim_o = prune_samples(sample_sums(dat_full_o) >= 5000, dat_full_o)
dat_trim_o

# Glom to family
dat_fam = tax_glom(dat_trim_o, 'Family')
dat_fam

fam_df = psmelt(dat_fam)
dim(fam_df)
head(fam_df)

tmp = (fam_df
       %>% select(OTU, Sample, Abundance, Family))
head(tmp)
samps = unique(fam_df$Sample)

fams = c()
for (samp in samps){
    df = (fam_df
          %>% filter(Sample == samp)
          %>% arrange(desc(Abundance))
          %>% head(n = 4))
    fams = unique(c(fams, as.character(df$Family)))
}
length(fams)
sort(fams)
for (fam in fams){
    fam1 = str_replace_all(fam, fixed('['), '')
    fam1 = str_replace_all(fam1, fixed(']'), '')
    fam1 = str_replace_all(fam1, fixed(' '), '_')
    fam1
    if (file.exists(paste('./Families/',fam1,'.Rmd', sep = ''))){
        next
    }
    file.create(paste('./Families/New/', fam1, '.Rmd', sep = ''))
}
