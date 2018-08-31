function frac_index, original, desired
  ;original is the y-data one has
  ;desired is the y-data which is needed
  index_original=indgen(n_elements(original))
  index_desired=interpol(index_original,original,desired)
  return, index_desired
end