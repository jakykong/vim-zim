"" Create Zim header in a buffer, i.e., for a new file
"" If files are created within Zim, this is already completed
function! zim#editor#CreateHeader(...)
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
  let l:l=getline(l:i)
  let l:rec=0 " 0 -> nothing ; 1 -> do update and rec; 2 -> only do update
  if l:l =~ '^\s*\(=\)\+ '
    let l:pos=match(l:l,'=')
    let l:end=match(l:l,' ',l:pos)
    let l:lvl=7-(l:end-l:pos)
  else
    let l:lvl=1
  endif
  
  let l:anystyle_before='^\s*\(===*\)\?\(\*\*\?\)\?\(\[.\]\)\?\s*'
  let l:anystyle_after='\s*\(===*\)\?\(\*\*\)\?\s*$'
  let l:l=substitute(l:l, l:anystyle_before,'','') 
  let l:l=substitute(l:l, l:anystyle_after,'','')
  let l:titlemark=repeat("=",(7-l:lvl))
  let l:l=l:titlemark.' '.l:l.' '.l:titlemark
  call setline(l:i,l:l)
  redraw
  echomsg zim#util#gettext("title_level")." ? "
  let l:chr=getchar()
  redraw
  if l:chr == "\<Right>" 
    let l:lvl=min([5,1+l:lvl])
    let l:rec=1
  elseif l:chr == "\<Left>" 
    let l:lvl=max([1,l:lvl-1])
    let l:rec=1
  elseif l:chr == "\<Up>"
    norm O
  elseif l:chr == "\<Down>"
    norm o
  else
    let l:lvl=nr2char(l:chr)
    if l:lvl == 't' || l:chr == "\<Backspace>"
      let l:l=substitute(l:l, l:anystyle_before,'','') 
      let l:l=substitute(l:l, l:anystyle_after,'','')
      call setline(l:i,l:l)
    else
      let l:rec=2
    endif
  endif
  if (l:lvl =~ '\d') && l:rec
    let l:l=substitute(l:l, l:anystyle_before,'','') 
    let l:l=substitute(l:l, l:anystyle_after,'','')
    let l:titlemark=repeat("=",(7-l:lvl))
    let l:l=l:titlemark.' '.l:l.' '.l:titlemark
    call setline(l:i,l:l)
    redraw
  endif
  if l:rec == 1
    call zim#editor#Title()
  endif
endfu

"" Set the bullet (list or checkbox) for the current line
" @param string bul The bullet : **; [ ]...
function! zim#editor#Bullet(bul)
  call setline('.',
        \ substitute(getline('.'),'^\(\s*\)\(\[.\]\)\?\(*\)\?\s*','\1'.a:bul.' ',''))
endfu

function! zim#editor#BulletBulk(bul)
  norm gv
  let [ l:l1, l:l2]=[line('.'), line('v')]
  let [ l:l1, l:l2 ] = l:l1>l:l2 ? [l:l2,l:l1] : [l:l1,l:l2]
  let l:i=l:l1
  for l:l in getline(l:l1,l:l2)
    call setline(l:i,
          \ substitute(l:l,'^\(\s*\)\(\[.\]\)\?\(*\)\?\s*','\1'.a:bul.' ',''))
    let l:i+=1
  endfor
  exe ':'.l:l1
  exe 'norm '.(l:l2-l:l1).'V'
  norm gv
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
      if l:l =~ '\d\+\.'
        let l:ret.=substitute(l:l,'\(\d\+\)\(.\D\)','\=(submatch(1)+1).submatch(2)','')
      else
        let l:ret.=l:l
      endif
    endif
  else
    let l:ret=""
  endif
  return l:ret
endfu

"" Insert bullet if we are at the end of the string, else split line
"" the cr substitute char is needed in order to mark the line return
"" before calling this function
function! zim#editor#CR(cr)
  let l:pos=col('.')
  let l:l=getline('.')
  if a:cr
    let l:pos=match(l:l,a:cr,l:pos-2)
  endif
  let l:b=strpart(l:l, 0, l:pos-1)
  let l:e=substitute(strpart(l:l, l:pos),'\s*$','','')
  call setline('.',l:b)
  if len(l:e)
    put=l:e
  else
    if l:b =~ '='
      put=' '
    else
      put=zim#editor#NextBullet(l:b).' '
    endif
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
function! s:doZimToggleStyle(bstyle,estyle,lnum,lcontent,beginpos)
  let l:l=a:lcontent
  let l:bstyle=substitute(a:bstyle,'[*~/]','\\\0','g')
  let l:estyle=substitute(a:estyle,'[*~/]','\\\0','g')
  let l:end=match(l:l,'\%(\s\s\+\|[;,.)}>]\|\]\|\s*$\)',a:beginpos-1)
  let l:begin=match(l:l,l:bstyle.'.*'.l:estyle,a:beginpos-1-len(a:bstyle))
  if l:begin>-1 && l:begin < l:end
    let l:end=match(l:l,l:estyle,l:begin+len(a:bstyle))
    let l:l=strpart(l:l, 0, l:begin).
          \ strpart(l:l, l:begin+len(a:bstyle), l:end - l:begin - len(a:bstyle)).
          \ strpart(l:l, l:end+len(a:estyle))
     call setline(a:lnum, l:l)
  else
    let l:begin=match(l:l,'[0-9A-Za-z_éèêëàâäàôöóòíìïîüûúù]',a:beginpos-1)
    if l:begin>-1
      let l:end=match(l:l,'\%(\s\s\+\|[;,.)}>]\|\]\|\s*$\)',l:begin)
      call s:doZimSetStyle(a:bstyle, a:estyle , l:begin, l:end, a:lnum)
    endif
  endif
endfu

"" Tooggle style on the current line
" @param string style The opening & ending element (used for bold, italic...)
function! zim#editor#ToggleStyle(style)
  let l:col=col('.')
  let l:i=line('.')
  let l:l=getline(l:i)
  if l:l[l:col-1]==' ' && index([' ','(',')','<','>','[',']','{','}','.',',',';'],l:l[l:col-2])
        \ && l:l[l:col] !~ '[^[:punct:]]'
"        \ && l:l[l:col] !~ '[^();,.{}]\|\[\]'
    exe 'norm a'.a:style.' '.a:style
    exe 'norm F xi'.input(zim#util#gettext('input_text').' : ')
    exe 'norm '.len(a:style).' '
    return 1
  endif
  let l:mark=' '
  while l:col >1 && l:l[l:col-1] != l:mark
    let l:col-=1
  endwhile
  call s:doZimToggleStyle(a:style,a:style,l:i,l:l,l:col)
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
    let l:i=line('.')
    for l:l in getline(l:l1,l:l2)
      call s:doZimToggleStyle(a:style,a:style,l:i,l:l,1)
      let l:i+=1
    endfor
  endif
endfu

"" functions to manage links
function! s:get_visual_selection()
  let [lnum1, col1] = getpos("'<")[1:2]
  let [lnum2, col2] = getpos("'>")[1:2]
  let lines = getline(lnum1, lnum2)
  let lines[-1] = lines[-1][: col2 - (&selection == 'inclusive' ? 1 : 2)]
  let lines[0] = lines[0][col1 - 1:]
  return join(lines, "\n")
endfunction

function! s:getLinkPath(tgt)
  let l:tgt=''
  if len(a:tgt)
    " ignore if it is not in notebook
    if match(a:tgt,'^\(\~/\|http[s]\?://\|/\)')> -1
      return a:tgt
    endif
    if match(a:tgt,'^\(href=\)')> -1
      return strpart(a:tgt,5)
    endif
    let l:notebook=expand('%:p:s?'.g:zim_notebooks_dir.'[/]*??:s?/.*$??')
    let l:inner_path=expand('%:p:s?'.g:zim_notebooks_dir.'[/]*??:s?^[^/]*[/]*??:s?.txt$?/?')
    let l:tgt=substitute(
          \ substitute(
          \ substitute(
          \ substitute(a:tgt,':','/','g'),
          \ ' ','_','g'),
          \ '\.txt$','','').'.txt',
          \ '^\./', l:inner_path,'')
    let l:tgt=g:zim_notebooks_dir.'/'.l:notebook.'/'.l:tgt
  endif
  return l:tgt
endfunction

function! s:getLinkComponentsUnderCursor(begin,end,sep)
  let l:pos=col('.')
  let l:l=getline('.')
  let l:pat=a:begin.'.*'.a:end
  let [l:b, l:e]=[0,0]
  while ((l:e>=0) && (l:b>=0) && (l:pos > l:b + l:e))
    let l:b=match(l:l, l:pat, l:b + l:e)
    if (l:b>=0)
      let l:bmatch=matchstr(l:l, a:begin, l:b + l:e)
      let l:e=match(l:l, a:end, l:b)
    endif
  endwhile
  if (l:b < 0)
    return []
  endif
  let l:b=l:b+len(l:bmatch)
  let l:tgt=strpart(l:l, l:b, l:e-l:b)
  return split(l:tgt,a:sep)
endfunction

function! s:getAllLinkComponentsInStr(str,begin,end,sep,idx)
  let l:pat=a:begin.'[a-zA-Z/.0-9éà_-]\+\('.a:end.'\|'.a:sep.'\)'
  let l:links=[]
  let [l:b, l:e]=[0,0]
  while (l:b >= 0 && l:e >=0)
    let l:b=match(a:str, l:pat, l:e)
    if (l:b>=0)
      let l:bmatch=matchstr(a:str, a:begin, l:e)
      let l:e=match(a:str, a:end, l:b+len(l:bmatch))
      if (l:e>=0)
        let l:b=l:b+len(l:bmatch)
        let l:tgt=strpart(a:str, l:b, l:e-l:b)
        call add(l:links,split(l:tgt,a:sep)[a:idx])
      endif
    endif
  endwhile
  return l:links
endfunction

function! zim#editor#JumpToLinkUnderCursor()
  let l:components=s:getLinkComponentsUnderCursor('\[\[','\]\]','|')
  if empty(l:components)
    norm! gF
    return 0
  endif
  let l:path=s:getLinkPath(l:components[0])
  let l:self=expand('%:p')
  if len(l:path) 
     if bufexists(l:path)
       exe 'buffer '.l:path
     else
       exe 'e '.l:path
     endif
  endif
  let b:zim_last_backlink=l:self
endfunction

""" functions to manage images and external files
function! s:showFiles(imgs, openners)
  let l:opens={}
  let l:idx=1
  let l:cnt=0
  for l:i in a:imgs
    let l:cnt+=1
    let l:path=s:getLinkPath(l:i)
    if len(l:path)
      for l:j in a:openners
        let l:p=l:j[0]
        let l:i=str2nr(get(l:j,2,0))
        if (l:i && l:cnt > l:i)
          let l:idx+=1
          let l:cnt=0
        endif
        if (match(l:path, l:p) > -1)
          let l:k=l:p.'@'.l:idx
          if has_key(l:opens, l:k)
            let l:opens[l:k].=' '.l:path
          else
            let l:opens[l:k]=l:j[1].' '.l:path
          endif
          break
        endif
      endfor
    endif
  endfor
  for l:i in keys(l:opens)
    "    silent exe '!'.l:opens[i].'&'
    exe '!'.l:opens[i].' &'
  endfor
endfunction

function! zim#editor#InsertImage(imgfname,captureprg)
  let l:imgfname=a:imgfname
  if (match(l:imgfname,'^/') < 0)
    let l:imgfname='~/'.l:imgfname
  endif
  if (len(a:captureprg))
    "    silent! exe '!'.a:captureprg.' '.l:imgfname.'&'
    exe '!'.a:captureprg.' '.l:imgfname
  endif
  exe 'norm i{{'.l:imgfname.'?href=#}}'
endfunction

function! zim#editor#ShowFile(openners)
  let l:components=s:getLinkComponentsUnderCursor('https://','\(\|$\| \|}\|\]\)','\(|\|?\)')
  if len(l:components)
    let l:components[0]='https://'.l:components[0]
  else
    let l:components=s:getLinkComponentsUnderCursor('http://','\(\|$\| \|}\|\]\)','\(|\|?\)')
    if len(l:components)
      " just add 's' to 'http' with an option to implement a kind of https everywhere
      let l:components[0]='http://'.l:components[0]
    else
      let l:components=s:getLinkComponentsUnderCursor('\(^\|{\|\[\)/','\(\|$\| \|}\|?\|\]\)','\(|\|?\)')
      if len(l:components)
        let l:components[0]='/'.l:components[0]
      else
        return 0
      endif
    endif
  endif
  call s:showFiles([l:components[0]],a:openners)
endfunction

function! zim#editor#ShowFileBulk(openners) range
  norm gv
  let l:str=substitute(s:get_visual_selection(),'\n',' ','g')
  let l:files=map(
        \s:getAllLinkComponentsInStr(l:str,'https://','\(\|$\| \|}\|?\|\]\)','\(|\|?\)',0),
        \'"https://".v:val')
  if empty(l:files)
    let l:files=map(
          \s:getAllLinkComponentsInStr(l:str,'http://','\(\|$\| \|}\|?\|\]\)','\(|\|?\)',0),
          \'"http://".v:val')
  endif
  if empty(l:files)
    let l:files=map(
          \s:getAllLinkComponentsInStr(l:str,'\( \|{\|\|\[\|^\)/','\(\|$\| \|}\|?\|\]\)','\(|\|?\)',0),
          \'"/".v:val')
  endif

  call s:showFiles(l:files,  a:openners)
endfunction

function! zim#editor#ShowImage(openners)
  let l:components=s:getLinkComponentsUnderCursor('{{','}}','?')
  if empty(l:components)
    return 0
  endif
  call s:showFiles([l:components[0]],a:openners)
endfunction

function! zim#editor#ShowImageBulk(openners) range
  norm gv
  call s:showFiles(
        \ s:getAllLinkComponentsInStr(s:get_visual_selection(),'{{','}}','?',0),
        \ a:openners
        \)
endfunction

function! zim#editor#ShowImageLink()
  let l:components=s:getLinkComponentsUnderCursor('{{','}}','?')
  if len(l:components) < 2
    return 0
  endif
  let l:path=s:getLinkPath(l:components[1])
  if len(l:path) 
     echo  l:path
  endif
endfunction

