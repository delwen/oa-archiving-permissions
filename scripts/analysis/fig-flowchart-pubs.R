#Adapted from Maia Salholz-Hillel (https://github.com/maia-sh/reg-pub-link/blob/master/analysis/fig_flowchart-trials.R)

library(dplyr)
library(glue)
library(here)

# Prepare labels
label_pubs_all <- glue('IntoValue trial\npublications\n(n = {n_pubs_iv})')
label_pubs_doi <- glue('Trial publications\nwith a DOI\n(n = {n_pubs_doi})')
label_pubs_deduped <- glue('Unique trial publications\n(n = {n_pubs_deduped})')
label_pubs_resolved <- glue('Trial publications\nresolved in Unpaywall\n(n = {n_pubs_resolved})')
label_pubs_journal_article <- glue('Trial publications\nwith DOI to published version\n(n = {n_pubs_journal_article})')
label_pubs_2010_2020 <- glue('Trial publications\npublished between\n2010 - 2020\n(n = {n_pubs_2010_2020})')

label_pubs_doi_ex <- glue('Trial publications\nwithout a DOI\n(n = {n_pubs_doi_ex})')
label_pubs_deduped_ex <- glue('Duplicate publications\n(n = {n_pubs_deduped_ex})')
label_pubs_resolved_ex <- glue('Trial publications\nunresolved in Unpaywall\n(n = {n_pubs_resolved_ex})')
label_pubs_journal_article_ex <- glue('Trial publications\nwith DOI to preprint version\n(n = {n_pubs_journal_article_ex})')
label_pubs_2010_2020_ex <- glue('Trial publications\npublished before 2010\nor after 2020\n(n = {n_pubs_2010_2020_ex})')

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
pubs_deduped [label = '@@3']
pubs_resolved [label = '@@4']
pubs_journal_article [label = '@@5']
pubs_2010_2020 [label = '@@6']
# NODES BLANK
node [label = '', width = 0.01, height = 0.01, style = invis]
rank = same
# EDGES INCLUSION
edge [minlen = 1]
pubs_all -> pubs_doi -> pubs_deduped -> pubs_resolved -> pubs_journal_article -> pubs_2010_2020
# EDGES BLANK
edge [dir = none, style = invis]
pubs_all -> blank_1
pubs_doi -> blank_2
pubs_deduped -> blank_3
pubs_resolved -> blank_4
pubs_journal_article -> blank_5
pubs_2010_2020 -> blank_6
}
# EXCLUSION SUBGRAPH
subgraph excluded {
node [width = 2.4]
# NODES EXCLUSION
pubs_doi_ex [label = '@@7']
pubs_deduped_ex [label = '@@8']
pubs_resolved_ex [label = '@@9']
pubs_journal_article_ex [label = '@@10']
pubs_2010_2020_ex [label = '@@11']
}
# EDGES EXCLUSION
blank_1 -> pubs_doi_ex
blank_2 -> pubs_deduped_ex
blank_3 -> pubs_resolved_ex
blank_4 -> pubs_journal_article_ex
blank_5 -> pubs_2010_2020_ex
}
# LABELS
[1]: label_pubs_all
[2]: label_pubs_doi
[3]: label_pubs_deduped
[4]: label_pubs_resolved
[5]: label_pubs_journal_article
[6]: label_pubs_2010_2020
[7]: label_pubs_doi_ex
[8]: label_pubs_deduped_ex
[9]: label_pubs_resolved_ex
[10]: label_pubs_journal_article_ex
[11]: label_pubs_2010_2020_ex
")

# Remove labels
rm(list = ls(pattern = "^label_"))


# Export EPS
flow_pubs %>%
  DiagrammeRsvg::export_svg() %>%
  charToRaw() %>%
  rsvg::rsvg_eps(here("figures", "flow-pubs.eps")
  )
