find_extrema = function(x, m, mode = c("peak", "valley")) {
  mode = match.arg(mode)
  shape = diff(sign(diff(x, na.pad = FALSE)))
  extrema = sapply(which(if (mode == "peak") shape < 0 else shape > 0), FUN = function(i) {
    z = max(i - m + 1, 1)
    w = min(i + m + 1, length(x))
    if (mode == "peak") {
      if (all(x[c(z:i, (i + 2):w)] <= x[i + 1])) return(i + 1)
    } else {
      if (all(x[c(z:i, (i + 2):w)] >= x[i + 1])) return(i + 1)
    }
    return(numeric(0))
  })
  unlist(extrema)
}
