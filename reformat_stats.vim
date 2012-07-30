function! ReformatStats()
  setlocal iskeyword+=.
  %substitute/,\s*/& /g
  %Tabular /,\zs /r0
  " the number of stats
  let l:col_skip = 12
  " the row identifiers
  let firstline = getline(1)
  if firstline =~? '\<seasons\=\>'
    let l:col_skip += 1
  endif
  if firstline =~? '\<games\=\>'
    let l:col_skip += 1
  endif
  if firstline =~? '\<batters\=\>'
    let l:col_skip +=1
  endif
  if firstline =~? '\<inn\>'
    let l:col_skip +=1
  endif
  " format BA, OBP, SLG, OPS:
  " turn 0 into 0.000 -- next command should handle this
  " %substitute/\(\(,[^,]\{-}\)\{14}\)\@<=\<0\>/&.000/g
  " add .000 when missing
  exec '%substitute/\(\(,[^,]\{-}\)\{'.l:col_skip.'}\)\@<=\<\d\>/&.000/ge'
  " truncate to x.xxx -- round() in R should handle this
  " exec '%substitute/\(\(,[^,]\{-}\)\{'.l:col_skip.'}\<\d\.\d\{3}\)\@<=\d*//g'
  " expand to .x00 or .xx0
  exec '%substitute/\(\(,[^,]\{-}\)\{'.l:col_skip.'}\.\(\d*\>\)\)\@<=/\=repeat("0",3-len(submatch(3)))/ge'
  %Tabular /,\zs /r0
endfunction
