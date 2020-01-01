
"" Get the translation of string
function! zim#util#gettext(k)
  " let l:lang_prompt=get(g:zim_wiki_prompt, g:zim_wiki_lang, g:zim_wiki_prompt['en'])
  if has_key(g:zim_wiki_prompt,g:zim_wiki_lang)
    if has_key(g:zim_wiki_prompt[g:zim_wiki_lang],a:k)
       let l:ret = g:zim_wiki_prompt[g:zim_wiki_lang][a:k]
    elseif has_key(g:zim_wiki_prompt['en'],a:k)
       let l:ret = g:zim_wiki_prompt['en'][a:k]
    else
       let l:ret = a:k
    endif
  else
    let l:ret=get(g:zim_wiki_prompt['en'],a:k,a:k)
  endif
  return l:ret
endfu


"" Completion function for commands
function! zim#util#_CompleteNotes(A,L,P)
  if a:A =~ '^/'
    if a:A =~ '^'.g:zim_notebook
      if mode() == 'c'
        call feedkeys('e"'.substitute(a:L, g:zim_notebook.'/', '', '').'"')
      endif
      let l:a=substitute(a:A,'^'.g:zim_notebook.'/','','')
    else
      if mode() == 'c'
        call feedkeys(repeat("\b",len(a:A)))
      endif
      let l:a=''
    endif
  else
    let l:a=a:A
  endif
  let l:dir=substitute(g:zim_notebook,'[/]*$','/','')
  return map(
        \globpath(l:dir, l:a.'*\c', 0, 1),
        \'strpart(v:val,len(l:dir)).(isdirectory(v:val)?"/":"")'
        \)
endfunction

" # s:CloseLayerPrint() -> a short string to indicate the current layer
let s:compl_help_bufnr=0
let s:compl_related=0
fu! s:CloseCompletionHelp()
  if !empty(s:compl_help_bufnr)
    if s:is_compl_help_update
      " let s:is_compl_help_update=0
    else
      let l:winnr=bufwinnr(s:compl_help_bufnr)
      if l:winnr > 0
        exe l:winnr.'windo bd'
        let s:compl_help_bufnr=0
        redraw
      endif
    endif
  endif
endfu


" Layer Description
fu! s:CompletionHelp(lines)
  let s:is_compl_help_update=1
  if !empty(a:lines)
    if s:compl_help_bufnr 
      let l:winnr=bufwinnr(s:compl_help_bufnr)
      if l:winnr > 0
        exe l:winnr.'wincmd w'
        exe '%delete'
      endif
    else
      let s:compl_related=bufnr('%')
      au CmdwinLeave,BufEnter,CursorMoved <buffer> call s:CloseCompletionHelp()
      rightbelow split
      enew
      " redraw
      let s:compl_help_bufnr=bufnr('%')
      set buftype=nofile
      setlocal nowrap
      set ft=zimindex
      au BufEnter <buffer> call s:CloseCompletionHelp()
    endif
    let l:w=winwidth('%')
    let l:lines=[]
    let l:nline=printf("%-50s",a:lines[0])
    for l:i in a:lines[1:]
      if (len(l:nline . l:i) + 4) > l:w
        call add(l:lines,l:nline)
        let l:nline = printf("%-50s",l:i)
      else
        let l:nline.= '||' . printf("%-50s",l:i)
      endif
    endfor
    call add(l:lines,l:nline)
    if s:is_compl_help_update
      exe 'resize '.len(l:lines)
      call setline(1,l:lines)
      exe winbufnr(s:compl_related).'wincmd w'
    endif
  endif
  redrawstatus
  let s:is_compl_help_update=0
endfu

function! zim#util#_CompleteEditCmdI(A,L,P)
  let l:r=keys(filter(g:zim_edit_actions,'has_key(v:val,"n")'))
  let l:ret = sort((len(a:A) ? filter(l:r, 'v:val =~ "'.a:A.'.*\\c"') : l:r))
  if len(l:ret) == 1
    call s:CloseCompletionHelp()
  else
    silent! call s:CompletionHelp(map(copy(l:ret),'v:val." -> ".zim#util#gettext("?".v:val)'))
  endif
  return l:ret
endfunction

function! zim#util#_CompleteEditCmdV(A,L,P)
  let l:r=keys(filter(g:zim_edit_actions,'has_key(v:val,"v")'))
  return len(a:A) ? filter(l:r, 'v:val =~ "'.a:A.'*\\c"') : l:r
endfunction

function! zim#util#_CompleteBook(A,L,P)
  let l:a=substitute(a:A,'^'.g:zim_notebook,'','')
  let l:dir=substitute(g:zim_notebooks_dir,'[/]*$','/','')
  return map(
        \filter(globpath(l:dir, l:a.'*\c', 0, 1),'isdirectory(v:val)'),
        \'strpart(v:val,len(l:dir))."/"'
        \)
endfunction

"" Function to ease the placement of the windows from zimindex window
"whereopen contains commands to create split
"editopt   contains the commands like 'noswapfile' 
"focused   is a 0 or 1 value to say to focus on new buffer
"file      is the file full path
function! zim#util#open(whereopen,editopt,focused,file)
  if a:file =~ '/' && a:file !~ '>'
    let l:current_win=winnr()
    let l:ope=(bufexists(a:file)? 'buffer ' : a:editopt.' e ')
    if len(a:whereopen) | exe a:whereopen | endif
    exe l:ope.a:file
    set ft=zim
    if !a:focused
      exe l:current_win.'wincmd w'
    endif
  endif
endfunction

" Get the line number for a goto instruction set
" See: :help g:zim_open_jump_to
function! zim#util#line(goto_instrs, ...)
  let l:i=get(a:000,0,1)
  let l:step=get(a:000,1,1)
  let l:default=0
  let l:e=line('$')
  let l:scroll = {'top':'zt', 'center': 'zz', 'bottom': 'zb'}
  let l:mem = {}
  for l:j in a:goto_instrs
    if type(l:j) == type(0)
      let l:i+=l:j
    elseif type(l:j) == type({})
      if has_key(l:j, 'scroll')
        exe l:i
        let l:scr=l:j['scroll'] 
        if type(l:scr) != type([]) | let l:scr=[l:scr] | endif
        for l:s in l:scr
          if type(l:s) == type(0)
            exe 'normal! '.abs(l:s).''.(l:s>0 ? '':'')
          elseif has_key(l:scroll,l:s)
            exe 'normal! '.l:scroll[l:s]
          endif
        endfor
      endif
      if has_key(l:j, 'checkpoint') | let l:default=l:i | endif
      if has_key(l:j, 'get') | let l:mem[l:j['get']]=l:i | endif
      if has_key(l:j, 'set') | let l:i=l:mem[l:j['set']] | endif
      if has_key(l:j, 'init') | let l:i=line(l:j['init']) | endif
      if has_key(l:j, 'sens') | let l:step=(l:j['sens']==0?1:l:j['sens']) | endif
      if has_key(l:j, 'default') | let l:default=l:j['default'] | endif
    else
      "find a line matching the pattern
      while l:i > 0 && l:i <= l:e && getline(l:i) !~ l:j
        let l:i+=l:step
      endwhile
    endif
    if l:i <= 0 | let l:i = l:default ? l:default : 1 | break | endif
    if l:i >= l:e | let l:i = l:default ? l:default : l:e | break | endif
    unlet l:j  " E706 without this
  endfor
  return l:i
endfunction

"copy / move / rename files or directories interface
"be caution at moving file to file 
"              moving dir to dir
function! zim#util#move(src,tgt,copy,dir)
  if has('win32')
    let l:copy_cmd= a:copy? '!xcopy  %s %s /s /e' : '!move  %s %s /s /e'
  else
    let l:copy_cmd= a:copy? '!cp -'.(a:dir?'r':'').'T  %s %s' : '!mv  %s %s'  
  endif
  exe printf(l:copy_cmd,a:src,a:tgt)
endfunction

fu! s:prefeed(a)
  let l:ret=a:a
  let l:pf={ 'cr':"\n",'esc':"\e",'bs':"\b",'tab':"\t" }
  for l:i in keys(l:pf)
     let l:ret=substitute(l:ret, '<'.l:i.'>', l:pf[l:i],'g')
  endfor
  return l:ret
endfu

fu! zim#util#cmd(mode,cmd,show)
  if a:show && has_key(g:zim_keymapping, a:cmd)
    echo g:zim_keymapping[a:cmd]
    sleep 600ms
  endif
  if a:mode == 'n'
    silent! call feedkeys(s:prefeed(g:zim_edit_actions[a:cmd]['n']))
  elseif a:mode == 'v'
    silent! call feedkeys('gv'.s:prefeed(g:zim_edit_actions[a:cmd]['v']))
  elseif a:mode == 'i'
    silent! call feedkeys("".s:prefeed(g:zim_edit_actions[a:cmd]['n']))
  endif
endfu
