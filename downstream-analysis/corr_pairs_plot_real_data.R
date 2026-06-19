#!/usr/bin/env Rscript
# Pairwise correlation plot (Hmisc) from synthetic data reproducing the
# correlation matrix heatmap
#   - lower triangle : pairwise scatterplots (small black dots + thick fit line)
#   - upper triangle : Pearson r, sized/coloured by magnitude/sign
#   - significance    : BH-adjusted (Hmisc::rcorr) padj < 0.05 marked with stars
suppressPackageStartupMessages({
  library(MASS)
  library(Hmisc)
  library(Matrix)
})

set.seed(42)
N <- 554L  # sample size -> drives which |r| clear BH < 0.05


# --- target correlation matrix, transcribed from the heatmap -----------------
R <- matrix(c(
  # aff   Delta  PepLen  Qval   RTSc   SpSim
  1.00,  -0.00,  -0.35, 0.02, -0.10, 0.13,
  -0.00,  1.00,  0.22, 0.34, -0.19,  0.06,
  -0.35,  0.22,  1.00, 0.24, -0.01, -0.08,
  0.02, 0.34, 0.24,  1.00,  -0.18, 0.33,
  -0.10, -0.19, -0.01,  -0.18,  1.00, -0.16,
  0.13,  0.06, -0.08, 0.33, -0.16,  1.00),
  nrow = 6, byrow = TRUE, dimnames = list(vars, vars))

# --- coerce to nearest positive-definite correlation matrix (safety) ---------
R_pd <- as.matrix(Matrix::nearPD(R, corr = TRUE, keepDiag = TRUE)$mat)

dat <- read.csv("group2_metrics.csv", check.names = FALSE)


vars <- c("neg_log_affinity", "DeltaScore", "Peptide Length", "neg_log_qvalue", "RTScore", "SpectralSim")
dat <- dat[, vars]      # keep only these columns, in this order
N <- nrow(dat)
# --- Hmisc::rcorr -> Pearson r + p-values, then BH-adjust --------------------
rc   <- Hmisc::rcorr(as.matrix(dat), type = "spearman")
rmat <- rc$r
pmat <- rc$P                                    # NA on the diagonal
ut   <- upper.tri(pmat)
padj <- matrix(NA_real_, 6, 6, dimnames = dimnames(pmat))
padj[ut] <- p.adjust(pmat[ut], method = "BH")   # BH over the 15 unique pairs
padj[lower.tri(padj)] <- t(padj)[lower.tri(padj)]

stars <- function(p) ifelse(is.na(p), "",
                            ifelse(p < 0.001, "***", ifelse(p < 0.01, "**", ifelse(p < 0.05, "*", ""))))

# --- pairs() panels, driven by the Hmisc::rcorr r / BH-padj matrices ---------
M <- as.matrix(dat)
find_idx <- function(v)                          # recover column index of a panel vector
  which(apply(M, 2, function(cc) isTRUE(all.equal(cc, as.numeric(v), tolerance = 1e-9))))[1]

panel_scatter <- function(x, y, ...) {           # lower: dots + thick fit line
  points(x, y, pch = 16, cex = 0.45, col = adjustcolor("black", 0.30))
  abline(lm(y ~ x), col = "#2C7FB8", lwd = 3)
}

panel_cor <- function(x, y, ...) {               # upper: Pearson r + BH stars
  usr <- par("usr"); on.exit(par(usr = usr))
  par(usr = c(0, 1, 0, 1))
  i <- find_idx(x); j <- find_idx(y)
  r <- rmat[i, j]; sig <- stars(padj[i, j])
  if (sig != "") rect(0.04, 0.04, 0.96, 0.96,
                      col = adjustcolor("grey60", 0.18), border = NA)
  text(0.5, 0.58, sprintf("%.2f", r), col = "black", cex = 1.5, font = 2)
  text(0.5, 0.22, sig, col = "black", cex = 1.5, font = 2)
}

panel_diag <- function(x, ...) {                 # diagonal: histogram + bold name
  usr <- par("usr"); on.exit(par(usr = usr))
  par(usr = c(usr[1:2], 0, 1))
  h <- hist(x, plot = FALSE, breaks = 18)
  rect(h$breaks[-length(h$breaks)], 0, h$breaks[-1],
       h$counts / max(h$counts) * 0.5, col = "#E8E8E8", border = NA)
  text(mean(usr[1:2]), 0.82, vars[find_idx(x)], col = "black", font = 2, cex = 1.15)
}


out <- "pairwise_hmisc_group2.png"
png(out, width = 2000, height = 2000, res = 220)
pairs(dat,
      lower.panel = panel_scatter, upper.panel = panel_cor,
      diag.panel  = panel_diag,    text.panel  = function(...) NULL,
      gap = 0.3, oma = c(5, 4.5, 6, 1.5),
      cex.axis = 0.7, font.axis = 2, col.axis = "black", las = 1,
      main = "Spearman correlation: HLA-I immune peptide peptide-spectrum matches/peptide sequences in GR-LCL cell line",
      cex.main = 0.92, font.main = 2, line.main = 4.0)   # pairs' built-in title
# pairs() has no `sub`; add the legend by hand (re-set oma — pairs restores it on exit)
par(oma = c(5, 4.5, 6, 1.5))
mtext("Spliced_only+Spliced_with_LIEPE-SPLICEd_alternative, n = 554;  BH padj  * <.05  ** <.01  *** <.001",
      side = 1, outer = TRUE, line = 4.0, cex = 0.8, font = 2, col = "black")
dev.off()

# --- console summary ---------------------------------------------------------
cat("\nBH-adjusted significance (upper-triangle pairs):\n")
idx <- which(upper.tri(rmat), arr.ind = TRUE)
tab <- data.frame(
  pair = sprintf("%s ~ %s", vars[idx[, 1]], vars[idx[, 2]]),
  r    = round(rmat[idx], 3),
  p    = signif(pmat[idx], 3),
  padj = signif(padj[idx], 3),
  sig  = stars(padj[idx]))
tab <- tab[order(tab$padj), ]
print(tab, row.names = FALSE)
cat("\nwritten:", out, "\n")