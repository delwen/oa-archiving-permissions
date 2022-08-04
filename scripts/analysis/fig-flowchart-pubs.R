#Adapted from Maia Salholz-Hillel (https://github.com/maia-sh/reg-pub-link/blob/master/analysis/fig_flowchart-trials.R)

library(dplyr)
library(glue)
library(here)

# Prepare labels
label_pubs_all <- glue('IntoValue trial\npublications\n(n = {n_pubs_iv})')
label_pubs_doi <- glue('Trial publications\nwith a DOI\n(n = {n_pubs_doi})')
label_pubs_resolved <- glue('Trial publications\nresolved in Unpaywall\n(n = {n_pubs_resolved})')
label_pubs_2010_2020 <- glue('Trial publications\npublished between\n2010 - 2020\n(n = {n_pubs_2010_2020})')
label_pubs_deduped <- glue('Unique trial publications\n(n = {n_pubs_deduped})')

label_pubs_doi_ex <- glue('Trial publications\nwithout a DOI\n(n = {n_pubs_doi_ex})')
label_pubs_resolved_ex <- glue('Trial publications\nunresolved in Unpaywall\n(n = {n_pubs_resolved_ex})')
label_pubs_2010_2020_ex <- glue('Trial publications\npublished before 2010\nor after 2020\n(n = {n_pubs_2010_2020_ex})')
label_pubs_deduped_ex <- glue('Duplicate publications\n(n = {n_pubs_deduped_ex})')

# Prepare flowchart
flow_pubs <- DiagrammeR::grViz("digraph trials {
# GRAPH
graph [layout = dot, rankdir = LR, splines = false]
node [shape = rectangle, width = 3, height = 1, fixedsize = true, penwidth = 1, fontname = Arial, fontsize = 12]
edge [penwidth = 1]
# INCLUSION SUBGRAPH
subgraph included {
# NODES INCLUSION
pubs_all [label = '@@1']
pubs_doi [label = '@@2']
pubs_resolved [label = '@@3']
pubs_2010_2020 [label = '@@4']
pubs_deduped [label = '@@5']
# NODES BLANK
node [label = '', width = 0.01, height = 0.01, style = invis]
rank = same
# EDGES INCLUSION
edge [minlen = 1]
pubs_all -> pubs_doi -> pubs_resolved -> pubs_2010_2020 -> pubs_deduped
# EDGES BLANK
edge [dir = none, style = invis]
pubs_all -> blank_1
pubs_doi -> blank_2
pubs_resolved -> blank_3
pubs_2010_2020 -> blank_4
pubs_deduped -> blank_5
}
# EXCLUSION SUBGRAPH
subgraph excluded {
node [width = 2.4]
# NODES EXCLUSION
pubs_doi_ex [label = '@@6']
pubs_resolved_ex [label = '@@7']
pubs_2010_2020_ex [label = '@@8']
pubs_deduped_ex [label = '@@9']
}
# EDGES EXCLUSION
blank_1 -> pubs_doi_ex
blank_2 -> pubs_resolved_ex
blank_3 -> pubs_2010_2020_ex
blank_4 -> pubs_deduped_ex
}
# LABELS
[1]: label_pubs_all
[2]: label_pubs_doi
[3]: label_pubs_resolved
[4]: label_pubs_2010_2020
[5]: label_pubs_deduped
[6]: label_pubs_doi_ex
[7]: label_pubs_resolved_ex
[8]: label_pubs_2010_2020_ex
[9]: label_pubs_deduped_ex
")

# Remove labels
rm(list = ls(pattern = "^label_"))


# Export PDF
flow_pubs %>%
  DiagrammeRsvg::export_svg() %>%
  charToRaw() %>%
  rsvg::rsvg_pdf(here("figures", "flow-pubs.pdf")
                 #width = 297.5,
                 #height = 463
  )
