import pandas as pd
import os

# --- 1. PATH CONFIGURATION ---
input_file = r"C:\docs\proteomics_project\psm_filtered_classified.tsv"
smprot_fasta = r"C:\docs\proteomics_project\smprot_analysis\SmProt2_human_Ribo.fa"
output_all = r"C:\docs\proteomics_project\smprot_analysis\spliced_all_results.tsv"
output_hits_only = r"C:\docs\proteomics_project\smprot_analysis\smprot_positive_hits_detailed.tsv"

print("Step 1: Loading and filtering the input TSV file...")

# Load the file using tab separation
df = pd.read_csv(input_file, sep='\t')

# Target classes of interest (Corrected spelling)
target_classes = ["Spliced_only", "Spliced_with_LIEPE-SPLICED_alternative"]

# Filter rows based on the Class column
filtered_df = df[df['Class'].isin(target_classes)].copy()
unique_peptides = filtered_df['Peptide'].dropna().unique()

print(f"-> Found spectra matching target classes: {len(filtered_df)} (Expected: 557)")
print(f"-> Total unique peptides to search: {len(unique_peptides)}")

print("\nStep 2: Loading and indexing the SmProt database...")
smprot_db = {}
smprot_descriptions = {}

with open(smprot_fasta, "r") as f:
    current_id = None
    current_seq = []
    for line in f:
        line = line.strip()
        if line.startswith(">"):
            if current_id:
                smprot_db[current_id] = "".join(current_seq)
            
            full_header = line[1:]
            current_id = full_header.split()[0]  # Extracts clean ID (e.g., SM_ID...)
            smprot_descriptions[current_id] = full_header  # Stores full FASTA header metadata
            current_seq = []
        else:
            current_seq.append(line)
    if current_id:
        smprot_db[current_id] = "".join(current_seq)

print(f"-> Successfully loaded {len(smprot_db)} sequences from SmProt.")

print("\nStep 3: Running exact string match against SmProt...")
peptide_to_hits = {}

for pep in unique_peptides:
    hits = []
    for sm_id, sm_seq in smprot_db.items():
        if pep in sm_seq:  # Substring match check
            hits.append(sm_id)
    
    if hits:
        peptide_to_hits[pep] = "; ".join(hits)
    else:
        peptide_to_hits[pep] = "No Hit"

# Map the results back to the filtered dataframe
filtered_df['SmProt_Hits'] = filtered_df['Peptide'].map(peptide_to_hits)
filtered_df.to_csv(output_all, sep='\t', index=False)

print("\nStep 4: Extracting detailed reference data for positive hits...")

# Create a clean dataframe containing ONLY successful hits
positive_hits_df = filtered_df[filtered_df['SmProt_Hits'] != "No Hit"].copy()

if not positive_hits_df.empty:
    # Function to extract detailed information from SmProt mapping
    def get_details(hit_string):
        first_hit = hit_string.split(";")[0].strip()
        desc = smprot_descriptions.get(first_hit, "Description not found")
        seq = smprot_db.get(first_hit, "")
        return pd.Series([desc, len(seq), seq])

    # Add the extracted reference columns
    positive_hits_df[['SmProt_Full_Description', 'SmProt_Protein_Length', 'SmProt_Full_Sequence']] = positive_hits_df['SmProt_Hits'].apply(get_details)
    
    # Select and order the columns for the final report
    columns_to_keep = [
        'Spectrum', 'Peptide', 'Peptide Length', 'Class', 'Hyperscore', 
        'SmProt_Hits', 'SmProt_Protein_Length', 'SmProt_Full_Description', 'SmProt_Full_Sequence'
    ]
    final_columns = [col for col in columns_to_keep if col in positive_hits_df.columns]
    
    # Save the filtered detailed hits table
    positive_hits_df[final_columns].to_csv(output_hits_only, sep='\t', index=False)
    
    unique_mapped = positive_hits_df['Peptide'].nunique()
    print(f"-> Success! Found SmProt hits for {unique_mapped} unique peptides.")
    print(f"-> Detailed hits file saved to: {output_hits_only}")
else:
    print("-> No SmProt hits found for the given peptides.")