let g:zim_notebook=get(g:,'zim_notebook',"Notebooks")

function! Ftdetect_zim()
  " No change if we didn't start with a txt file
  if &ft != 'text'
    return
  endif
  if getline(1) =~ "Content-Type: text/x-zim-wiki"
        \ || expand('%') =~ g:zim_notebook
    set ft=zim
  endif
endfunction


au BufNewFile,BufRead *.txt call Ftdetect_zim()


