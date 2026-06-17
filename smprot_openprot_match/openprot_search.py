import pandas as pd
import os

# --- 1. PATH CONFIGURATION ---
input_file = r"C:\docs\proteomics_project\psm_filtered_classified.tsv"
openprot_fasta = r"C:\docs\proteomics_project\smprot_analysis\human-openprot-2_2-refprots+altprots+isoforms-uniprot2022_06_01.fasta"

# Clear, descriptive output names as requested
output_all = r"C:\docs\proteomics_project\smprot_analysis\openprot_all_results.tsv"
output_positive = r"C:\docs\proteomics_project\smprot_analysis\openprot_positive_hits_detailed.tsv"

print("Step 1: Loading and filtering the input data...")
df = pd.read_csv(input_file, sep='\t')

# Target non-canonical classes
target_classes = ["Spliced_only", "Spliced_with_LIEPE-SPLICED_alternative"]
filtered_df = df[df['Class'].isin(target_classes)].copy()
unique_peptides = filtered_df['Peptide'].dropna().unique()

print(f"-> Total target spectra loaded: {len(filtered_df)} (Expected: 557)")
print(f"-> Total unique peptides to search: {len(unique_peptides)}")

print("\nStep 2: Loading and parsing the OpenProt FASTA database...")
openprot_db = {}
openprot_headers = {}

with open(openprot_fasta, "r") as f:
    current_id = None
    current_seq = []
    for line in f:
        line = line.strip()
        if line.startswith(">"):
            if current_id:
                openprot_db[current_id] = "".join(current_seq)
            
            full_header = line[1:]
            # Parse the clean Identifier using the rule ">(.*)|" -> up to the first pipe character
            current_id = full_header.split('|')[0].strip()
            openprot_headers[current_id] = full_header
            current_seq = []
        else:
            current_seq.append(line)
    if current_id:
        openprot_db[current_id] = "".join(current_seq)

print(f"-> Successfully loaded {len(openprot_db)} sequences from OpenProt.")

print("\nStep 3: Running exact string match against OpenProt sequences...")
peptide_to_hits = {}

for pep in unique_peptides:
    hits = []
    for op_id, op_seq in openprot_db.items():
        if pep in op_seq:  # Exact substring match check
            hits.append(op_id)
    
    if hits:
        peptide_to_hits[pep] = "; ".join(hits)
    else:
        peptide_to_hits[pep] = "No Hit"

# Map results back to create the comprehensive "ALL" file
filtered_df['OpenProt_Hits'] = filtered_df['Peptide'].map(peptide_to_hits)
filtered_df.to_csv(output_all, sep='\t', index=False)
print(f"-> Generated full mapping file: {output_all}")

print("\nStep 4: Creating a dedicated 'POSITIVE' file with parsed metadata...")
# Filter for successful hits only
positive_df = filtered_df[filtered_df['OpenProt_Hits'] != "No Hit"].copy()

if not positive_df.empty:
    # Lists to hold newly parsed columns
    protein_types = []
    gene_names = []
    transcript_accs = []
    full_descriptions = []
    full_sequences = []

    for hit_string in positive_df['OpenProt_Hits']:
        # If a peptide maps to multiple entries, parse the first primary hit for metadata
        primary_hit = hit_string.split(";")[0].strip()
        header = openprot_headers.get(primary_hit, "")
        sequence = openprot_db.get(primary_hit, "")
        
        # 1. Determine Protein Type using official OpenProt prefixes
        if primary_hit.startswith("IP_"):
            p_type = "AltProt (Novel Alternative Protein)"
        elif primary_hit.startswith("II_"):
            p_type = "Isoform (Novel Predicted Isoform)"
        else:
            p_type = "RefProt (Canonical Protein)"
            
        # 2. Extract standard fields from the header (GN=, TA=)
        gene = "Unknown"
        transcript = "Unknown"
        if " " in header:
            metadata_parts = header.split()
            for part in metadata_parts:
                if part.startswith("GN="):
                    gene = part.split("=")[1]
                elif part.startswith("TA="):
                    transcript = part.split("=")[1]

        protein_types.append(p_type)
        gene_names.append(gene)
        transcript_accs.append(transcript)
        full_descriptions.append(header)
        full_sequences.append(sequence)

    # Inject the clean parsed metadata back into the positive dataframe
    positive_df['OpenProt_Protein_Type'] = protein_types
    positive_df['OpenProt_Gene_Name'] = gene_names
    positive_df['OpenProt_Transcript_Accession'] = transcript_accs
    positive_df['OpenProt_Full_Sequence'] = full_sequences
    positive_df['OpenProt_Full_Description'] = full_descriptions
    positive_df['OpenProt_Protein_Length'] = positive_df['OpenProt_Full_Sequence'].apply(len)

    # Organize clean, logical columns for the final report
    final_report_columns = [
        'Spectrum', 'Peptide', 'Peptide Length', 'Class', 'Hyperscore', 'Qvalue',
        'OpenProt_Hits', 'OpenProt_Protein_Type', 'OpenProt_Gene_Name', 
        'OpenProt_Transcript_Accession', 'OpenProt_Protein_Length', 
        'OpenProt_Full_Sequence', 'OpenProt_Full_Description'
    ]
    
    # Filter columns to retain only what exists in the file
    available_columns = [col for col in final_report_columns if col in positive_df.columns]
    
    # Save the positive hits file
    positive_df[available_columns].to_csv(output_positive, sep='\t', index=False)
    
    unique_pep_count = positive_df['Peptide'].nunique()
    print(f"-> Done! Found hits for {unique_pep_count} unique peptides.")
    print(f"-> Generated positive hits file: {output_positive}")
else:
    print("-> No matches found. The positive hits file was not created.")