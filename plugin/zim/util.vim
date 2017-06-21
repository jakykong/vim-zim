
"" Get the translation of string
function! zim#util#gettext(k)
  return  get(get(g:zim_wiki_prompt, g:zim_wiki_lang, g:zim_wiki_prompt['en']),
        \  a:k, a:k )
endfu


"" Completion function for commands
function! zim#util#_CompleteNotes(A,L,P)
  let l:dir=substitute(g:zim_notebook,'[/]*$','/','g')
  return map(
        \globpath(l:dir, a:A.'*', 0, 1),
        \'strpart(v:val,len(l:dir)).(isdirectory(v:val)?"/":"")'
        \)
endfunction

function! zim#util#_CompleteBook(A,L,P)
  let l:dir=substitute(g:zim_notebooks_dir,'[/]*$','/','g')
  return map(
        \filter(globpath(l:dir, a:A.'*', 0, 1),'isdirectory(v:val)'),
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
function! zim#util#line(goto_instrs)
  let l:i=1
  let l:step=1
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
      if has_key(l:j, 'get') | let l:mem[l:j['get']]=l:i | endif
      if has_key(l:j, 'set') | let l:i=l:mem[l:j['set']] | endif
      if has_key(l:j, 'init') | let l:i=line(l:j['init']) | endif
      if has_key(l:j, 'sens') | let l:step=(l:j['sens']==0?1:l:j['sens']) | endif
    else
      while l:i > 0 && l:i <= l:e && getline(l:i) !~ l:j
        let l:i+=l:step
      endwhile
    endif
    if l:i <= 0 | let l:i = 1 | break | endif
    if l:i > l:e | let l:i = l:e | break | endif
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
