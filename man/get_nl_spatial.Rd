% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_nl_spatial.R
\name{get_nl_spatial}
\alias{get_nl_spatial}
\title{Get spatial data from metrics.turtles and metrics.patches output}
\usage{
get_nl_spatial(nl, turtles = TRUE, patches = TRUE, links = FALSE,
  turtle_coords = "px", format = "spatial")
}
\arguments{
\item{nl}{nl object}

\item{turtles}{if TRUE (default), the function generates reports the metrics.turtles as spatial columns (either in a tibble or sf object)}

\item{patches}{if TRUE (default), the function generates raster objects from metrics.patches data (either in a tibble or raster object)}

\item{links}{if TRUE (default is false), the function collects the the end1 and  end2, as well as link variables (if provided).}

\item{turtle_coords}{either "px" if turtle coordinates were measured as
"pxcor" and "pycor" or "x" if coordinates were measured as "xcor" and "ycor"}

\item{format}{string indication whether to return spatial objects
(RasterLayer, sf Points) or a rowbinded tibble}
}
\value{
tibble with spatial data objects
}
\description{
Turn results from NetLogo in spatial data objects
}
\details{
get_nl_spatial generates spatial point objects and raster objects from data
that has been collected by metrics.turtles and metrics.patches.
metrics.turtles and metrics.patches need to collect coordinates of turtles
and patches.
For patches this can be easily done by adding "pxcor" and "pycor" to
metrics.patches.
For turtles you can either add "pxcor" and "pycor" to metrics.turtles or
"xcor" and "ycor".
For turtles you can add "end1" and "end2" to metrics.turtles.
It is also possible to measure both coordinates, and select the type that is
used for spatial object creation through the function parameter
turtle_coords.
"px" uses "pxcor" and "pycor", while "x" uses "xcor" and "ycor".

Furthermore, every type of agent also supports additional information (turtle, patch or link owns).
These are also collected and returned. If the output format is supposed to spatial,
turtle owns become columns in the sf object, and patch owns are returned as rasterstack for each tick.

\emph{NOTE}:

Links are currently only supported in the tibble output format!
}
\examples{
\dontrun{

# Run parallel on local machine:
library(future)
plan(multisession)
# Run simulations:
results \%<-\% run_nl_all(nl = nl)
# Attach results to nl:
setsim(nl, "simoutput") <- results
# Get spatial data:
results_spatial <- get_nl_spatial(nl)
}
}
