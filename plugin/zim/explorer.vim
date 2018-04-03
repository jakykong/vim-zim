
""""""""""""""""""""""""""""""""""""""""""""""""""
""" The next functions are for notebook navigation
""

" Easily change g:zim_notebook
function! zim#explorer#SelectNotebook(whereopen)
  if len(a:whereopen)
    exe a:whereopen
  endif
  enew | set buftype=nowrite ft=zimindex | setlocal nowrap cursorline
  call setline(1, [ g:zim_notebooks_dir ]+
        \ filter(
        \ split(globpath(g:zim_notebooks_dir,'*'),"\n"),
        \ 'isdirectory(v:val)')
        \)
  nnoremap <buffer> <cr> :exe "let g:zim_notebook='".getline('.')."'"<cr>:q<cr>
  nnoremap <buffer> q :q<cr>
endfunction

function! zim#explorer#getLine()
  let l:l=b:dir.'/'.substitute(substitute(getline('.'),' : ','/','g'),' |.*$','','')
  if l:l =~ '>' || l:l =~ ':'
    let l:l=''
  endif
  let b:current_id=substitute(l:l,g:zim_notebook.'/*','','')
  return l:l
endfunction

function! zim#explorer#interactiveMove()
  let l:moving_tgt=zim#explorer#getLine()
  if len(b:current_id)
    if b:moving_id == '' 
      if b:current_id =~ '.*\.txt$'
        let b:moving_id=b:current_id
      endif
    else
      let l:moving_tgt=substitute(l:moving_tgt,'/[^/]*\.\(txt\|zim\)$','','')
      let l:src_file=g:zim_notebook.'/'.b:moving_id
      let l:src_dir=substitute(l:src_file,'\.txt$','','')
      let l:src_name=substitute(l:src_dir,'.*/\([^/]\)','\1','')
      let l:tgt_dir=l:moving_tgt.'/'.l:src_name
      let l:tgt_file=l:tgt_dir.'.txt'
      if l:src_dir == l:moving_tgt || l:src_file == l:tgt_file
        echo zim#util#gettext('Cannot move a note into itself !')
      else
        echo l:src_file.' -> '.l:tgt_file
        if isdirectory(l:src_dir)
          silent call zim#util#move(l:src_dir,l:tgt_dir,0,1)
        endif
        silent call zim#util#move(l:src_file,l:tgt_file,0,0)
      endif
      let b:moving_id=''
    endif
  endif
  call zim#explorer#ListUpdate()
endfunction

function! zim#explorer#interactiveRename()
  call zim#explorer#getLine()
  if len(b:current_id)
      let l:tgt=substitute(b:current_id,'/[^/]*\.\(txt\|zim\)$','','')
      let l:note_name=zim#note#getFilenameFromName(
            \input( zim#util#gettext('note_name').' ? ') )
      call zim#note#Move(0,b:current_id,l:tgt.'/'.l:note_name) 
  endif
  silent call zim#explorer#ListUpdate()
endfunction

function! zim#explorer#interactiveNewNote(whereopen)
  let l:curwin=win_getid()
  call zim#explorer#getLine()
  if len(b:current_id)
      let l:tgt=substitute(b:current_id,'\.\(txt\|zim\)$','','')
      let l:tgttab=split(l:tgt, '/')
      let l:sug=l:tgttab[-1]
      let l:tgt=join(l:tgttab[0:-2],'/')
      " let l:tgt=substitute(b:current_id,'/[^/]*\.\(txt\|zim\)$','','')
      let l:note_name=input( zim#util#gettext('note_name').' ? ',l:sug, 'customlist,zim#util#_CompleteNotes' )
      call zim#note#Create(a:whereopen,g:zim_notebook,l:tgt.'/'.l:note_name) 
      let l:newwin=win_getid()
  endif
  call win_gotoid(l:curwin)
  call zim#explorer#ListUpdate()
  call win_gotoid(l:newwin)
endfunction

function! zim#explorer#List(whereopen,dir,...)
  let l:filter=""
  if len(a:000) && len(a:1)
    let l:filter=a:1
  endif
  if len(a:whereopen)
    exe a:whereopen
  endif
  enew | set buftype=nowrite ft=zimindex | setlocal nowrap cursorline 
  let b:dir=a:dir | let b:filter=l:filter | let b:detect_doubles=0 
  let b:current_id='' | let b:moving_id=''
  "" Openning the file in a vertical new split (vnew) on Return:
  nnoremap <silent> <buffer> <cr> :call zim#util#open('','', 1, zim#explorer#getLine())<cr>
  nnoremap <silent> <buffer> <space> :call zim#util#open((len(tabpagebuflist())>1?'wincmd w':'vertical rightbelow split'),'', 0,zim#explorer#getLine())<cr>
  nnoremap <silent> <buffer> u  :call zim#explorer#getLine()<bar>call zim#explorer#ListUpdate()<cr>
  nnoremap <silent> <buffer> d  :call zim#explorer#getLine()<bar>let b:detect_doubles=!b:detect_doubles<bar>call zim#explorer#ListUpdate() <cr>
  nnoremap <buffer> m    :call zim#explorer#interactiveMove()<cr>
  nnoremap <buffer> N    :call zim#explorer#interactiveNewNote('rightbelow vertical split')<cr>
  nnoremap <buffer> R    :call zim#explorer#interactiveRename()<cr>
  nnoremap <buffer> D    :if(input(zim#util#gettext('Delete note').'[Y/n]') !~ "^[Nn]") <bar> call system('rm '.zim#explorer#getLine()) <bar> endif <bar> call zim#explorer#ListUpdate()<cr>
  exe "nnoremap <buffer> f    :silent call zim#explorer#getLine()<bar>let b:filter=input('".zim#util#gettext('Change filter :')."') <bar> call zim#explorer#ListUpdate()<cr>"
  nnoremap <buffer> q :q<cr>
  call zim#explorer#ListUpdate()
endfunction

"" Do a reccursive grep on Notebook
"@param string arg The word to search
function! zim#explorer#SearchTermInNotebook(arg)
  if has("win32")
    "assuming findstr
    let l:grep_opt='/s'
  else
    "assuming grep
    let l:grep_opt='-r'
  endif
  exe 'silent lgrep! '.l:grep_opt.' '.a:arg.' '.g:zim_notebook
  tabnew | ll | lopen
  nnoremap <buffer> q :lclose<cr>
  nnoremap <buffer> n :lnext<cr>
  nnoremap <buffer> N :lprevious<cr>
endfunction

"" List all notes / if a filter (or a regex) is provided 
"" only list the notes corresponding to the filter
"@param string dir    The directory to list
"@param string filter A word contained in the file name
function! zim#explorer#getNotesList(dir,filter,detect_doubles)
  let l:ret=[]
  for l:i in split(globpath(a:dir,'*'),"\n")
      if isdirectory(l:i)
"        if !(empty(b:moving_id))
"          call add(l:ret, substitute(substitute(l:i,g:zim_notebook.'/*','','')
"                \, '/', ' : ', 'g'))
"          let b:line_count+=1
"        endif
        call extend(l:ret ,zim#explorer#getNotesList(l:i,a:filter,0))
      else
        let l:i=substitute(l:i,g:zim_notebook.'/*','','')
        if b:current_id == l:i
          let b:selected_idx_in_list=b:line_count
        endif
        if b:moving_id == l:i
          call add(l:ret, substitute(l:i.' | MOVING ', '/', ' : ', 'g'))
          let b:line_count+=1
        elseif  l:i =~ a:filter
          call add(l:ret, substitute(l:i, '/', ' : ', 'g'))
          let b:line_count+=1
        endif
      endif
  endfor
  if a:detect_doubles
    let l:fnames={}
    for l:i in range(len(l:ret))
      let l:fname=substitute(l:ret[l:i],'.* : \([^:]*\.txt\)','\1','')
      if has_key(l:fnames, l:fname)
        let l:ret[l:i].=' |'
        let l:ret[l:fnames[l:fname][0]].=' |'
        let l:fnames[l:fname]+=[l:i]
        let b:nb_doubles+=1
      else
        let l:fnames[l:fname]=[l:i]
      endif
    endfor
    let l:fnames=filter(l:fnames,'len(v:val)>1')
    let b:doubles=[[0,0],values(l:fnames)]
  endif
  return l:ret
endfunction


"" List all notes / if a filter (or a regex) is provided 
"" only list the notes corresponding to the filter
"@param string dir   The directory to list
"@param string [opt] A word contained in the file name
function! zim#explorer#ListUpdate()
  if exists('b:dir') && exists('b:filter')
    let b:i=line('.')
    setlocal modifiable
    let b:selected_idx_in_list=-1
    let b:nb_doubles=0
    let b:line_count=0
    let l:note_list=zim#explorer#getNotesList(b:dir, b:filter, b:detect_doubles)
    let l:head=[
          \  '<-- Zim --> '.b:dir.' % '.b:filter, 
          \  '<cr>     -> '.zim#util#gettext('Open note'),
          \  '<space>  -> '.zim#util#gettext('Preview'),
          \  'u        -> '.zim#util#gettext('Update view'),
          \  'f        -> '.zim#util#gettext('Modify filter'),
          \  'd        -> '.(b:detect_doubles ? printf(zim#util#gettext('Disable doubles detection (%d founds)'), b:nb_doubles) : zim#util#gettext('Detect doubles names')) ] + 
          \ ( b:nb_doubles ? [  'n        -> '.zim#util#gettext('Find next double') ] : [] )
          \ + [
          \  'D        -> '.zim#util#gettext('Delete note') ,
          \  'N        -> '.zim#util#gettext('Create note') ,
          \  'm        -> '.(empty(b:moving_id) ? zim#util#gettext('Move note under cursor') : printf(zim#util#gettext('Place the note under cursor (moving %s)'),b:moving_id)), 
          \  'R        -> '.zim#util#gettext('Rename note under cursor') ,
          \  'q        -> '.zim#util#gettext('Close this window'),
          \  '-------- -> -------------------------------'] 
    %delete
    call setline(1,
          \ l:head +
          \ l:note_list
          \ )
    let b:first_line=(len(l:head)+1)
    if (b:selected_idx_in_list > -1)
        let b:i = b:first_line + b:selected_idx_in_list
    endif
    let b:i = (b:i < b:first_line ? b:first_line : b:i )
      
    exe b:i
    setlocal nomodifiable
    if (b:nb_doubles)
      nnoremap <buffer> n :call zim#explorer#NextDouble() <cr>
    else
      silent! nunmap <buffer> n
    endif
  endif
endfunction
"""

function! zim#explorer#NextDouble()
  exe b:doubles[1][b:doubles[0][0]][b:doubles[0][1]] + b:first_line
  let b:doubles[0][1]+=1  
  if (b:doubles[0][1]+1>len(b:doubles[1][b:doubles[0][0]]))
    let b:doubles[0][0]=(b:doubles[0][0]+1)%len(b:doubles[1])
    let b:doubles[0][1]=0
  endif
endfunction




