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

syn case ignore

" Zim Header
syn match zimHeader /^\(Content-Type\|Wiki-Format\|Creation-Date\):\(.*\)\@=/ contained
syn region zimHeaderRegion start="^\(Content-Type\|Wiki-Format\|Creation-Date\):\%1l" end="^\([^CWM].*\|\)$" contains=zimHeader keepend
highlight link zimHeader LineNr

" Titles (h1 to h5)
syn match Title /^\(=\+\).*\1$/

" Links
syn match Identifier /\[\[.*\]\]/

" Checkbox
syn match zimCheckbox /^\(\s\{4}\)*\[[ ]\]\(\s\|$\)/
syn match zimYes /^\(\s\{4}\)*\[[\*]\]\(\s\|$\)/
syn match zimNo  /^\(\s\{4}\)*\[[x ]\]\(\s\|$\)/
highlight zimCheckbox gui=bold guifg=black guibg=#cccccc term=bold ctermfg=0
highlight zimYes gui=bold guifg=darkgreen guibg=#cccccc term=bold ctermfg=2
highlight zimNo  gui=bold guifg=darkred guibg=#cccccc term=bold ctermfg=8

" Bullet
syn match ZimBullet /^\(\s\{4}\)*\*\(\s\|$\)/
highlight zimBullet gui=bold guifg=black guibg=#cccccc term=bold ctermfg=0

" Style : bold
syn match zimBold /\*\*.*\*\*/
highlight zimBold gui=bold term=bold

" Style : italic
syn match zimItalic +//.*//+
highlight zimItalic gui=italic

" Style : hightlighted
syn match zimHighlighted /__.*__/
highlight link zimHighlighted DiffChange 

" Style : strikethrough
syn match zimStrikethrough /\~\~.*\~\~/
highlight link zimStrikethrough NonText




