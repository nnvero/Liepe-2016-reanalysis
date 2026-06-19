# Reanalysis of Liepe et al. (2016) | Proteasome-spliced peptides: abundance and MHC interaction analysis

This repository contains the project codebase and analysis for a reanalysis of the 2016 paper:  
> **"A large fraction of HLA class I ligands are proteasome-generated spliced peptides"** (Liepe et al., *Science*, 2016).

---

## Project Overview

In their original study, authors have found that large proportion of the HLA class I immunopeptidome consists of proteasome-spliced peptides - a phenomenon previously considered to be extremely rare. 

The goal of this project is to critically approach this finding. By utilizing modern mass spectrometry data processing pipelines, updated canonical databases (**UniProt**), and newly discovered **alternative protein/peptide databases**, we aim to investigate whether these "spliced" spectra can be better explained by non-spliced, canonical, or alternative variants that were not available in 2016.

---

## Statement of Contribution

All team members participated in the selection of the topic, shaping research question, and establishing project design. The specific division was distributed in the following way:

* **Oleh Kovalyshyn** – Construction of the custom database, MS data preprocessing, literature review.
* **Yevhenii Zasko** – MS data preprocessing, execution of the data processing pipeline, UniProt database searching.
* **Yehor Franchuk** – Searching alternative protein databases and analyzing the corresponding findings.
* **Veronika Nikolaieva** – Downstream data analysis, visualization, statistical analysis.
* **Yelyzaveta Fisun** – Peptide-HLA affinity analysis, visualization, statistical analysis.

---

## Responsible Use of AI Statement

During this project, our team utilized Large Language Models (specifically **ChatGPT**, **Claude AI**, and **Gemini AI**) as collaborative tools. AI assistance was restricted to the following responsible use cases:
* **Literature research:** Searching for relevant scientific papers, peer reviews to better understand the context and valid reanalysis approaches.
* **Documentation navigation and debudding:** Quick navigation through software and package documentations used in the project. Assisting with code debugging
* **Writing:** Grammar/style corrections.

---

## Acknowledgments

We would like to express our gratitude to:
* The **Genomics UA** team for organizing this course and providing us with the opportunity to learn proteomics from professionals.
* Our highly supportive mentor, **Yehor Horokhovskyi**, for his invaluable guidance, kind advice, and dedication to helping our team every step of the way (including joining our meetings late into the night!).


## Data

Download the dataset from [Dryad](https://datadryad.org/dataset/doi:10.5061/dryad.r984n)
and unzip it under [`data/`](data/)

the structure should look like
```
data/
    raw/
        C1R/*
        immunopeptidome/*
        lysate/*
        T2/*
    mzml/
        GR_LCL/*
    mylonas-et-al/supplementary6.xlsx
```
