#' """ Workshop 8: Community data: vegan and multivariate methods
#'     @author: BSC 6926 B52
#'     date: 11/7/2023"""

library(tidyverse)

## Community Data
#Community data can vary in format, but typically involves abundance, biomass, or CPUE data for multiple species collected in each sample. Data can be stored in wide (species ID for each column) or long format. The `vegan` package can be useful for calculating diversity metrics. `vegan` calculates metrics from a community matrix (long format).
# data in wide format
marsh_w = read_csv('data/Calcasieu.csv') |> 
  mutate(site = as.character(site),
         month = month(date)) 

marsh_w

### `vegan` diversity functions
# There are useful functions in `vegan` that can be used to calculate diversity metrics.
# 
# `specnumber()` calculates species richness. `diversity()` can calculate Shannon, Simpson, and inverse Simpson metrics.

library(vegan)

marsh_div = marsh_w |> 
  mutate(richness = specnumber(across(`Speckled Madtom`:`Smooth Puffer`)),
         H = diversity(across(`Speckled Madtom`:`Smooth Puffer`)),
         simp = diversity(across(`Speckled Madtom`:`Smooth Puffer`), "simpson"),
         invsimp = diversity(across(`Speckled Madtom`:`Smooth Puffer`),"inv")) 

#average
average_div = marsh_div |> 
  group_by(month) |> 
  summarize(across(richness:invsimp, list(mean = mean, sd = sd)))

average_div

ggplot(average_div, aes(month, richness_mean))+
  geom_point(size = 2)+
  geom_line( linewidth = 1)+
  labs(x = 'Month', y = 'Species richness')+
  theme_bw()

## Diversity partitioning (From Stevens 2010 - A primer of ecology with R)

# We frequently refer to biodiversity (i.e., richness, Simpson’s, and Shannon diversity) at different spatial scales as $\alpha$, $\beta$, and $\gamma$ diversity.\
# 
# Alpha diversity, $\alpha$, is the diversity of a point location or of a single sample.\
# Beta diversity, $\beta$, is the diversity due to multiple localities and can be used to describe differences in species composition among sites.\
# Gamma diversity, $\gamma$, is the diversity of a region, or at least the diversity of all the species in a set of samples collected over a large area (with large extent relative to a single sample).
# 
# Diversity across spatial scales can be further be partitioned in one of two ways, either using additive or multiplicative partitioning.\

### Additive partitioning
# _Additive partitioning_ is 
# $$\overline{\alpha} + \beta = \gamma$$
#   where $\alpha$ is the average diversity of samples, $\gamma$ is the diversity of pooled samples and $\beta$ is found  as 
# $$\beta = \gamma - \overline{\alpha}$$
#   We can think of $\beta$ as the average number of species not found in a sample, but which we know to be in the region. Additive partitioning allows direct comparison of average richness among samples at any hierarchical level of organization because all three measures of diversity $\alpha$, $\beta$, and $\gamma$ are expressed in the same units. This makes it analogous to partitioning variance in ANOVA. This is not the case for multiplicative partitioning diversity.

# gamma diversity
# convert to long format for plotting
marsh_l = marsh_w |> 
  pivot_longer(cols = 4:62, 
               names_to = "Species", 
               values_to = "Count") 

marsh_l

gammaDiv = length(unique(marsh_l$Species))

# calculate beta diversity
betaDiv = marsh_div |> 
  group_by(month) |> 
  summarise(alpha = mean(richness, na.rm = TRUE),
            gamma = gammaDiv,
            beta_a = gamma - alpha)

# plot 
library(ggpubr)

a = ggplot(betaDiv, aes(month, alpha))+
  geom_point()+
  geom_line()+
  scale_y_continuous(limits = c(0,60))+
  labs(x = 'month', y = expression(alpha ~ 'diversity'))+
  theme_bw()

b = ggplot(betaDiv, aes(month, beta_a))+
  geom_point()+
  geom_line()+
  scale_y_continuous(limits = c(0,60))+
  labs(x = 'month', y = expression(beta ~ 'diversity'))+
  theme_bw()

ggarrange(a,b,nrow =1, common.legend = T,align = 'h')

### Multiplicative partitioning
# _Multiplicative partitioning_ is 
# $$\overline{\alpha} \beta = \gamma$$ and 
# 
# $$\beta = \gamma/\overline{\alpha}$$
#   where $\beta$ is a conversion factor that describes the relative change in species composition among samples. Sometimes this type of $\beta$ diversity is thought of as the number of different community types in a set of samples. However, use this interpretation with great caution, as $\beta$ diversity depends completely on the sizes or extent of the samples used for $\alpha$ diversity.

betaDiv = betaDiv |> 
  mutate(beta_m = gamma/alpha)


b = ggplot(betaDiv, aes(month, beta_a))+
  geom_point()+
  geom_line()+
  scale_y_continuous(limits = c(0,60))+
  labs(x = 'month', y = expression('Additive'~ beta ~ 'diversity'))+
  theme_bw()

m = ggplot(betaDiv, aes(month, beta_m))+
  geom_point()+
  geom_line()+
  scale_y_continuous(limits = c(0,60))+
  labs(x = 'month', y = expression('Multiplicative'~beta ~ 'diversity'))+
  theme_bw()

ggarrange(b,m,nrow =1, common.legend = T,align = 'h')

## Species composition/Community structure
# Instead of distilling community data into metrics, comparisons can be made doing with the multivariate method. This is commonly done with distance or dissimilarity, and represent how similar communities are.

# filter to 2 species in for visualization
marsh_spp = marsh_w |> 
  group_by(site) |> 
  summarise(across(c(`Gulf Menhaden`, `White Shrimp`), mean)) 

ggplot(marsh_spp, aes(`Gulf Menhaden`, `White Shrimp`, color = site)) +
  geom_point(size = 4)+
  theme_bw()


### Euclidean distance
# One way to measure the distance between two points is to use euclidean distance, which is the straight line distance between two points. Euclidean distance between two points $d(p,q)$ can be measured using the following formula
# $$d(p,q) = \sqrt{\sum_{i = 1}^{n} (p_i - q_i)^2}$$
#   
#   Note that this is not great for community data.

#Example - Euclidean distance between site 15 and site 16

gm_diff = marsh_spp$`Gulf Menhaden`[1] - marsh_spp$`Gulf Menhaden`[2] #Atya abundance pool 0 - pool 13
ws_diff = marsh_spp$`White Shrimp`[1] - marsh_spp$`White Shrimp`[2] #MAC abundance pool 0 - pool 13

sqrt(gm_diff^2+ws_diff^2)

### Bray-Curtis 
# A common distance method for community data is Bray-Curtis. 
# This is the difference in species abundance between two sites divided by the total abundance at each site. 
# Interpret as the proportion of all individuals that would remain unpaired - percentage of dissimilarity. Reflects changes in composition and changes in relative. This can be calculated with the `vegan` package. 

#First, lets create a community species matrix for average at each site

marsh_comm = marsh_w |> 
  group_by(site) |> 
  summarise(across(`Speckled Madtom`:`Smooth Puffer`, mean)) |> 
  column_to_rownames(var = "site")

# converts to dataframe
marsh_comm 

euc_dist = vegdist(marsh_comm, method = "euclidean")
euc_dist

bray_dist = vegdist(marsh_comm, method = "bray")
bray_dist

### Jaccard
# Another common way to analyze community data is with presence absence data. This is best compared with Jaccard dissimilarity. 
# Represents the proportion of unshared species. Frequently used to interpret turnover. 
# To some extent, the average Jaccard dissimilarity is a measure of beta diversity.

jac_dist = vegdist(marsh_comm, method = "jaccard")
jac_dist

mean(jac_dist)

### Plot distance in ordination space
# Ordination - represent data along a reduced number of orthogonal axis. 
# Or, show us patterns of relationship between samples in the high dimensional space in way smaller number of dimension (2 or 3, or more depending on complexity). 
# Different techniques, which use will depend on the research question or objectives e.g., Principal component analysis, Correspondence Analysis, Pricinpal Coordinate Analysis, and MDS.
# 
# non-metric MDS, most commonly used for data exploration and illustrate patterns. Technique that maximize the rank correlation between dissimilarity matrix and n dimensions space
# through an iterative process.

marsh.nmds.bc = metaMDS(marsh_comm, distance = "bray", k = 2, try = 100)
marsh.nmds.ec = metaMDS(marsh_comm, distance = "euclidean", k = 2, try = 100)
marsh.nmds.jc = metaMDS(marsh_comm, distance = "jaccard", k = 2, try = 100)

plot(marsh.nmds.bc, display = "sites", type = "text")

# The output is a list, so need to extract data to plot in ggplot

nmds_output = bind_rows(bc = data.frame(marsh.nmds.bc[["points"]]),
                        ec = data.frame(marsh.nmds.ec[["points"]]),
                        jc = data.frame(marsh.nmds.jc[["points"]])) |> 
  mutate(site = rep(unique(marsh_spp$site), times = 3),
         Dissimilarity = rep(c("Bray", "Euclidean", "Jaccard"),
                             each = length(unique(site))))

ggplot(nmds_output, aes(MDS1, MDS2, color = as.factor(site)))+
  geom_point(size = 2)+ 
  facet_wrap(~Dissimilarity)+
  labs(color = 'site')+
  theme_bw()

## Diversity partitioning 
# Analysis of species replacement (turnover) and richness differences (or nestedness) based on Podani or Baselga Family Indices. From Chapter 8 - Numerical Ecology with R


library(adespatial)

beta.div.comp(marsh_comm, coef = "BJ")

marsh_spp.2 = marsh_l |>
  mutate(PA = if_else(Count > 0, 1, 0)) |> 
  group_by(site, Species) |> 
  summarise(mean_count = mean(Count, na.rm = TRUE),
            mean_PA = mean(PA, na.rm = TRUE)) 


# Let's explore how presence/absence and counts varies between species and pools

PA_dist = ggplot(marsh_spp.2, aes(x = Species, y = site, fill = mean_PA))+
  labs(y = 'site')+
  geom_raster()+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))

Co_dist = ggplot(marsh_spp.2, aes(x = Species, y = site, fill = mean_count))+
  labs(y = 'site')+
  geom_raster()+ 
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))

ggarrange(PA_dist, Co_dist,
          nrow = 2, align = 'v')

# ## Exercises
# For these exercises use the [LDWF Pontchartrain seine sampling dataset](https://raw.githubusercontent.com/PCB5423/BSC6926_workshopScripts/master/data/Calcasieu.csv). This dataset is the abundance for each species (in wide format) for 6 sites over 1 date.
# 
# 1. Using the Pontchartrain dataset calculate the mean and SD for species richness, Shannon, Simpson, and inverse Simpson for each sampling site.
# 
# 2. Plot the dominance (Whittiker) and K-dominance curves for each site.
# 
# 3. Plot the $\alpha$, $\beta$, and $\gamma$ diversity for each site for each sampling date in 2007. Use either additive or multiplicative $\beta$ diversity. Plot diversity over time. 
# 
# 4. Plot the Bray-Curtis and Jaccard dissimilarity for each site. 