r_version_string <- function() {
  paste0(R.version$major, ".", R.version$minor)
}

r_version_string.patch_x <- function() {
  gsub(".$", "x", r_version_string())
}
