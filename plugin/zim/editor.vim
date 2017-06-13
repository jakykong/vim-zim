
"" Create Zim header in a buffer, i.e., for a new file
"" If files are created within Zim, this is already completed
function! zim#editor#CreateHeader()
    if (  getline(1) =~ "Content-Type: text/x-zim-wiki"
          \ && getline(2) =~ "Wiki-Format:" )
      echomsg zim#util#gettext("Zim Header already exists")
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
      let l:note_name=input( zim#util#gettext('note_name').' ? ')
    endif
    let l:header=[
          \ "Content-Type: text/x-zim-wiki",
          \ "Wiki-Format: zim " . g:zim_wiki_version ,
          \ "Creation-Date: " . l:timest1 . l:timest2,
          \ "",
          \ "====== ".l:note_name." ======"
          \]
    call append(0,l:header)
endfunction

"" Make a title with the current line
function! zim#editor#Title()
  let l:i=line('.')
  echomsg zim#util#gettext("title_level")." ? "
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

"" Set the bullet (list or checkbox) for the current line
" @param string bul The bullet : **; [ ]...
function! zim#editor#Bullet(bul)
  call setline('.',
        \ substitute(getline('.'),'^\(\s*\)\(\[.\]\)\?\(*\)\?\s*','\1'.a:bul.' ',''))
endfu

"" Get the bullet (list, numbered list, checkbox) for the next line
"" given the current line
function! zim#editor#NextBullet(l)
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

function! zim#editor#JumpToLinkUnderCursor()
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

"" Insert bullet if we are at the end of the string, else split line
"" the cr substitute char is needed in order to mark the line return
"" before calling this function
function! zim#editor#CR(cr)
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
    put=zim#editor#NextBullet(l:b).' '
    normal $
  endif
endfu

"" Add format elements around a string
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

"" Toogle format elements on a line
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

"" Tooggle style on the current line
" @param string style The opening & ending element (used for bold, italic...)
function! zim#editor#ToggleStyle(style)
  call s:doZimToggleStyle(a:style,a:style,line('.'))
endfu

"" Tooggle style on the selected words
"" if selection is on 1 line toggle from cursor start to end,
"" else toggle style line by line
" @param string style The opening & ending element (used for bold, italic...)
function! zim#editor#ToggleStyleBlock(style)
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

