#------------------------------------------------------------------------------
#
#    Prep Shi 2021 snRNAseq data for scDRS - create h5
#
#------------------------------------------------------------------------------

import scdrs
import pandas as pd
import scanpy as sc
from anndata import AnnData
import os, subprocess, tempfile
import seaborn as sn
from collections import Counter

SHI_H5AD = snakemake.input[0]
H5AD_OUT = snakemake.output[0]
COV_OUT = snakemake.output[1]


# Load data -------------------------------------------------------------------
adata = sc.read_h5ad(SHI_H5AD)

# Note that the Seurat to h5ad conversion alters cluster_level_1 mappings
# Keeps eyes peeled for other conversion issues
old_to_new = {
    0:'MGE',
    1:'CGE',
    2:'LGE',
    3:'Progenitor',
    4:'Early_InN',
    5:'Microglia'
}

adata.obs['cluster_level_1'] = (
    adata.obs['cluster_level_1']
    .map(old_to_new)
    .astype('category')
)

# Access cell / gene names
adata.obs_names
adata.var_names

# Add QC metrics
adata.var['mt'] = adata.var_names.str.startswith('MT-') 
sc.pp.calculate_qc_metrics(adata, qc_vars=['mt'], percent_top=None, log1p=False, 
                           inplace=True)

##  Create covariate file  ----------------------------------------------------
cov_df = pd.DataFrame(adata.obs['n_genes_by_counts'])
cov_df.columns = ['n_genes']
cov_df.index.name = 'index'
cov_df.reset_index(inplace = True)
cov_df.to_csv(COV_OUT, sep = "\t", index = False)

# Test for failure of compute score on hawk
sc.pp.normalize_per_cell(adata, counts_per_cell_after = 1e4)

# This is required to avoid error see: https://github.com/theislab/scvelo/issues/255
adata.__dict__['_raw'].__dict__['_var'] = adata.__dict__['_raw'].__dict__['_var'].rename(columns={'_index': 'features'})

# Write h5ad
adata.write(H5AD_OUT)

#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
