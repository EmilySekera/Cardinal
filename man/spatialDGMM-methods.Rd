\name{spatialDGMM-methods}
\docType{methods}
\alias{spatialDGMM}
\alias{class:SpatialDGMM}
\alias{SpatialDGMM-class}
\alias{spatialDGMM-methods}

\alias{spatialDGMM,SparseImagingExperiment-method}
\alias{summary,SpatialDGMM-method}

\title{Spatially-aware Dirichlet Gaussian mixture model}
\description{
    Fits spatially-aware Dirichlet Gaussian mixture models to each feature and each run in an imaging experiment. Each image is segmented and the means and variances of all Gaussian components are estimated. A linear filter with a spatial kernel is applied to the component probabilities to achieve spatial smoothing. Simulated annealing is used in the EM-algorithm to avoid local optimia and achieve more accurate parameter estimates.
}
\usage{
\S4method{spatialDGMM}{SparseImagingExperiment}(x, r = 1, k = 3, groups = run(x),
    method = c("gaussian", "adaptive"),
    dist = "chebyshev", annealing = TRUE,
    init = c("kmeans", "gmm"), p0 = 0.05,
    iter.max = 100, tol = 1e-9,
    BPPARAM = bpparam(), \dots)

\S4method{summary}{SpatialDGMM}(object, \dots)
}
\arguments{
    \item{x}{The imaging dataset to segment or classify.}
    \item{r}{The spatial neighborhood radius of nearby pixels to consider. This can be a vector of multiple radii values.}
    \item{k}{The maximum number of segments (clusters). This can be a vector to try initializing the clustering with different numbers of maximum segments. The final number of segments may differ.}
    \item{groups}{Pixels from different groups will be segmented separately. For the validity of downstream statistical analysis, it is important that \emph{each distinct observational unit (e.g., tissue sample) is assigned to a unique group}.}
    \item{method}{The method to use to calculate the spatial smoothing weights. The 'gaussian' method refers to spatially-aware (SA) weights, and 'adaptive' refers to spatially-aware structurally-adaptive (SASA) weights.}
    \item{dist}{The type of distance metric to use when calculating neighboring pixels based on \code{r}. The options are `radial', `manhattan', `minkowski', and `chebyshev' (the default).}
    \item{annealing}{Should simulated annealing be used during the optimization process to improve parameter estimates?}
    \item{init}{Should the parameter estimates be initialized using k-means ('kmeans') or Gaussian mixture model ('gmm')?}
    \item{p0}{A regularization parameter applied to estimated posterior class probabilities to avoid singularities. Must be positive for successful gradient descent optimization. Changing this value (within reason) should have only minimal impact on values of parameter estimates, but may greatly affect the algorithm's speed and stability.}
    \item{iter.max}{The maximum number of EM-algorithm iterations.}
    \item{tol}{The tolerance convergence criterion for the EM-algorithm. Corresponds to the change in log-likelihood.}
    \item{\dots}{Passed to internal methods.}
    \item{object}{A fitted model object to summarize.}
    \item{BPPARAM}{An optional instance of \code{BiocParallelParam}. See documentation for \code{\link{bplapply}}.}
}
\value{
    An object of class \code{SpatialDGMM}, which is a \code{ImagingResult}, where each element of the \code{resultData} slot contains at least the following components:

    \describe{
        \item{\code{estimates}:}{A list giving the parameter estimates for the means and variances for each Gaussian component.}
        \item{\code{class}:}{The predicted Gaussian component.}
        \item{\code{probability}:}{The probability of class membership for each Gaussian component.}
    }
}
\author{
    Dan Guo and Kylie A. Bemis
}
\references{
    Guo, D., Bemis, K., Rawlins, C., Agar, J., and Vitek, O. (2019.) Unsupervised segmentation of mass spectrometric ion images characterizes morphology of tissues. Proceedings of ISMB/ECCB, Basel, Switzerland, 2019.
}
\examples{
register(SerialParam())

set.seed(2)
x <- simulateImage(preset=3, dim=c(10,10), npeaks=6,
    peakheight=c(4,6,8), representation="centroid")

res <- spatialDGMM(x, r=1, k=5, method="adaptive")

summary(res)

image(res, model=list(feature=3))
}

\keyword{spatial}
\keyword{clustering}
