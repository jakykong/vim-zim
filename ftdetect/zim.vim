function! Ftdetect_zim()
  " No change if we didn't start with a txt file
  if &ft != 'text'
    return
  endif
  if getline(1) =~ "Content-Type: text/x-zim-wiki"
        \ || expand('%') =~ g:zim_notebooks_dir
    set ft=zim
  endif
endfunction


augroup Zim
au BufNewFile,BufRead *.txt call Ftdetect_zim()
augroup END
