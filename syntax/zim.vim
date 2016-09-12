" Zim syntax highlighting
" Author: Jack Mudge <jakykong@theanythingbox.com>
" * I declare this file to be public domain.
"
" Changelog:
" 2016-09-12 - Jack Mudge - v0.1
"   * Initial creation
"
" Simple syntax file, assumes all mime-type lines are part of the header
" (TODO: Improve this to make sure they're at the beginning of the file only)

syn case ignore

syn match zmFHdr /^\(Content-Type\|Wiki-Format\|Creation-Date\):.*$/
highlight zmFHdr gui=italic

syn match zmWHdr /^\(=\+\).*\1$/
highlight zmWHdr gui=bold

syn match zmWBld /\*\*.*\*\*/
highlight zmWBld gui=bold

syn match zmWItl +//.*//+
highlight zmWItl gui=italic

syn match zmBullet /^\s*\(\[[* ]\]\|\*\)\(\s\|$\)/
highlight zmBullet gui=bold

syn match zmWHlt /__.*__/
highlight zmWHlt gui=inverse

syn match zmWStr /~~.*~~/
highlight zmWStr gui=underline



