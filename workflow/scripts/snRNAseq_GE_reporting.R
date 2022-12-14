# -------------------------------------------------------------------------------------
#
#    snRNAseq - Reporting
#
# -------------------------------------------------------------------------------------

##  Set Variables  --------------------------------------------------------------------
SCRIPT_DIR <- '~/Desktop/fetal_brain_snRNAseq_GE_270922/workflow/scripts/'

##  Load objects  --------------------------------------------------------------------
source(paste0(SCRIPT_DIR, 'snRNAseq_GE_plots_magma_and_ldsr_plots.R'))
source(paste0(SCRIPT_DIR, 'snRNAseq_GE_scDRS_visualisation.R'))

# Create markdown file
OUT_DIR <- '~/Desktop/fetal_brain_snRNAseq_GE_270922/results/'
R_DIR <- paste0(OUT_DIR, 'R_objects/')
MARKDOWN_FILE <- paste0(SCRIPT_DIR, 'snRNAseq_GE_reporting.Rmd')
REPORT_DIR <- paste0(OUT_DIR, 'rmarkdown_reports/')
REPORT_FILE <- 'snRNAseq_GE_reporting.html'


##  Load Seurat Objects  --------------------------------------------------------------
seurat.shi.bc <- readRDS(paste0(R_DIR, 'seurat_shi_bc.rds'))
seurat.shi.bc_dwnSmpl_lvl1 <- readRDS(paste0(R_DIR, 'seurat_shi_bc_dwnSmpl_lvl1.rds'))
seurat.shi.bc_dwnSmpl_lvl2 <- readRDS(paste0(R_DIR, 'seurat_shi_bc_dwnSmpl_lvl2.rds'))

##  MAGMA & LDSR  ---------------------------------------------------------------------
# Default MAGMA 35UP_10DOWN, LDSR 100UP_100DOWN
magma_ldsr_lvl1_plot <- plot_grid(SCZ_magma_ldsr_lvl_1_plot, HEIGHT_magma_ldsr_lvl_1_plot)
magma_ldsr_lvl2_plot <-plot_grid(SCZ_magma_ldsr_lvl_2_plot, HEIGHT_magma_ldsr_lvl_2_plot)
magma_ldsr_cond_lvl2_plot <- plot_grid(SCZ_magma_ldsr_lvl_2_plot, 
                                       plot_grid(magma_cond_GE_MSN_35UP_10DOWN_plot, 
                                                 magma_cond_GE_InN_35UP_10DOWN_plot, ncol = 1))

# Correlation between cell number and MAGMA / LDSR results?
# Cluster level 1
cnts_lvl1 <- as.data.frame(table(seurat.shi.bc$cluster_level_1))
cnts_lvl1_dwnSmpl <- as.data.frame(table(seurat.shi.bc_dwnSmpl_lvl1$cluster_level_1))
colnames(cnts_lvl1) <- c('Category', 'cnts')
colnames(cnts_lvl1_dwnSmpl) <- c('Category', 'cnts_ds')
merge_lvl1 <- magma_SCZ_lvl_1_35UP_10DOWN_df %>% 
  left_join(cnts_lvl1) %>%
  left_join(cnts_lvl1_dwnSmpl) %>%
  left_join(ldsr_SCZ_lvl_1_100UP_100DOWN_df) 

cor(merge_lvl1[, unlist(lapply(merge_lvl1, is.numeric))])

cor.test(merge_lvl1$MAGMA, merge_lvl1$cnts)
cor.test(merge_lvl1$LDSR, merge_lvl1$cnts)
plot(merge_lvl1$MAGMA, merge_lvl1$cnts)
plot(merge_lvl1$MAGMA, merge_lvl1$cnts)

# Cluster level 2
cnts_lvl2 <- as.data.frame(table(seurat.shi.bc$cluster_level_2))
cnts_lvl2_dwnSmpl <- as.data.frame(table(seurat.shi.bc_dwnSmpl_lvl2$cluster_level_2))
colnames(cnts_lvl2) <- c('Category', 'cnts')
colnames(cnts_lvl2_dwnSmpl) <- c('Category', 'cnts_ds')
merge_lvl2 <- magma_SCZ_lvl_2_35UP_10DOWN_df %>% 
  left_join(cnts_lvl2) %>%
  left_join(cnts_lvl2_dwnSmpl) %>%
  left_join(ldsr_SCZ_lvl_2_100UP_100DOWN_df) 
  
cor(merge_lvl1[, unlist(lapply(merge_lvl1, is.numeric))])

for (LEVEL in c(1, 2)) {

  MAGMA_PRE_DS <- ggpubr::ggscatter(get(paste0('merge_lvl', LEVEL)), x = "MAGMA", y = "cnts", 
                            add = "reg.line", conf.int = TRUE, 
                            cor.coef = TRUE, cor.method = "pearson",
                            xlab = "MAGMA", ylab = "Cell counts", 
                            title = 'Cluster level 2')
  
  MAGMA_POST_DS <- ggpubr::ggscatter(get(paste0('merge_lvl', LEVEL)), x = "MAGMA", y = "cnts_ds",
                             add = "reg.line", conf.int = TRUE, 
                             cor.coef = TRUE, cor.method = "pearson",
                             xlab = "MAGMA", ylab = "Cell counts", 
                             title = 'Cluster level 2 - downsampled') +
    ylim(0, 3000)
  
  MAGMA_SCATTER <- plot_grid(MAGMA_PRE_DS, MAGMA_POST_DS)
  assign(paste0('magma_dnwSmple_scatter_lvl', LEVEL, '_plot'), MAGMA_SCATTER, envir = .GlobalEnv)  


}

# Downsampled  
magma_dwnSmple_lvl1_plot <- plot_grid(magma_SCZ_lvl_1_35UP_10DOWN_plot, magma_dwnSmpl_SCZ_lvl_1_35UP_10DOWN_plot)
magma_dwnSmple_lvl2_plot <- plot_grid(magma_SCZ_lvl_2_35UP_10DOWN_plot, magma_dwnSmpl_SCZ_lvl_2_35UP_10DOWN_plot)

# magma_dwnSmple_lvl1_all_plot <- plot_grid(magma_dwnSmpl_SCZ_lvl_1_10UP_10DOWN_plot, magma_dwnSmpl_SCZ_lvl_1_35UP_10DOWN_plot, 
#           magma_dwnSmpl_SCZ_lvl_1_100UP_100DOWN_plot, magma_dwnSmpl_HEIGHT_lvl_1_10UP_10DOWN_plot, 
#           magma_dwnSmpl_HEIGHT_lvl_1_35UP_10DOWN_plot, magma_dwnSmpl_HEIGHT_lvl_1_100UP_100DOWN_plot)

# Gene_windows
magma_windows_lvl1_plot <- plot_grid(magma_SCZ_lvl_1_10UP_10DOWN_plot, magma_SCZ_lvl_1_35UP_10DOWN_plot, 
                                     magma_SCZ_lvl_1_100UP_100DOWN_plot, magma_HEIGHT_lvl_1_10UP_10DOWN_plot, 
                                     magma_HEIGHT_lvl_1_35UP_10DOWN_plot, magma_HEIGHT_lvl_1_100UP_100DOWN_plot, ncol = 3)

ldsr_windows_lvl1_plot <- plot_grid(ldsr_SCZ_lvl_1_10UP_10DOWN_plot, ldsr_SCZ_lvl_1_35UP_10DOWN_plot, 
                                    ldsr_SCZ_lvl_1_100UP_100DOWN_plot, ldsr_HEIGHT_lvl_1_10UP_10DOWN_plot, 
                                    ldsr_HEIGHT_lvl_1_35UP_10DOWN_plot, ldsr_HEIGHT_lvl_1_100UP_100DOWN_plot, ncol = 3)

##  scDRS  ----------------------------------------------------------------------------
scDRS_all_umap <- plot_grid(scDRS_all_SCZ_group_umap, scDRS_all_HEIGHT_group_umap, ncol = 1)
scDRS_MGE_umap <- plot_grid(scDRS_MGE_SCZ_group_umap, scDRS_MGE_HEIGHT_group_umap, ncol = 1)
scDRS_LGE_umap <- plot_grid(scDRS_LGE_SCZ_group_umap, scDRS_LGE_HEIGHT_group_umap, ncol = 1)
scDRS_CGE_umap <- plot_grid(scDRS_CGE_SCZ_group_umap, scDRS_CGE_HEIGHT_group_umap, ncol = 1)
scDRS_Progenitor_umap <- plot_grid(scDRS_Progenitor_SCZ_group_umap, scDRS_Progenitor_HEIGHT_group_umap, ncol = 1)

# Heatmap

rmarkdown::render(MARKDOWN_FILE, output_file = REPORT_FILE, output_dir = REPORT_DIR)
