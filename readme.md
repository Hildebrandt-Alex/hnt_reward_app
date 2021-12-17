---
title: "Readme"
output: html_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

## Get reward report for HNT mining

This shiny app is for reporting the daily HNT reward for a user defined time range.
Therefore you need a walletID/accountID of a given Helium Hotspot. 
The overview table can be used for the tax office to record daily profits with the respective exchange rate and to summarize them over a certain period of time. The report can be downloaded as a .tsv file and saved in e.g. Excel can be processed further. In this version, the period is available from January 1, 2020 to December 1, 2021. In addition to this very simple version, another one is under construction.