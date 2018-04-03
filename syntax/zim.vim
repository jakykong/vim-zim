" Zim syntax highlighting
" Author: Jack Mudge <jakykong@theanythingbox.com>
" * I declare this file to be public domain.
"
" Changelog:
" 2016-09-12 - Jack Mudge - v0.1
"   * Initial creation
" 2017-05-30 - Luffah - v0.3
"   * More detailled syntax
"
" Simple syntax file, assumes all mime-type lines are part of the header
" (TODO: Improve this to make sure they're at the beginning of the file only)
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

"syn case ignore

" Zim Header
syn match zimHeader /^\(Content-Type\|Wiki-Format\|Creation-Date\):\(.*\)\@=\c/ contained
syn region zimHeaderRegion
      \ start=/^\(Content-Type\|Wiki-Format\|Creation-Date\):\%1l\c/
      \ end=/^\([^CW].*\|\)$\c/
      \ contains=zimHeader
      \ transparent fold
      \ keepend extend
highlight link zimHeader LineNr

" Titles (h1 to h5)
syn match Title /^\(=\+\).*\1$/

" Links
syn match Identifier /\[\[.*\]\]/

" Checkbox
syn match zimCheckbox /^\(\s\{4}\)*\[[ ]\]\(\s\|$\)/
syn match zimYes /^\(\s\{4}\)*\[\*\]\(\s\|$\)/
syn match zimNo  /^\(\s\{4}\)*\[x\]\(\s\|$\)/
highlight zimCheckbox gui=bold guifg=black guibg=#dcdcdc term=bold ctermfg=0 ctermbg=7
highlight zimYes gui=bold guifg=#65B616 guibg=#dcdcdc term=bold ctermfg=2 ctermbg=7
highlight zimNo  gui=bold guifg=#AF0000 guibg=#dcdcdc term=bold ctermfg=1 ctermbg=7

" Lists
syn match ZimBulletItem /^\(\s\{4}\|\t\)*\*\(\s\|$\)/
syn match ZimNumberedItem /^\(\s\{4}\|\t\)*\d\+\.\(\s\|$\)/
"highlight zimBulletItem gui=bold guifg=black guibg=#f4f4f4 term=bold ctermfg=0
hi link ZimBulletItem Special 
hi link ZimNumberedItem Special 

" Style : bold
syn match zimBold /\*\*.*\*\*/
highlight zimBold gui=bold term=standout cterm=bold

" Style : italic
syn match zimItalic +//.*//+
highlight zimItalic gui=italic cterm=italic

" Style : hightlighted
syn match zimHighlighted /__.*__/
highlight link zimHighlighted DiffChange 

" Style : strikethrough
syn match zimStrikethrough /\~\~.*\~\~/
highlight link zimStrikethrough NonText


"" Next style definitions are based on the fork of YaoPo Wang <blue119@gmail.com>
"" which include joanrivera vim-zimwiki-syntax <joan.manuel.rivera+dev@gmail.com>
"" https://github.com/joanrivera/vim-zimwiki-syntax (MIT Licence)
" Style : code
syn region zimwikiCode start="'''" end="'''"
hi def link zimwikiCode	SpecialComment

" Style : sub and sup
syn match zimwikiSub '_{.\{-1,}}'
syn match zimwikiSup '\^{.\{-1,}}'
hi def link zimwikiSub	Number
hi def link zimwikiSup	Number

" Style : image
syn match zimwikiImage '{{.\{-1,}}}'
hi def link zimwikiImage Float

" Line
syn match zimHorizontalLine /^\(-\{20}\)$/
hi link zimHorizontalLine Underlined


" Code Block
highlight link zimHeader LineNr


fu! s:activate_codeblock()
  " generate by :read!%:p:h/getsourcesfiletype.py
  let l:languages = {"java" : "java","dtd" : "dtd","lua" : "lua",".desktop" : "desktop","gtkrc" : "gtkrc","r" : "r","html" : "html","m4" : "m4","javascript" : "javascript","xml" : "xml","ruby" : "ruby","c" : "c","xslt" : "xslt","c++" : "cpp","sh" : "sh",".ini" : "dosini","awk" : "awk","perl" : "perl","css" : "css","cmake" : "cmake","diff" : "diff","changelog" : "changelog","gettext-translation" : "po","python" : "python","sql" : "sql","php" : "php"}

  for l:i in keys(l:languages)
    let l:l = l:languages[l:i]
    let b:current_syntax=''
    unlet b:current_syntax
    exe 'syn include @zimcodeblock'.l:l.' syntax/'.l:l.'.vim contained'
    exe 'syn region zimCodeBlock'.l:l.' start=|lang="'.l:i.'".*$|ms=e+1'.
          \' end=|^}}}|me=e-3 contained contains=@zimcodeblock'.l:l
  endfor
  syn region zimCodeBlock
        \ start="^{{{code: " end="^}}}"
        \ transparent keepend contains=@NoSpell,ZimCodeBlock.*
endfu
call s:activate_codeblock()


let b:current_syntax = "zim"
