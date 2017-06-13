
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
"@param char prewincmd    <C-w> command to do before any control
"@param char alonewcmd    <C-w> command to do when the zimindex is alone
"@param char notalonewcmd <C-w> command to do when there is another window
"@param char postwcmd     <C-w> command to do after the placement
function! zim#util#setWindow(prewincmd,alonewcmd,notalonewcmd,postwcmd,file)
  if a:file =~ '/' && a:file !~ '>'
    if len(a:prewincmd) | exe 'wincmd '.a:prewincmd | endif
    let l:buffer_exist=bufexists(a:file)
    if exists('b:filetype') && b:filetype == 'zimindex'
      " alone
      if len(a:alonewcmd) | exe 'wincmd '.a:alonewcmd | endif
    else
      if len(a:notalonewcmd) | exe 'wincmd '.a:notalonewcmd | endif
    endif
    let l:ope=(l:buffer_exist? 'buffer ' : 'e ')
    exe l:ope.a:file
    if len(a:postwcmd) | exe 'wincmd '.a:postwcmd | endif
  endif
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
