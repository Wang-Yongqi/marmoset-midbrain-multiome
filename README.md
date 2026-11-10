# Marmoset midbrain single-nucleus multiome

This repository contains the preprocessing and joint RNA–ATAC workflow for two 10x Multiome reactions from a single common marmoset ventral midbrain specimen. The study generated 32,070 nuclei that passed quality control, including 258 dopaminergic nuclei across the two reactions. The reactions are technical replicates from one animal.

`SN_pipeline.Rmd` reads the Cell Ranger ARC gene expression matrix, called ATAC peaks, and indexed fragments for each reaction. It filters RNA counts, removes predicted doublets with scDblFinder, quantifies fragments over a shared peak set, and computes transcription start site (TSS) enrichment and nucleosome signal. It then merges the reactions, performs SCTransform and RNA PCA, and uses TF–IDF and latent semantic indexing for ATAC. Seurat's weighted nearest-neighbor graph supports joint clustering and UMAP. RNA marker plots help interpret the clusters.

The notebook preserves the archived implementation's RNA count filter and calculates TSS enrichment without filtering on it. The manuscript Methods instead describe a detected-gene cutoff and a TSS enrichment cutoff. Reproducing the reported final nucleus counts requires the exact filtering and annotation settings used for the manuscript.

## Inputs and use

1. Use Cell Ranger ARC outputs aligned to `Callithrix_jacchus_cj1700_1.1` (calJac4). Each reaction's `outs` directory must contain `filtered_feature_bc_matrix.h5`, `atac_peaks.bed`, `atac_fragments.tsv.gz`, and `atac_fragments.tsv.gz.tbi`. The NeMO Archive hosts the broader [RNA collection](https://assets.nemoarchive.org/collection/nemo:col-qys8yad) and [ATAC collection](https://assets.nemoarchive.org/collection/nemo:col-z6ym0ii) containing the study records.
2. Supply the matching NCBI gene annotation in GFF3 format, with chromosome names compatible with the Cell Ranger reference. The [NCBI calJac4 assembly record](https://www.ncbi.nlm.nih.gov/assembly/7157801) identifies RefSeq assembly `GCF_009663435.1`. The `tss.bed` file supplied with the calJac4 reference is included here.
3. Install R, Pandoc, and the R packages `rmarkdown`, `knitr`, `Seurat`, `Signac`, `hdf5r`, `GenomicRanges`, `GenomeInfoDb`, `S4Vectors`, `SummarizedExperiment`, `rtracklayer`, and `scDblFinder`. From the repository root, render the notebook with paths to the two reaction directories and the GFF3 annotation.

```r
rmarkdown::render(
  "SN_pipeline.Rmd",
  params = list(
    rxn1_outs = "/path/to/ivy_rxn1/outs",
    rxn2_outs = "/path/to/ivy_rxn2/outs",
    annotation_gff = "/path/to/cj1700.gff"
  )
)
```

The default output paths are `SN_pipeline.html` and `results/merged_SN_ivy.rds`.

## Cell Ranger ARC template

`spock_script.sh` and `libraries.csv` adapt the reaction 2 SLURM job. Replace both FASTQ directories in the CSV with absolute paths and verify the sample prefixes against the FASTQ filenames. Set `CELLRANGER_REFERENCE` to your installed ARC reference and submit the job from the repository root. Set `LIBRARIES_CSV` to use a different manifest and `RUN_ID` for a different output ID.

```bash
export CELLRANGER_REFERENCE=/path/to/calJac4_multiome
sbatch spock_script.sh
```

The original reaction 2 job pointed to `mCalJa1.2.pat.X`. The template takes the reference as an input. For the calJac4 notebook, use ARC outputs, the GFF3 annotation, and the TSS BED from the same assembly.
