" Zim Utilities Plugin
" Author: Jack Mudge <jakykong@theanythingbox.com>
" * I declare this file to be in the public domain.
"
" Last Change:	2017 May 25
" Maintainer: Luffah <luffah@runbox.com>
" Version: 0.2
"
" Changelog:
" 2016-09-12 - Jack Mudge - v0.1
"   * Initial creation.
" 2017-05-25 - luffah - v0.2
"   * Mod. CreateZimHeader 
"      + minimal support of Linux strftime() + automatic title
"   * Keymappings
"      + limited to zim buffers + stored in g:zim_keymapping
"   * Add a gettext like function
"   * In insert mode : add bullet, numbering, or checkbox
"     on <CR> with the result of ZimNextBullet
"
" Provides shortcuts and helpful mappings to work with Zim wiki formatting.
" This is primarily intended for using the 'Edit Source' functionality in
" Zim, but may be useful to create new files in a Zim folder.
"
" Known Bugs:
" * Zim issue: New files aren't shown in Zim index until restart of zim.
" * Doesn't correctly add bullets, numbering, or checkboxes on <CR> from
"   visual mode
"
" Example configuration :
" let g:zim_keymapping=
"       \{
"       \ 'continue_list':'<CR>',
"       \'bold':'<Leader>b',
"       \'italic':'<Leader>i',
"       \'highlight':'<Leader>h',
"       \'strike':'<Leader>s',
"       \'title':'<Leader>h',
"       \'header':'<Leader>H',
"       \'li':'<Leader>l',
"       \'checkbox':'<Leader>c',
"       \'checkbox_yes':'<Leader>y',
"       \'checkbox_no':'<Leader>n'
"       \}
" set rtp+=/path/to/zim.vim

"'"'""'"'"'"'"'"'"'"'"'"'"'"'"'"
""
"  PARAMETRIC PART
"

""
" Actions
"
let g:zim_edit_actions=get(g:,'zim_edit_actions', {
      \ '<cr>':{
      \   'i' : '<bar><Esc>:call ZimCR("<bar>")<Cr>i'
      \ },
      \ 'jump':{
      \   'n' : ':call ZimJumpToLinkUnderCursor()<Cr>'
      \ },
      \ 'jump_back':{
      \   'n' : ':exe "buffer ".b:zim_last_backlink <Cr>'
      \ },
      \ 'continue_list':{
      \   'n' : ':put=ZimNextBullet(getline("."))<Cr>$a'
      \ },
      \ 'bold':{
      \   'v': ':call ZimToggleStyleBlock("**")<CR>',
      \   'n': ':call ZimToggleStyle("**")<CR>'
      \ },
      \  'highlight':{
      \   'v': ':call ZimToggleStyleBlock("__")<CR>',
      \   'n': ':call ZimToggleStyle("__")<CR>'
      \ },
      \ 'strike': {
      \   'v':  ':call ZimToggleStyleBlock("~~")<CR>',
      \   'n':  ':call ZimToggleStyle("~~")<CR>'
      \ },
      \ 'title': {
      \   'n':  ':call ZimTitle()<CR>'
      \ },
      \ 'italic': {
      \   'v' : ':call ZimToggleStyleBlock("//")<CR>',
      \   'n' : ':call ZimToggleStyle("//")<CR>'
      \ },
      \ 'header': {
      \   'n':  ':call CreateZimHeader()<CR>'
      \  },
      \ 'all_checkbox_to_li': {
      \   'n': ':%s/^\(\s*\)\[ \]/\1*/<cr>'
      \  },
      \ 'li': {
      \   'n': ":call ZimBullet('*')<cr>"
      \ },
      \ 'checkbox': {
      \   'n': ":call ZimBullet('[ ]')<cr>"
      \ },
      \ 'checkbox_yes': {
      \   'n': ":call ZimBullet('[*]')<cr>"
      \ },
      \ 'checkbox_no': {
      \   'n': ":call ZimBullet('[x]')<cr>" 
      \ }
      \})

""
" Default keymapping
"
let g:zim_keymapping=get(g:,'zim_keymapping', {
      \ '<cr>':'<CR>',
      \ 'continue_list':'<Leader><CR>',
      \ 'jump':'<Leader>g',
      \ 'jump_back':'<Leader>G',
      \ 'bold':'<Leader>wb',
      \ 'italic':'<Leader>wi',
      \ 'highlight':'<Leader>wh',
      \ 'strike':'<Leader>ws',
      \ 'title':'<Leader>wt',
      \ 'header':'<Leader>wH',
      \ 'all_checkbox_to_li':'<F8>',
      \ 'li':'<Leader>wl',
      \ 'checkbox':'<Leader>wc',
      \ 'checkbox_yes':'<F12>',
      \ 'checkbox_no':'<S-F12>'
      \ })


" You can choose where to begin note editing
" skip header
let g:zim_open_skip_header=1

" Succession of movements to determine the cursor position on openning.
" It make possible cheaty movements,as might be in French Unemployment Agency. 
" Given the cursor at the first line, you can say go forward to 'Title 4';
"  'no, at the begining of the file ('.'); 'Title 3'; '10 line before';
"  'foo'; 'from now you go backward when you search';
"  'Title 3'; 'tofu'
"
" Here the syntax.
" dict    { 'init': line_position init, 'sens' : (-1 or 1) for searching text pattern }
" string  text pattern  e.g. Creation
" integer line delta  e.g. -1 to go back 1 line
" integer line delta  e.g. -1 to go back 1 line
"
" Go to the last title and jump 2 line 
let g:zim_open_jump_to=[{'init': '$', 'sens': -1}, "==.*==", 2]

" Go to the first title and jump 2 line after
" let g:zim_open_jump_to=["==.*==", 2]

function! s:setBufferSpecific()
  " set buffer properties
  setlocal tabstop=4
  setlocal softtabstop=4
  setlocal shiftwidth=4
  
  " add key mappings
  for l:k in keys(g:zim_edit_actions)
    if has_key(g:zim_keymapping,l:k)
      for l:m in keys(g:zim_edit_actions[l:k])
        exe l:m.'noremap <buffer> '.g:zim_keymapping[l:k].' '.g:zim_edit_actions[l:k][l:m]
      endfor
    endif
  endfor
  
  " add commamds
  command! -buffer -nargs=* ZimGrepThis :call ZimSearchInNotebook(expand('<cword>'))
  command! -buffer -nargs=* ZimListThis :call ZimListNotes(g:zim_notebook,expand('<cword>'))
  
  let l:i=line('.')
  let l:step=1
  if l:i == 1
    let l:e=line('$')
    for l:j in g:zim_open_jump_to
      if type(l:j) == type(0)
        let l:i+=l:j
      elseif type(l:j) == type({})
        if has_key(l:j, 'init') | let l:i=line(l:j['init']) | endif
        if has_key(l:j, 'sens') | let l:step=l:j['sens'] | endif
      else
        while l:i > 0 && l:i <= l:e && getline(l:i) !~ l:j
          let l:i+=l:step
        endwhile
      endif
      if l:i <= 0 | let l:i = 1 | break | endif
      if l:i > l:e | let l:i = l:e | break | endif
		  unlet l:j  " E706 without this
    endfor
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

"'"'""'"'"'"'"'"'"'"'"'"'"'"'"'"
""
" FUNCTIONNAL PART
"
let g:zim_wiki_format=get(g:,'zim_wiki_format','zim 0.4')

""
" Messages
"
let g:zim_wiki_lang=get(g:,'zim_wiki_lang','fr')
let s:zim_wiki_prompt={
      \ 'en' : { 'note_name' : 'Name of the new note',
      \          'title_level': "Title level (between 1 and 5 , else remove style)"
      \        },
      \ 'fr' : { 'note_name' : 'Nom de la nouvelle note',
      \          'title_level': "Niveau de titre (de 1 à 5 , sinon retire le style)",
      \          'Zim Header already exists' : "Le fichier présente déja une entète Zim"
      \        }
      \}
" Get the translation of string
function! s:gettext(k)
  return  get(get(s:zim_wiki_prompt, g:zim_wiki_lang, s:zim_wiki_prompt['en']),
        \  a:k, a:k )
endfu

" Create Zim header in a buffer, i.e., for a new file
" If files are created within Zim, this is already completed
function! CreateZimHeader()
    if (  getline(1) =~ "Content-Type: text/x-zim-wiki"
          \ && getline(2) =~ "Wiki-Format:" )
      echomsg s:gettext("Zim Header already exists")
      return
    endif
    let l:timest1 = strftime("%Y-%m-%dT%H:%M:%S")
    if has("win32")
        " Microsoft screwed with strftime() sot that %z returns a description of the time zone. BOOOO Microsoft.
        " This calculation converts that to the appropriate numeric representation. (Only for PST/PDT.)
        if strftime("%z") == "Pacific Standard Time"
            let l:timest2 = "-08:00"
        elseif strftime("%z") == "Pacific Daylight Time"
            let l:timest2 = "-07:00"
        else
            throw "Unknown Time Zone: " . strftime("%z")
        endif
    else
        let l:timest2 = substitute(strftime("%z"),'\(+\d\d\)\(\d\d\)','\1:\2','')
    endif
    let l:note_name=substitute(expand('%:t:s?.txt??'),'_',' ','g')
    if empty(l:note_name)
      let l:note_name=input( s:gettext('note_name').' ? ')
    endif
    let l:header=[
          \ "Content-Type: text/x-zim-wiki",
          \ "Wiki-Format: " . g:zim_wiki_format ,
          \ "Creation-Date: " . l:timest1 . l:timest2,
          \ "",
          \ "====== ".l:note_name." ======"
          \]
    call append(0,l:header)
endfunction

" Make a title of the current line
function! ZimTitle()
  let l:i=line('.')
  echo s:gettext("title_level")." ? "
  let l:lvl=nr2char(getchar())
  redraw
  if exists('l:lvl') 
    let l:l=getline(l:i)
    let l:anystyle_before='^\s*\(===*\)\?\(\*\*\?\)\?\(\[.\]\)\?\s*'
    let l:anystyle_after='\s*\(===*\)\?\(\*\*\)\?\s*$'
    let l:l=substitute(l:l, l:anystyle_before,'','') 
    let l:l=substitute(l:l, l:anystyle_after,'','')
    if l:lvl =~ '\d'
      let l:titlemark=repeat("=",(7-l:lvl))
      let l:l=l:titlemark.' '.l:l.' '.l:titlemark
    endif
    call setline(l:i,l:l)
  endif
endfu

" Set the bullet (list or checkbox) for the current line
" @param string bul The bullet : **; [ ]...
function! ZimBullet(bul)
  call setline('.',
        \ substitute(getline('.'),'^\(\s*\)\(\[.\]\)\?\(*\)\?\s*','\1'.a:bul.' ',''))
endfu

" Get the bullet (list, numbered list, checkbox) for the next line
" given the current line
function! ZimNextBullet(l)
  let l:l=a:l
  let l:pos=match(l:l,'\h')
  if l:pos > -1
    let l:l=strpart(l:l,0,l:pos)
    let l:pos=match(l:l,'\S')
    let l:ret=strpart(l:l,0,l:pos)
    let l:l=strpart(l:l,l:pos)
    if l:pos > -1
      if l:l =~ '\d\.'
        let l:ret.=substitute(l:l,'\(\d\)\(.\D\)','\=(submatch(1)+1).submatch(2)','')
      else
        let l:ret.=l:l
      endif
    endif
  else
    let l:ret=""
  endif
  return l:ret
endfu

function! s:getLinkPath(tgt)
  let l:tgt=''
  if len(a:tgt)
    let l:tgt=substitute(
          \ substitute(a:tgt,':','/','g'),
          \ ' ','_','g').'.txt'
    let l:notebook=expand('%:p:s?'.g:zim_notebooks_dir.'[/]*??:s?/.*$??')
    let l:tgt=g:zim_notebooks_dir.'/'.l:notebook.'/'.l:tgt
  endif
  return l:tgt
endfunction

function! s:getLinkUnderCursor()
  let l:pos=col('.')
  let l:l=getline('.')
  let l:matches=[]
  let l:tgt=''
  let l:prev=0
  let l:b=match(l:l, '\[\[.*\]\]',l:prev)
  let l:e=(l:b > -1) ? match(l:l, '\(\]\]\||\)', l:b) : -1
  while l:e > -1
    if l:pos >= l:b && l:pos <= l:e
      let l:tgt=strpart(l:l, l:b+2, l:e-l:b-2)
      break
    endif
    let l:b=match(l:l, '\[\[.*\]\]',l:prev)
    let l:e=(l:b > -1) ? match(l:l, '\(\]\]\||\)', l:b) : -1
  endwhile
  return s:getLinkPath(l:tgt)
endfunction

function! ZimJumpToLinkUnderCursor()
  let l:path=s:getLinkUnderCursor()
  let l:self=expand('%:p')
  if len(l:path) || len(a:edit_cmd)
     if bufexists(l:path)
       exe 'buffer '.l:path
     else
       exe 'e '.l:path
     endif
  endif
  let b:zim_last_backlink=l:self
endfunction

" Insert bullet if we are at the end of the string, else split line
" the cr substitute char is needed in order to mark the line return
" before calling this function
function! ZimCR(cr)
  let l:pos=col('.')
  let l:l=getline('.')
  if a:cr
    let pos=match(l:l,a:cr,l:pos-2)
  endif
  let l:b=strpart(l:l, 0, l:pos-1)
  let l:e=substitute(strpart(l:l, l:pos),'\s*$','','')
  call setline('.',l:b)
  if len(l:e)
    put=l:e
  else
    put=ZimNextBullet(l:b).' '
    normal $
  endif
endfu

" Add format elements around a string
" @param string bstyle The opening element 
" @param string estyle The ending element
" @param int    begin  The start position of the string to format in the line
" @param int    end    The end position of the string to format in the line
" @param int    lnum   Line number
function! s:doZimSetStyle(bstyle,estyle,begin,end,lnum)
  let l:l=getline(a:lnum)
  let l:l=strpart(l:l, 0, a:begin).
        \ a:bstyle. strpart(l:l, a:begin, a:end - a:begin).
        \ a:estyle. strpart(l:l, a:end)
  call setline(a:lnum,l:l)
endfu

" Toogle format elements on a line
" @param string bstyle The opening element
" @param string estyle The ending element
" @param int    lnum   Line number
function! s:doZimToggleStyle(bstyle,estyle,lnum)
  let l:l=getline(a:lnum)
  let l:bstyle=substitute(a:bstyle,'[*~/]','\\\0','g')
  let l:estyle=substitute(a:estyle,'[*~/]','\\\0','g')
  if match(l:l,l:bstyle.'.*'.l:estyle)>-1
    call setline(a:lnum,substitute(l:l,l:bstyle.'\(.*\)'.l:estyle,'\1',''))
  else
    let l:begin=match(l:l,'\]')
    if l:begin>-1
      let l:begin=match(l:l,'\w',l:begin)
    else
      let l:begin=match(l:l,'\w')
    endif
    if l:begin>-1
      let l:end=match(l:l,'\s*$')
      call s:doZimSetStyle(a:bstyle, a:estyle , l:begin, l:end, a:lnum)
    endif
  endif
endfu

" Tooggle style on the current line
" @param string style The opening & ending element (used for bold, italic...)
function! ZimToggleStyle(style)
  call s:doZimToggleStyle(a:style,a:style,line('.'))
endfu

" Tooggle style on the selected words
" if selection is on 1 line toggle from cursor start to end,
" else toggle style line by line
" @param string style The opening & ending element (used for bold, italic...)
function! ZimToggleStyleBlock(style)
  norm gv
  let [ l:l1, l:l2, l:c1, l:c2]=[line('.'), line('v'),col('.'), col('v')]
  let [ l:l1, l:l2 ] = l:l1>l:l2 ? [l:l2,l:l1] : [l:l1,l:l2]
  let [ l:c1, l:c2 ] = l:c1>l:c2 ? [l:c2,l:c1] : [l:c1,l:c2]
  let l:style=substitute(a:style,'[*~/]','\\\0','g')
  if l:l1 == l:l2
    let l:l = getline(l:l1)
    let l:part1=strpart(l:l,0,l:c1-1)
    let l:part2=strpart(l:l,l:c1-1,1+l:c2-l:c1)
    let l:part3=strpart(l:l,l:c2)
    call setpos('.',[0,l:l1,l:c1,0])
    if match(l:l,l:style.'.*'.l:style)>-1
      let l:part2=substitute(l:part2, l:style,'','g')
      let l:c2-=(2*len(a:style))
    else
      let l:part2= a:style.l:part2.a:style
      let l:c2+=(2*len(a:style))
    endif
    call setline(l:l1,l:part1.l:part2.l:part3)
    call setpos('.',[0,l:l1,l:c1,0])
    norm o
    call setpos('.',[0,l:l1,l:c2,0])
  else
    for l:i in getline(l:l1,l:l2)
      call s:doZimToggleStyle(a:style,a:style,line('.'))
    endfor
  endif
endfu

""" The next functions are for notebook navigation
let g:zim_notebook=get(g:,'zim_notebook',g:zim_notebooks_dir)

" Easily change g:zim_notebook
function! ZimSelectNotebook()
  new | set buftype=nowrite ft=zimindex | setlocal nowrap cursorline
  call setline(1, [ g:zim_notebooks_dir ]+
        \ filter(
        \ split(globpath(g:zim_notebooks_dir,'*'),"\n"),
        \ 'isdirectory(v:val)')
        \)
  nnoremap <buffer> <cr> :exe "let g:zim_notebook='".getline('.')."'"<cr>:q<cr>
  nnoremap <buffer> q :q<cr>
endfunction

""
" List notes on the directory, with a filter 
"
function! s:ZimListNotes(dir,filter)
  let l:ret=[]
  for l:i in split(globpath(a:dir,'*'),"\n")
      if isdirectory(l:i)
        call extend(l:ret ,s:ZimListNotes(l:i,a:filter))
      else
        let l:i=substitute(l:i,g:zim_notebook.'/*','','')
        if l:i =~ a:filter
          call add(l:ret, substitute(l:i, '/', ' : ', 'g'))
        endif
      endif
  endfor
  return l:ret
endfunction

function! ZimListNotes(dir,...)
  let l:filter=""
  if len(a:000) && len(a:1)
    let l:filter=a:1
  endif
  tabnew | set buftype=nowrite ft=zimindex | setlocal nowrap cursorline

  "" Openning the file in a vertical new slit (vnew) on Return:
  "  nnoremap <buffer> <cr> :vnew ~/Notebooks/Notes/note.txt)<cr>
  " + note.txt path shall be computed on Return key
  "  nnoremap <buffer> <cr> :exe 'vnew '.a:dir.'/'.substitute(getline('.'),' : ','/','g')<cr>
  " + a:dir shall be computed now
  exe "nnoremap <buffer> <cr> :exe 'vnew ".a:dir."/'.substitute(getline('.'),' : ','/','g')<cr>"
  nnoremap <buffer> q :q<cr>
  call setline(1,
        \ ['<cr> -> '.s:gettext('Open note'),
        \  '  q -> '.s:gettext('Close this window'),
        \  '-------------------------------------'] +
        \ s:ZimListNotes(a:dir, l:filter)
        \ )
  4
endfunction

function! ZimSearchInNotebook(arg)
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

command! -nargs=* ZimGrep :call ZimSearchInNotebook(<q-args>)
command! -nargs=* ZimList :call ZimListNotes(g:zim_notebook,<q-args>)
command! ZimSelectNotebook :call ZimSelectNotebook()
