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
      \   'i' : '<Esc>:call ZimCR()<Cr>a'
      \ },
      \ 'continue_list':{
      \   'n' : ':put=ZimNextBullet()<Cr>$a'
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

function! s:setKeymappings()
  for l:k in keys(g:zim_edit_actions)
    if has_key(g:zim_keymapping,l:k)
      for l:m in keys(g:zim_edit_actions[l:k])
        exe l:m.'noremap <buffer> '.g:zim_keymapping[l:k].' '.g:zim_edit_actions[l:k][l:m]
      endfor
    endif
  endfor
endfu
autocmd! Filetype zim call s:setKeymappings()

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
        \ substitute(getline('.'),'^\(\s*\)\(\[.\]\)\?\(*\)\?','\1'.a:bul,''))
endfu

" Get the bullet (list, numbered list, checkbox) for the next line
" given the current line
function! ZimNextBullet()
  let l:l=getline('.')
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

" Insert bullet if we are at the end of the string, else split line
function! ZimCR()
  let l:pos=col('.')
  let l:eol=col('$')
  if l:pos >= (l:eol-1)
    put=ZimNextBullet()
    normal $
  else 
    " equivalent to norm <C-j>
    let l:l=getline('.')
    let l:end=strpart(l:l, l:pos)
    call setline('.',strpart(l:l,0,l:pos))
    put=l:end
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
