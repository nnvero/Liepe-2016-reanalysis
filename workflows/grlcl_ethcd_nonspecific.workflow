workflow.workflow-option=Nonspecific-HLA

# --- MSFragger ---
msfragger.search_enzyme_name_1=nonspecific
msfragger.num_enzyme_termini=0
msfragger.allowed_missed_cleavage_1=2
msfragger.digest_min_length=9
msfragger.digest_max_length=12

msfragger.precursor_mass_tolerance=3
msfragger.precursor_mass_units=1
msfragger.fragment_mass_tolerance=0.02
msfragger.fragment_mass_units=0
msfragger.fragment_ion_series=b,y,c,z

msfragger.fixed_modifications=C\:57.02146
# Variable mods: deamidation (N,Q), oxidation (M), acetyl (protein N-term).
msfragger.variable_mod_01=15.9949 M
msfragger.variable_mod_02=42.0106 [^
msfragger.variable_mod_03=0.98402 NQ
# --- Variable-mod-free version (Liepe ignored PTMs for the spliced DB search).
#     To use it, comment the three variable_mod lines above and uncomment these:
# msfragger.variable_mod_01=
# msfragger.variable_mod_02=
# msfragger.variable_mod_03=

msfragger.database_name=/work/data/proteome/library/proteome_with_liepe_peptides_target_decoy.fasta
database.db-path=/work/data/proteome/library/proteome_with_liepe_peptides_target_decoy.fasta
database.decoy-tag=rev_
msfragger.num_threads=0
msfragger.calibrate_mass=0
msfragger.write_calibrated_mzml=false
msfragger.deisotope=1
msfragger.localize_delta_mass=false
msfragger.misc.slice-db=16

msbooster.predict-rt=true
msbooster.predict-spectra=true
# msbooster.predict-spectra=false
msbooster.predict-im=true
msbooster.find-best-rt-model=false
msbooster.find-best-spectra-model=false
msbooster.find-best-im-model=false
msbooster.rt-model=DIA-NN
msbooster.spectra-model=DIA-NN
msbooster.im-model=DIA-NN
msbooster.fragmentation-type=0
msbooster.koina-url=
msbooster.spectral-library-path=
percolator.run-percolator=true
percolator.cmd-opts=--only-psms --no-terminate --post-processing-tdc
percolator.min-prob=0.5
percolator.keep-tsv-files=false
peptide-prophet.run-peptide-prophet=false
peptide-prophet.cmd-opts=--decoyprobs --ppm --accmass --nonparam --expectscore
peptide-prophet.combine-pepxml=false
protein-prophet.run-protein-prophet=true
protein-prophet.cmd-opts=--maxppmdiff 2000000
phi-report.run-report=true
phi-report.filter=--sequential --prot 1
phi-report.dont-use-prot-proph-file=false
phi-report.print-decoys=false
phi-report.pep-level-summary=true
phi-report.prot-level-summary=true
phi-report.remove-contaminants=false
ptmprophet.run-ptmprophet=false
diann.run-dia-nn=false
diatracer.run-diatracer=false

quantitation.run-label-free-quant=true
workflow.input.data-type.regular-ms=true
workflow.input.data-type.im-ms=false
workflow.misc.save-sdrf=true
ionquant.run-ionquant=true
ionquant.use-lfq=true
ionquant.use-labeling=false
ionquant.maxlfq=1
ionquant.intensitymode=2
ionquant.mbr=1
ionquant.mbrimtol=0.05
ionquant.mbrmincorr=0
ionquant.mbrrttol=1
ionquant.mbrtoprun=10
ionquant.minfreq=0
ionquant.minions=1
ionquant.minisotopes=2
ionquant.minscans=3
ionquant.ionfdr=0.01
ionquant.peptidefdr=1
ionquant.proteinfdr=1
ionquant.locprob=0.75
ionquant.mztol=10
ionquant.imtol=0.05
ionquant.rttol=0.4
ionquant.normalization=1
ionquant.requantify=1
ionquant.uniqueness=0
ionquant.writeindex=0
ionquant.tp=0
ionquant.excludemods=
ionquant.formula=
ionquant.light=
ionquant.medium=
ionquant.heavy=

# --- Outputs ---
fragpipe-config.bin-msfragger=tools/FragPipe-24.0-linux/tools/MSFragger/msfragger.jar
