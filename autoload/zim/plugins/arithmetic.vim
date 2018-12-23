" Copyright (C) 2018  luffah <luffah@runbox.com>
" Author: luffah <luffah@runbox.com>
"
" This program is free software: you can redistribute it and/or modify
" it under the terms of the GNU General Public License as published by
" the Free Software Foundation, either version 3 of the License, or
" (at your option) any later version.
"
" This program is distributed in the hope that it will be useful,
" but WITHOUT ANY WARRANTY; without even the implied warranty of
" MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
" GNU General Public License for more details.
"
" You should have received a copy of the GNU General Public License
" along with this program.  If not, see <http://www.gnu.org/licenses/>.

" Wrapper for Zim plugin Arithmetic
fu! zim#plugins#arithmetic#processfile(...)
  let l:curbuf=bufnr('%')
  if len(a:000) > 0
    if a:000[0] ~= '^\d\+$'
      let l:buf == str2nr(a:000[0])
      if !bufexists(l:buf)
        throw "the buffer doesn't extist"
      endif
    endif
  else
    let l:buf=l:curbuf
  endif
  let l:pyfile=g:zim_python_path.'/inc/arithmetic.py'
  if filereadable(l:pyfile)
    if l:curbuf != l:buf
      call execute('buffer '.l:buf)
    endif
    let l:file=shellescape(expand('%'))
    if len(l:file)
      let l:file=shellescape(expand('%:p'))

      silent! let l:lines = systemlist('echo << EOF | python '.
            \ l:pyfile.' -f '.l:file."  2> /dev/null")
      while len(l:lines) != 0 && l:lines[0] =~ '^eval error:'
        cal remove(l:lines,0)
      endwhile

      %delete
      call setline(1,l:lines)
    else
      echo "Buffer shall be linked to an existing file to use Zim plugins." 
    endif
    if l:curbuf != l:buf
      call execute('buffer '.l:curbuf)
    endif
  else
    echomsg l:pyfile." not found"
  endif
endfu
