" Zim Index syntax  highlighting  (for Zim.vim plugin)
" Author: luffah
" cc0
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

syn case ignore

" Zim Header
"syn region zimIndexHeaderRegion start="^:\%1l" end="^\(---.*\|\)$" contains=zimIndexHeader keepend

" Style : hightlighted
syn match MoreMsg /.*\( -> .*\)\@=/
"syn match Directory /.* :/
"syn match Title /[^: ]*\.txt$/
syn match TODO /[^: ]*\.txt /
" Style : strikethrough
"syn match zimStrikethrough /\~\~.*\~\~/
"highlight link zimStrikethrough NonText


let b:current_syntax = "zimindex"
