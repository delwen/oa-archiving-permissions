#Adapted from Maia Salholz-Hillel (https://github.com/maia-sh/reg-pub-link/blob/master/analysis/fig_flowchart-trials.R)

library(dplyr)
library(glue)

# Prepare labels
label_iv_all <- glue('IntoValue trials\n(DRKS and CT.gov)\n(n = {n_trials_iv})\nIV1 = {n_trials_iv1} & IV2 = {n_trials_iv2}')
label_iv_screened <- glue('Trials meeting IntoValue criteria\nwith new registry data\n(n = {n_trials_iv_interventional})')
label_trials_lead <- glue('IntoValue German UMC Lead Trials\n(n = {n_trials_lead})')
label_trials_deduped <- glue('Trials with duplicates removed\n(n = {n_trials_deduped})')

label_iv_screened_ex <- glue('Trials not meeting IntoValue criteria\nwith new registry data\n(n = {n_trials_iv_completion_date_ex + n_trials_iv_status_ex + n_trials_iv_interventional_ex})\nNot completed 2009-2017 (n = {n_trials_iv_completion_date_ex})\nNot included status (n = {n_trials_iv_status_ex})\nNot interventional (n = {n_trials_iv_interventional_ex})')
label_iv_lead_ex <- glue('No German UMC Lead\n(n = {n_trials_lead_ex})')
label_trials_dupes_ex <- glue('Duplicate trials\n(n = {n_trials_dupes_ex})')

# Prepare flowchart
flow_trials <- DiagrammeR::grViz("digraph trials {
# GRAPH
graph [layout = dot, rankdir = LR, splines = false]
node [shape = rectangle, width = 3, height = 1, fixedsize = true, penwidth = 1, fontname = Arial, fontsize = 12]
edge [penwidth = 1]
# INCLUSION SUBGRAPH
subgraph included {
# NODES INCLUSION
iv_all [label = '@@1']
iv_screened [label = '@@2']
trials_lead [label = '@@3']
trials_deduped [label = '@@4']
# NODES BLANK
node [label = '', width = 0.01, height = 0.01, style = invis]
rank = same
# EDGES INCLUSION
edge [minlen = 1]
iv_all -> iv_screened -> trials_lead -> trials_deduped
# EDGES BLANK
edge [dir = none, style = invis]
iv_all -> blank_1
iv_screened -> blank_2
trials_lead -> blank_3
trials_deduped -> blank_4
}
# EXCLUSION SUBGRAPH
subgraph excluded {
node [width = 2.4]
# NODES EXCLUSION
iv_screened_ex [label = '@@5'] [width = 3, height = 1.6]
iv_lead_ex [label = '@@6']
trials_dupes_ex [label = '@@7']
}
# EDGES EXCLUSION
blank_1 -> iv_screened_ex
blank_2 -> iv_lead_ex
blank_3 -> trials_dupes_ex
}
# LABELS
[1]: label_iv_all
[2]: label_iv_screened
[3]: label_trials_lead
[4]: label_trials_deduped
[5]: label_iv_screened_ex
[6]: label_iv_lead_ex
[7]: label_trials_dupes_ex
")

# Remove labels
rm(list = ls(pattern = "^label_"))


# Export PDF
flow_trials %>%
  DiagrammeRsvg::export_svg() %>%
  charToRaw() %>%
  rsvg::rsvg_pdf(here("figures", "flow-trials.pdf")
                 #width = 297.5,
                 #height = 463
  )
