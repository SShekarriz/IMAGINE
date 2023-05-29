# Packages ---------------------
library(phyloseq)
library(AfterSl1p)
library(tidyverse)

# Imports ---------------------------

# Importing the dada2 files
seqtab.nochim <- read.csv("data/seqtab_nochim_transposed_IMG-HC_v34.csv", 
                          row.names = 1)
# Importing taxonomic assignment
taxa <- read.csv("data/taxa_IMG-HC_v34_silva138.csv", row.names = 1)
#import the data into phyloseq:
ps <- phyloseq(otu_table(seqtab.nochim, taxa_are_rows=TRUE),
               tax_table(as.matrix(taxa)))

# Mock mapfile
mapfile = data.frame(Study_ID= sample_names(ps),
           Status = sample(c('Healthy', 'UC'), 105, replace = TRUE))

row.names(mapfile) <- mapfile$Study_ID
sample_data(ps) <- mapfile

ps

# Clean the data ---------------

# Remove host sequences
ps = prop_tax_down(ps, indic = FALSE)
ps
ps = subset_taxa(ps, Kingdom %in% c('Bacteria','Archaea') &
                       !(Phylum %in% Kingdom) & 
                     (Family != 'Mitochondria'))
ps

# Take relative abundance before any abundance filtering
ps_rel = transform_sample_counts(ps, function(x) x/sum(x))
ps_rel

# Remove low-abundance taxa
keep = filter_taxa(ps, function(x) mean(x) > 10)
ps_rel_filt = prune_taxa(keep, ps_rel)
ps_filt = prune_taxa(keep, ps)

# Make the data frame ----------------

ps_df = make_phy_df(ps_rel_filt, rank = 'Genus', cutoff = 0.001,
                    indic = FALSE, prop = FALSE)
n = ceiling(n_distinct(ps_df$Family)/length(tax_colours))
fam_cols = rep(tax_colours, n)
fam_cols = c(fam_cols[1:(n_distinct(ps_df$Family)-1)],'grey69')
names(fam_cols) = rev(levels(ps_df$Family))

# Make the mean and range plots --------------------

ps_df = (ps_df
         %>% mutate(Dummy = 'All'))
mean_bar = plot_tax_bar(ps_df, 'Family', colours = fam_cols, 
                        sample = 'Dummy', means = TRUE,
                        legloc = 'none') +
    scale_x_discrete(labels = 'Everyone')
mean_bar

to_keep = c('ps_df', 'fam_cols', 'mean_bar')

# Do the ordination --------------

bray_dis_ps = phyloseq::distance(ps_rel_filt, method = 'bray')
bray_ord_ps = ordinate(ps_rel_filt, method = 'PCoA', distance = bray_dis_ps)
bray_df = plot_ordination(ps_rel_filt, bray_ord_ps, axes = 1:4, 
                          justDF = TRUE)

bray_plt = ggplot(bray_df, aes(Axis.1, Axis.2)) +
    geom_point(colour = 'grey80', alpha = 1, size = 2) +
    geom_point(colour = 'grey80', alpha = 0.5, size = 3) +
    theme_bw() +
    theme(axis.title = element_blank(),
          axis.text = element_blank(),
          axis.ticks = element_blank())
bray_plt

to_keep = c(to_keep, 'bray_df', 'bray_plt')

# Get the four most extreme samples

s1 = rownames(bray_df %>% filter(Axis.1 == min(Axis.1)))
s2 = rownames(bray_df %>% filter(Axis.1 == max(Axis.1)))
s3 = rownames(bray_df %>% filter(Axis.2 == min(Axis.2)))
s4 = rownames(bray_df %>% filter(Axis.2 == max(Axis.2)))
s1_bar = plot_tax_bar(filter(ps_df, Study_ID == s1), 'Family',
                       colours = fam_cols, sample = 'Study_ID') +
    theme_void() +
    theme(legend.position = 'none')

s2_bar = plot_tax_bar(filter(ps_df, Study_ID == s2), 'Family',
                       colours = fam_cols, sample = 'Study_ID') +
    theme_void() +
    theme(legend.position = 'none')
s3_bar = plot_tax_bar(filter(ps_df, Study_ID == s3), 'Family',
                       colours = fam_cols, sample = 'Study_ID') +
    theme_void() +
    theme(legend.position = 'none')
s4_bar = plot_tax_bar(filter(ps_df, Study_ID == s4), 'Family',
                       colours = fam_cols, sample = 'Study_ID') +
    theme_void() +
    theme(legend.position = 'none')

to_keep = c(to_keep,'s1_bar','s2_bar','s3_bar','s4_bar')

save(list = to_keep, file = 'data/all_processed.RData')
