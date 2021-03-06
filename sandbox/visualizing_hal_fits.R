n <- 1000
dat <- make_ks(1000)
library(hal9001)

fit <- fit_hal(X = cbind(dat$A, dat$W), Y = dat$Y,
                standardize = FALSE, fit_type = "glmnet",
                lambda =  exp(seq(3, -50, length = 2000)))


n <- 1000
dat <- make_ks_mod(1000)
library(hal9001)

fit_mod <- fit_hal(X = cbind(dat$A, dat$W), Y = dat$Y,
                standardize = FALSE, fit_type = "glmnet",
                lambda =  exp(seq(3, -50, length = 2000)))

# fit2 <- fit_hal(X = cbind(dat$A, dat$W), Y = dat$Y)

fit_earth <- earth::earth(x = cbind(dat$A, dat$W), y = dat$Y, degree = 2, 
            nk = 21, penalty = 3, pmethod = "backward", nfold = 0, 
            ncross = 1, minspan = 0, endspan = 0)

get_Q0 <- function(pred_dat){
	z1 <- 2*log(pred_dat$W1)
	z2 <- (pred_dat$W2 - 10) * (1 + exp(z1))
	z3 <- ((pred_dat$W3^(1/3) - 0.6) * 25 ) /z1
	z4 <- sqrt(pred_dat$W4) - 20 - z2

	Q0 <- 210 + 27.4*z1 + 13.7*z2 + 13.7*z3 + 13.7*z4 

	return(Q0)
}

get_g0 <- function(pred_dat){
	z1 <- 2*log(pred_dat$W1)
	z2 <- (pred_dat$W2 - 10) * (1 + exp(z1))
	z3 <- ((pred_dat$W3^(1/3) - 0.6) * 25 ) /z1
	z4 <- sqrt(pred_dat$W4) - 20 - z2

	g0 <-  plogis(-z1 + 0.5*z2 - 0.25*z3 - 0.1*z4)

	return(g0)
}

make_pred_plot <- function(dat, fit, which.var = "W1", npt = 1000, a0 = 0,
                           set_covar = "mean", yl = NULL, rug = TRUE){

	w_seq <- seq(min(dat$W[,which.var]), max(dat$W[,which.var]), length = npt)
	if(set_covar == "mean"){
		pred_dat <- data.frame(A = rep(a0,npt), 
	                       W1 = rep(mean(dat$W$W1), npt),
	                       W2 = rep(mean(dat$W$W2), npt),
	                       W3 = rep(mean(dat$W$W3), npt),
	                       W4 = rep(mean(dat$W$W4), npt))
	}else if(set_covar == "p25"){
		pred_dat <- data.frame(A = rep(a0,npt), 
	                       W1 = rep(quantile(dat$W$W1, p = 0.25), npt),
	                       W2 = rep(quantile(dat$W$W2, p = 0.25), npt),
	                       W3 = rep(quantile(dat$W$W3, p = 0.25), npt),
	                       W4 = rep(quantile(dat$W$W4, p = 0.25), npt))
	}else if(set_covar == "p50"){
		pred_dat <- data.frame(A = rep(a0,npt), 
	                       W1 = rep(quantile(dat$W$W1, p = 0.50), npt),
	                       W2 = rep(quantile(dat$W$W2, p = 0.50), npt),
	                       W3 = rep(quantile(dat$W$W3, p = 0.50), npt),
	                       W4 = rep(quantile(dat$W$W4, p = 0.50), npt))
	}else if(set_covar == "p75"){
		pred_dat <- data.frame(A = rep(a0,npt), 
	                       W1 = rep(quantile(dat$W$W1, p = 0.75), npt),
	                       W2 = rep(quantile(dat$W$W2, p = 0.75), npt),
	                       W3 = rep(quantile(dat$W$W3, p = 0.75), npt),
	                       W4 = rep(quantile(dat$W$W4, p = 0.75), npt))
	}
	pred_dat[,which.var] <- w_seq
	if(class(fit) == "hal9001"){
		pred1 <- predict(fit, new_data = pred_dat)
	}else{
		pred1 <- predict(fit, newdata = pred_dat, type = "response")
	}
	truth <- get_Q0(pred_dat)
	if(is.null(yl)){
		yl <- range(c(truth, pred1))
	}
	plot(truth ~ w_seq, xlab = which.var, ylab = "Y",
	     ylim = yl, type = "l", lwd = 2, col = 2, lty = 2)
	lines(pred1 ~ w_seq, lwd = 2)
	if(rug){
		rug(dat$W[,which.var])
	}
}

pdf("~/Dropbox/R/haltmle.sim/sandbox/original_ks_halfit.pdf")
layout(matrix(1:12, nrow = 4, ncol = 3, byrow = TRUE))
par(mar = c(4.1, 2.1, 0.1, 0.1), mgp = c(2.1, 0.5, 0))
for(w in paste0("W",1:4)){
	make_pred_plot(dat, fit, which.var = w, npt = 1000, a0 = 1, set_covar = "p25",
	               yl = c(100,340))
	make_pred_plot(dat, fit, which.var = w, npt = 1000, a0 = 1, set_covar = "p50",
	               yl = c(100,340))
	make_pred_plot(dat, fit, which.var = w, npt = 1000, a0 = 1, set_covar = "p75",
               yl = c(100,340))
}
dev.off()

pdf("~/Dropbox/R/haltmle.sim/sandbox/modified_ks_halfit.pdf")
layout(matrix(1:12, nrow = 4, ncol = 3, byrow = TRUE))
par(mar = c(4.1, 2.1, 0.1, 0.1), mgp = c(2.1, 0.5, 0))
for(w in paste0("W",1:4)){
	make_pred_plot(dat, fit_mod, which.var = w, npt = 1000, a0 = 1, set_covar = "p25",
	               yl = c(100,340))
	make_pred_plot(dat, fit_mod, which.var = w, npt = 1000, a0 = 1, set_covar = "p50",
	               yl = c(100,340))
	make_pred_plot(dat, fit_mod, which.var = w, npt = 1000, a0 = 1, set_covar = "p75",
               yl = c(100,340))
}
dev.off()


make_pred_plot(dat, fit, which.var = "W1", npt = 1000, a0 = 1, set_covar = "p25")
make_pred_plot(dat, fit, which.var = "W3", npt = 1000, a0 = 1, set_covar = "p25")
make_pred_plot(dat, fit, which.var = "W4", npt = 1000, a0 = 1, set_covar = "p25")

make_pred_plot(dat, fit_earth, which.var = "W1", npt = 1000, a0 = 1, set_covar = "p75")
plot_done()

make_pred_plot(dat, fit, which.var = "W2", npt = 1000, a0 = 1, set_covar = "mean")
plot_done()
make_pred_plot(dat, fit, which.var = "W3", npt = 1000, a0 = 1, set_covar = "mean")
plot_done()
make_pred_plot(dat, fit, which.var = "W4", npt = 1000, a0 = 1, set_covar = "mean")
plot_done()


fit_propens <- fit_hal(X = dat$W, Y = dat$A)
make_prop_plot <- function(dat, fit, which.var = "W1", npt = 1000){

	w_seq <- seq(min(dat$W[,which.var]), max(dat$W[,which.var]), length = npt)
	pred_dat <- data.frame(W1 = rep(mean(dat$W$W1), npt),
	                       W2 = rep(mean(dat$W$W2), npt),
	                       W3 = rep(mean(dat$W$W3), npt),
	                       W4 = rep(mean(dat$W$W4), npt))
	pred_dat[,which.var] <- w_seq
	pred1 <- predict(fit, new_data = pred_dat)
	truth <- get_g0(pred_dat)
	ylim <- range(c(truth, pred1))
	plot(pred1 ~ w_seq, xlab = which.var, ylab = "A",
	     ylim = ylim, type = "l", lwd = 2)
	lines(truth ~ w_seq, lty = 2, col = 2, lwd = 2)
}

make_prop_plot(dat, fit_propens)

