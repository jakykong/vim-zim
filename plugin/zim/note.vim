"" Create Zim Note in a buffer, i.e., for a new file
" @param string dir  Notebook dir
" @param string name Path to the note
function! zim#note#Create(whereopen,dir,name)
  if !len(a:name)
    echomsg zim#util#gettext('note_out_of_notebook')
    return
  endif
  let l:nsplit=split(a:name.'/','/')
  let l:note_name=l:nsplit[-1]
  let l:note_dir=join(l:nsplit[0:-2],'/')
  if empty(l:note_name)
    let l:note_name=input( zim#util#gettext('note_name').' ? ')
  endif

  let l:note=a:dir.'/'.l:note_dir.'/'.substitute(
        \substitute(l:note_name,'\([ :\*]\)\+','_','g'),
        \'\(\.txt\)\?$','.txt','g')
  if l:note !~ g:zim_notebooks_dir.'/.*/.*.txt'
    echomsg zim#util#gettext('note_out_of_notebook')
  else
    let l:dirs=split(substitute(
          \substitute(l:note,'/[^/]*$','',''),g:zim_notebooks_dir,'',''),'/')
    if isdirectory(g:zim_notebooks_dir.'/'.l:dirs[0])
      if len(a:whereopen)
        exe a:whereopen
      endif
      if !filereadable(l:note)
        " path begin with Notebook name
        let l:notebook=l:dirs[0]
        call remove(l:dirs,0)
        let l:path=l:notebook
        for l:i in l:dirs
          let l:path.='/'.l:i
          if !isdirectory(g:zim_notebooks_dir.'/'.l:path)
            call mkdir(g:zim_notebooks_dir.'/'.l:path,'p', 0700)
          endif
          if !filereadable(g:zim_notebooks_dir.'/'.l:path.'.txt')
            call zim#note#Create(a:whereopen,g:zim_notebooks_dir,l:path)
          endif
        endfor
        exe 'e '.l:note
        call zim#editor#CreateHeader()
        silent exe 'silent w'
        if has('win32')
          echo "skip chmod"
        else
          silent exe '!chmod 0700 '.l:note
        endif
        silent exe 'silent e!'
        echomsg printf(zim#util#gettext("'%s' created"),l:note)
        if exists('g:zim_update_index_key')
          if len(exepath('xdotool'))
            exe "silent !xdotool search --name '".l:notebook." - Zim' key ".g:zim_update_index_key
          endif
        endif
      else
        echomsg printf(zim#util#gettext("Note '%s' already exists"),l:dirs[0])
        exe 'e '.l:note
      endif
    else
      echomsg printf(zim#util#gettext("NoteBook '%s' not exists"),l:dirs[0])
    endif
  endif
endfunction


"" Create a new notebook nammed name
function! zim#note#CreateNoteBook(name)
  let l:dir=g:zim_notebooks_dir.'/'.substitute(a:name,'\([ :/\*]\)\+','_','g')
  let l:file=l:dir.'/notebook.zim'
  let l:lines=[
        \ '[Notebook]',
        \ 'version='.g:zim_wiki_version,
        \ 'name='.a:name,
        \ 'interwiki=',
        \ 'home=Home',
        \ 'icon=',
        \ 'document_root=',
        \ 'shared=True',
        \ 'endofline='.(has('win32')? 'msdos' : 'unix'),
        \ 'disable_trash=False',
        \ 'profile=',
        \]
  if !isdirectory(l:dir)
    call mkdir(l:dir,'p', 0700)
  endif
  if !filereadable(l:file)
    call writefile(l:lines, l:file, "b")
    call zim#note#AppendToNotebooksList(l:dir)
    echomsg printf(zim#util#gettext("NoteBook '%s' created"),l:file)
  else
    echomsg printf(zim#util#gettext("NoteBook '%s' already exists"),l:dir)
  endif
endfunction


function! zim#note#AppendToNotebooksList(dir)
  if len(g:zim_config_dir)
    let l:update_zim=input(zim#util#gettext("Say Zim to acknowledge this NoteBook ? [Y/n]"))
    if !len(l:update_zim) || l:update_zim =~? '^y'
      let l:accounted=readfile(g:zim_config_dir.'/notebooks.list')
      if len(l:accounted)
        let l:ck=0
        for l:i in range(len(l:accounted))
          let l:l=l:accounted[l:i]
          if l:ck 
            if  (l:l =~? '^\s*\($\|\[Notebook \)' ) 
              call insert(l:accounted,(l:i-l:ck).'='.a:dir,l:i)
              break
            endif
          elseif l:l =~? "^\[NotebookList"
            " +1 to skip Default
            let l:ck=l:i+1
          endif
        endfor
        call writefile(l:accounted,g:zim_config_dir.'/notebooks.list')
      else
        echomsg printf(zim#util#gettext("Invalid Zim configuration : %s"), 'notebooks.list')
      endif
    endif
  else
    echomsg zim#util#gettext("(You shall setup g:zim_config_dir to easily update notebooks.list)")
  endif
endfunction

"" Move a note and its sub notes
function! zim#note#Move(copy,src,tgt)
  let l:src_dir=g:zim_notebook.'/'.substitute(a:src,'\(/\|\.txt\)$','','')
  let l:src_name=substitute(l:src_dir,'.*/\([^/]\)','\1','')
  let l:src_file=l:src_dir.'.txt'
  let l:tgt=substitute(a:tgt,'\([ :\*]\)\+','_','g').( a:tgt =~ '/$' ? l:src_name : '')
  let l:tgt_dir=g:zim_notebook.'/'.substitute(l:tgt,'\(/\|\.txt\)$','','')
  let l:tgt_name=substitute(l:tgt_dir,'.*/\([^/]\)','\1','')
  let l:tgt_file=l:tgt_dir.'.txt'
  if isdirectory(l:src_dir) && isdirectory(l:tgt_dir)
    echomsg printf(zim#util#gettext("Directory '%s' already exists"),l:tgt_dir)
    return 0
  endif
  if filereadable(l:tgt_file)
    echomsg printf(zim#util#gettext("Note '%s' already exists"),l:tgt_file)
    return 0
  endif
  let l:dirs=split(substitute(
        \substitute(l:tgt_dir,'/[^/]*$','',''),g:zim_notebooks_dir,'',''),'/')
  if isdirectory(g:zim_notebooks_dir.'/'.l:dirs[0])
    " Prepare target
    " path begin with Notebook name
    let l:notebook=l:dirs[0]
    let l:tgt_notename=l:dirs[0]
    call remove(l:dirs,0)
    let l:path=l:notebook
    for l:i in l:dirs
      let l:path.='/'.l:i
      if !filereadable(g:zim_notebooks_dir.'/'.l:path.'.txt')
        call zim#explorer#CreateNote(g:zim_notebooks_dir,l:path)
      endif
      if !isdirectory(g:zim_notebooks_dir.'/'.l:path)
        call mkdir(g:zim_notebooks_dir.'/'.l:path,'p', 0700)
      endif
    endfor
    if isdirectory(l:src_dir)
      call zim#util#move(l:src_dir,l:tgt_dir,a:copy,1)
    endif
    call zim#util#move(l:src_file,l:tgt_file,a:copy,0)
    if exists('g:zim_update_index_key')
      if len(exepath('xdotool'))
        exe "silent !xdotool search --name '".l:notebook." - Zim' key ".g:zim_update_index_key
      endif
    endif
  else
    echomsg printf(zim#util#gettext("NoteBook '%s' not exists"),l:dirs[0])
  endif
endfunction


"" The things that happen on note openning
function! s:setBufferSpecific()
  " set buffer properties
  setlocal tabstop=4
  setlocal softtabstop=4
  setlocal shiftwidth=4
  
  " add commamds avaible for the note
  command! -buffer -nargs=* ZimGrepThis :call zim#explorer#SearchInNotebook(expand('<cword>'))
  command! -buffer -nargs=* ZimListThis :call zim#explorer#ListNotes(g:zim_notebook,expand('<cword>'))

  command! -buffer -nargs=1 -complete=file ZimImgInsert :call zim#editor#InsertImage(<q-args>,'')
  command! -buffer -nargs=1 -complete=file ZimImgCapture :call zim#editor#InsertImage(<q-args>,g:zim_img_capture)

  for s:el in keys(g:zim_matchable)
    exe 'command! -buffer ZimMatchNext'.s:el." :exe zim#util#line([{'default': line('.')},'".g:zim_matchable[s:el]."'],line('.')+1,1)"
    exe 'command! -buffer ZimMatchPrev'.s:el." :exe zim#util#line([{'default': line('.')},'".g:zim_matchable[s:el]."'],line('.')-1,-1)"
  endfor

  " Add next and prev matchable items to mappable actions (to use it as shortcut)
  for s:el in keys(g:zim_matchable)
    let g:zim_edit_actions['next'.s:el]={
          \'n': ":ZimMatchNext".s:el."<Cr>"
          \}
    let g:zim_edit_actions['prev'.s:el]={
          \'n': ":ZimMatchPrev".s:el."<Cr>"
          \}
  endfor

  " add key mappings
  for l:k in keys(g:zim_edit_actions)
    if has_key(g:zim_keymapping,l:k)
      for l:m in keys(g:zim_edit_actions[l:k])
        exe l:m.'noremap <buffer> '.g:zim_keymapping[l:k].' '.g:zim_edit_actions[l:k][l:m]
      endfor
    endif
  endfor
  let l:i=line('.')
  if l:i == 1
    let l:i=zim#util#line(g:zim_open_jump_to, 1, 1)
  endif
  if l:i == 1 && g:zim_open_skip_header
    while getline(l:i) =~ 
          \ '^\(Content-Type\|Wiki-Format\|Creation-Date\):'
      let l:i+=1
    endwhile
  endif
  exe l:i
endfu

autocmd! Filetype zim call s:setBufferSpecific()
