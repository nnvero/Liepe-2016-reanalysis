import pandas as pd
from pathlib import Path

SPLICED_PEPTIDES_DATA = "./data/mylonas-et-al/supplementary6.xlsx"
BASE_PROTEOME_FASTA = "./data/proteome/uniprot/human.fasta"
OUTPUT_FASTA = "./data/proteome/library/proteome_with_liepe_peptides.fasta"

spliced = pd.read_excel(SPLICED_PEPTIDES_DATA, sheet_name=' GR-LCL Spliced')
non_spliced = pd.read_excel(SPLICED_PEPTIDES_DATA, sheet_name='GR-LCL non-spliced')

def row_to_fasta(row):
  return f">sp|SPLICE-{row['ID']};{row['Gene']};{row['Domain']}\n{row['pep']}"

fasta = "\n".join(spliced.apply(row_to_fasta, axis=1))
fasta += "\n" + "\n".join(non_spliced.apply(row_to_fasta, axis=1))

uniprot_fasta_content = ""

with open(BASE_PROTEOME_FASTA, "r") as f:
  uniprot_fasta_content = f.read()

Path(OUTPUT_FASTA).parent.mkdir(parents=True, exist_ok=True)

with open(OUTPUT_FASTA, "w") as f:
  f.write(uniprot_fasta_content)
  f.write(fasta)
