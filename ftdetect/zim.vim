
function! s:ftdetect_zim()
    " No change if we didn't start with a txt file
    if &ft != 'text'
        return
    endif
    if getline(1) =~ "Content-Type: text/x-zim-wiki"
        set ft=zim
    endif
endfunction


au BufNewFile,BufRead *.txt call s:ftdetect_zim()


