" Zim Utilities Plugin
" Author: Jack Mudge <jakykong@theanythingbox.com>
" * I declare this file to be in the public domain.
"
" Last Change:	2017 July 18
" Maintainer: Luffah <luffah@runbox.com>
" Version: 1.1
"
" Changelog:
" 2016-09-12 - Jack Mudge - v0.1
"   * Initial creation.
" 2017-05-25 - luffah - v0.2
"   * Mod. CreateZimHeader  to zim#editor#CreateHeader
"      + minimal support of Linux strftime() + automatic title
"   * Keymappings
"      + limited to zim buffers + stored in g:zim_keymapping
"   * Add a gettext like function
"   * In insert mode : add bullet, numbering, or checkbox
"     on <CR> with the result of ZimNextBullet
" 2017-06-07 - luffah - v0.3
"   * Add note and notebook creation commands
"   * Add workarounds to force Zim re-indexing
" 2017-06-13 - luffah - v1
"   * Add notebook navigation features
" 2017-06-07 - luffah - v1.1
"   * Interaction with others files types
"   * Add images insertion
"
" What This Plugin Does: 
" * Provides shortcuts and helpful mappings to work with Zim wiki formatting.
"   This is primarily intended for using the 'Edit Source' functionality in
"   Zim, but may be useful to create new files in a Zim folder.
" * Add bullet, incremental, numbering, checkboxes on <CR> in insert mode
" * Note navigation and creation
"
" What This Plugin Does Not: 
" * Doesn't add bullets, numbering, or checkboxes on <CR> in visual mode
" * Doesn't reindex Zim (see Bugs) nor reorganize notes
" /** IF YOU WANT TO UPDATE ZIM INDEX FROM VIM **
"  On Linux you can choose to use the deprecated ZimBrutalUpdate command.
"  To use this command you need to enable it
"     in vimrc : let g:zim_brutal_update_allowed=1
"  OR
"  to setup shortcut key (F5) in $HOME/.config/zim/accelmap
"  and define it in your configuration allowing
"  the plugin to update index when a note is created (ZimNewNote command)
"      in vimrc : let g:zim_update_index_key="F5"
"   in accelmap : (gtk_accel_path "<Actions>/GtkInterface/reload_index" "F5")
" **/
" Known Bugs:
" * Zim issue: New files aren't shown in Zim index until restart of zim.
"              This can be forced with the command `zim --index`, but indexing
"              while zim is running will corrupt index. 
"              If you encounter problems with index, stop zim, remove zim index
"              from your cache. (Linux: rm -rf $HOME/.cache/zim)
"              If you want to reindex living Zim Notebook, click on Zim menu :
"              'Tools' > 'Update Index'
"
" Example configuration :
" set rtp+=/path/to/zim.vim
" let g:zim_keymapping={
"       \ '<CR>':'<CR>',
"       \ 'continue_list':'<Leader><CR>',
"       \ 'jump':'<Leader>g',
"       \ 'jump_back':'<Leader>G',
"       \ 'bold':'<Leader>b',
"       \ 'italic':'<Leader>i',
"       \ 'highlight':'<Leader>h',
"       \ 'strike':'<Leader>s',
"       \ 'title':'<Leader>t',
"       \ 'header':'<Leader>H',
"       \ 'li':'<Leader>l',
"       \ 'checkbox':'<Leader>c',
"       \ 'checkbox_yes':'<Leader>y',
"       \ 'checkbox_no':'<Leader>n'
"       \}
" " On note openning, go 2 lines after the first title
" let g:zim_open_jump_to=["==.*==", 2]
" " Or Go 2 lines after the last title
" let g:zim_open_jump_to=[{'init': '$', 'sens': -1}, "==.*==", 2]
"
""""""""""""""""""""""""""""""""
" Plugin init 
" (for developpers who wants to test ':let g:zim_dev=1 | source %')
if (!get(g:,'zim_dev',0) && get(g:,'loaded_zim',0)) || &cp | finish | endif

"'"'""'"'"'"'"'"'"'"'"'"'"'"'"'"
""
"  Globally avaible commands (other commands are defined in zim/note.vim)
"
command! ZimSelectNotebook :call zim#explorer#SelectNotebook('split')
command! ZimCreateHeader :call zim#editor#CreateHeader()
command! -nargs=* ZimGrep :call zim#explorer#SearchTermInNotebook(<q-args>)
command! -nargs=* -complete=customlist,zim#util#_CompleteNotes ZimNewNote :call zim#note#Create('rightbelow vertical split',g:zim_notebook,<q-args>)
command! -nargs=* -complete=customlist,zim#util#_CompleteNotes ZimOpen :call zim#util#open('rightbelow vertical split',g:zim_notebook,<q-args>)
command! -nargs=* -complete=customlist,zim#util#_CompleteNotes ZimList :call zim#explorer#List('tabnew',g:zim_notebook,<q-args>)
command! -nargs=* -complete=customlist,zim#util#_CompleteNotes ZimCopy :call zim#note#Move(1, <f-args>)
command! -nargs=* -complete=customlist,zim#util#_CompleteNotes ZimMove :call zim#note#Move(0, <f-args>)
command! -nargs=1 -complete=customlist,zim#util#_CompleteBook ZimCD :exe "let g:zim_notebook='".g:zim_notebooks_dir.'/'.<q-args>."'"
command! -nargs=1 ZimCreateNoteBook :call zim#note#CreateNoteBook(<q-args>)

command! -nargs=1 -complete=customlist,zim#util#_CompleteEditCmdI ZimCmd :call zim#util#cmd('n',<q-args>,1)
command! -nargs=1 -complete=customlist,zim#util#_CompleteEditCmdV -range ZimCmdV :call zim#util#cmd('v',<q-args>,1)
command! ZimServer :call system('zim --server --gui '.g:zim_notebook .' '.get(g:,'zim_server_options','').' &')

" The matchable dict activate commands ZimMatchNext.. and ZimMatchPrev...
let g:zim_matchable=get(g:,'zim_matchable',{
      \'KeyElement': '\(' .
                    \ '==' .
                    \ '\|{{' .
                    \ '\|\*'.
                    \ '\|\[\(\[\| \)' .
                    \ '\|\d\+\.\s' .
                    \ '\|/[.a-zA-Z0-9]\+' .
                    \ '\)',
      \'Title': '^\(=\+\).*\1$',
      \'Checkbox': '^\(\s\{4}\)*\[[ ]\]\(\s\|$\)',
      \'Li': '^\(\s\{4}\|\t\)*\*\(\s\|$\)',
      \'NumberedItem': '^\(\s\{4}\|\t\)*\d\+\.\(\s\|$\)',
      \'Link': '\[\[.*\]\]',
      \'Img': '{{.*}}',
      \'File': '\(\~\|\.\|^\| \|{\|\[\)/[.a-zA-Z0-9]\+',
      \'Url': 'http[s]\?://[.a-zA-Z0-9]\+',
      \ })

if !has("win32")
  if get(g:,'zim_brutal_update_allowed', 0)
    command! ZimBrutalUpdate :silent !pkill -9 zim; zim & 
  elseif exists(':ZimBrutalUpdate') 
    delcommand ZimBrutalUpdate
  endif
endif

let g:zim_notebooks_dir=get(g:,'zim_notebooks_dir',expand("~/Notebooks"))
let g:zim_notebook=get(g:,'zim_notebook',g:zim_notebooks_dir)

"'"'""'"'"'"'"'"'"'"'"'"'"'"'"'"
""
"  PARAMETRIC PART
"
"  Read this file if you want to customize zim.vim
"
"" External programs
"if !has("win32")
"else
let g:zim_img_capture=get(g:,'zim_img_capture','sleep 2; scrot -s')
" Note : in '\..*$','xdg-open', 1
"           '\..*$' is a vim regular expression for any file extension
"           'xdg-open' is the program
"           1  express cardinality, it says to open one file per program
"         if <number> is not present,
"         then all files in a file list matching the .ext
"         will be openned within the same command
"         Example of cardinality for a selection of 3 filenames
"         1 -> 'program file1.ext; program file2.ext; program file3.ext'
" none or 0 -> 'program file1.ext file2.ext file3.ext'
let g:zim_img_viewer=get(g:,'zim_img_viewer',['\..*$','xdg-open',1])
let g:zim_img_editor=get(g:,'zim_img_editor',['\..*$','xdg-open',1])
let g:zim_ext_viewer=get(g:,'zim_ext_viewer',['\..*$','xdg-open',1])
let g:zim_ext_editor=get(g:,'zim_ext_editor',['\..*$','xdg-open',1])
"endif
""
" Actions and keymapping : how it works ?
" 
" Actions in the editor pane are defined by reference
" idem for the keys.
"
" The commands for the commands (protocol) are defined in g:zim_edit_actions,
" and the keys are defined in g:zim_keymapping.
"
" Default configuration provide a good example
"
"" Actions
let g:zim_edit_actions=get(g:,'zim_edit_actions', {
      \ '<CR>': { 'i' : '<bar><Esc>:silent call zim#editor#CR("<bar>")<CR>i' },
      \ 'explore':{ 'n' : ':silent call zim#explorer#List("vertical leftabove split", g:zim_notebook, strpart(expand("%:p:h"),len(g:zim_notebooks_dir) +1))<CR>' },
      \ 'jump':{ 'n' : ':call zim#editor#JumpToLinkUnderCursor()<CR>' },
      \ 'jump_back':{  'n' : ':exe "buffer ".b:zim_last_backlink <CR>' },
      \ 'continue_list':{  'n' : ':put=zim#editor#NextBullet(getline("."))<CR>$a' },
      \ 'title': { 'n':  ':call zim#editor#Title()<CR>' },
      \ 'header':       { 'n':  ':call zim#editor#CreateHeader()<CR>' },
      \ 'showimg':       {
      \    'v':  ':call zim#editor#ShowImageBulk(g:zim_img_viewer)<CR>',
      \    'n':  ':call zim#editor#ShowImage(g:zim_img_viewer)<CR>'
      \},
      \ 'editimg':       {
      \    'v':  ':call zim#editor#ShowImageBulk(g:zim_img_editor)<CR>',
      \    'n':  ':call zim#editor#ShowImage(g:zim_img_editor)<CR>'
      \},
      \ 'showfile':       {
      \    'v':  ':call zim#editor#ShowFileBulk(g:zim_ext_viewer)<CR>',
      \    'n':  ':call zim#editor#ShowFile(g:zim_ext_viewer)<CR>'
      \},
      \ 'editfile':       {
      \    'v':  ':call zim#editor#ShowFileBulk(g:zim_ext_editor)<CR>',
      \    'n':  ':call zim#editor#ShowFile(g:zim_ext_editor)<CR>'
      \},
      \ 'all_checkbox_to_li': { 'n': ':%s/^\(\s*\)\[ \]/\1*/<CR>' },
      \ 'li':           { 'n': ":call zim#editor#Bullet('*')<CR>", 'v':":call zim#editor#BulletBulk('*')<CR>" },
      \ 'checkbox':     { 'n': ":call zim#editor#Bullet('[ ]')<CR>", 'v':":call zim#editor#BulletBulk('[ ]')<CR>"},
      \ 'checkbox_yes': { 'n': ":call zim#editor#Bullet('[*]')<CR>", 'v':":call zim#editor#BulletBulk('[*]')<CR>"},
      \ 'checkbox_no':  { 'n': ":call zim#editor#Bullet('[x]')<CR>", 'v':":call zim#editor#BulletBulk('[x]')<CR>"},
      \ 'date': { 'n': ':exe "norm a".strftime(zim#util#gettext("dateformat"))<CR>'},
      \ 'datehour': { 'n': ':exe "norm a".strftime(zim#util#gettext("datehourformat"))<CR>'},
      \ 'bold':{
      \   'v': ':call zim#editor#ToggleStyleBlock("**")<CR><Esc>',
      \   'n': ':call zim#editor#ToggleStyle("**")<CR>'
      \ },
      \  'highlight':{
      \   'v': ':silent call zim#editor#ToggleStyleBlock("__")<CR><Esc>',
      \   'n': ':silent call zim#editor#ToggleStyle("__")<CR>'
      \ },
      \ 'strike': {
      \   'v':  ':call zim#editor#ToggleStyleBlock("~~")<CR><Esc>',
      \   'n':  ':call zim#editor#ToggleStyle("~~")<CR>'
      \ },
      \ 'italic': {
      \   'v' : ':call zim#editor#ToggleStyleBlock("//")<CR><Esc>',
      \   'n' : ':call zim#editor#ToggleStyle("//")<CR>'
      \ }
      \})

"" Default keymapping
let g:zim_keymapping=get(g:,'zim_keymapping', {
      \ '<CR>':'<CR>',
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
      \ 'checkbox_no':'<S-F12>',
      \ 'date':'<Leader>wd',
      \ 'datehour':'<Leader>wD',
      \ 'explore':'<F9>',
      \ 'showimg':'<F3>',
      \ 'editimg':'<S-F3>',
      \ 'showfile':'<F4>',
      \ 'editfile':'<S-F4>',
      \ })

let g:zim_keymapping=get(g:,'zim_keymapping', {
      \ '<CR>':'<CR>',
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
      \ 'checkbox_no':'<S-F12>',
      \ 'date':'<Leader>wd',
      \ 'datehour':'<Leader>wD',
      \ 'explore':'<F9>',
      \ 'showimg':'<F3>',
      \ 'editimg':'<S-F3>',
      \ 'showfile':'<F4>',
      \ 'editfile':'<S-F4>',
      \ })


"" Zim Wiki format : to be change if wiki format change...
let g:zim_wiki_version=get(g:,'zim_wiki_version','0.4')

""" Configuration dir of Zim
let g:zim_config_dir=get(g:,'zim_config_dir','')
if (! len(g:zim_config_dir))
  if has('win32')
    let g:zim_config_dir=''
  else
    let g:zim_config_dir=(expand('$XDG_CONFIG_HOME') || expand('$HOME/.config')).'/zim'
  endif
endif
"" When g:zim_open_skip_header is set to true (1),
"" the note is openned on the first line after the header.
let g:zim_open_skip_header=get(g:,'zim_open_skip_header',1)

"" The array g:zim_open_jump_to allow you to begin note editing where you want.
"" This is done by a succession of movements determining the cursor position.

"" The array can contain 3 types of variables, with different meanings
"" dict    { 'init': 'a line position', 'sens' : (-1 or 1) line step for searching text }
"" string  text pattern  e.g. Creation
"" integer line delta  e.g. -1 to go back 1 line
""
"" Go to the last title and jump 2 line
let g:zim_open_jump_to=get(g:,'zim_open_jump_to',
      \ [{'init': '$', 'sens': -1}, "==.*==", 2])


""
" Messages
"
let g:zim_wiki_lang=get(g:,'zim_wiki_lang','fr')
let g:zim_wiki_prompt={
      \ 'en' : { 'note_name' : 'Name of the new note',
      \          'dateformat': "%d/%m/%Y",
      \          'datehourformat': "%d/%m/%Y %H:%M",
      \          'title_level': "Title level (between 1 and 5 , else remove style)",
      \          'note_out_of_notebook': "Notes shall be created in a notebook... Aborting",
      \          'input_text': 'Text',
      \          '?continue_list': 'Create a new bullet under current',
      \          '?jump': 'Jump to File or Note',
      \          '?jump_back': 'Jump back...',
      \          '?bold': 'Format **bold**',
      \          '?italic': 'Format //italic//',
      \          '?highlight': 'Format __hightlighted__',
      \          '?strike': 'Format ~~striked through~~',
      \          '?title': 'Format = Title =',
      \          '?header': 'Add Zim file header',
      \          '?all_checkbox_to_li': 'Convert checkboxes to list',
      \          '?li': 'Make current line a list item',
      \          '?checkbox': 'Make an empty checkbox',
      \          '?checkbox_yes': 'Validate checkbox',
      \          '?checkbox_no': 'Invalidate checkbox',
      \          '?date': 'Insert date',
      \          '?datehour': 'Insert date with hour',
      \          '?explore': 'View the note explorer',
      \          '?showimg': 'Open image in an external tool',
      \          '?editimg': 'Edit image in an external tool',
      \          '?showfile': 'Open file in an external tool',
      \          '?editfile': 'Edit file in an external tool',
      \        },
      \ 'fr' : { 'note_name' : 'Nom de la nouvelle note',
      \          'dateformat': "%d/%m/%Y",
      \          'datehourformat': "%d/%m/%Y %H:%M",
      \          'title_level': "Niveau de titre (de 1 à 5 , sinon retire le style)",
      \          "'%s' created": "La note %s a été créée",
      \          "NoteBook '%s' created": "Le bloc-note %s a été créée",
      \          'note_out_of_notebook': "Impossible de créer une note en dehors d'un bloc-note !",
      \          "Note '%s' already exists" : "La note '%s' existe déjà",
      \          "Directory '%s' already exists" : "Le Répertoire des sous-notes '%s' est existe déjà",
      \          "NoteBook '%s' not exists" : "Le bloc-note '%s' n'existe pas. Il faut d'abord le créer dans Zim...",
      \          "NoteBook '%s' already exists" : "Le bloc-note '%s' existe déjà.",
      \          "Zim Header already exists" : "Le fichier présente déja une entète Zim",
      \          'Close this window' : 'Quitter',
      \          'Preview' : 'Visualiser sans bouger',
      \          'Open note' : 'Ouvrir la note sous le curseur',
      \          'Update view' : 'Rafraichir',
      \          'Modify filter' : 'Modifier le filtre',
      \          'Detect doubles names' : 'Détecter les notes qui porte le même nom',
      \          'Disable doubles detection (%d founds)' : 'Ne plus détecter les doublons (%d restant)',
      \          'input_text': 'Texte',
      \          'Cannot move a note into itself !': 'Impossible de déplacer une note dans elle-même !',
      \          'Find Next double': 'Atteindre le doublon suivant',
      \          'Delete note': 'Supprimer la note (irreversible)',
      \          'Create note': 'Créer un nouvelle note à coté de la note sous le curseur',
      \          'Rename note under cursor': 'Renommer la note sous le curseur',
      \          'Move note under cursor': 'Sélectionner la note pour déplacement',
      \          'Place the note under cursor (moving %s)': 'Déplacer la note (%s) sélectionnée à coté de la note sous le curseur',
      \        }
      \}
for s:i in keys(g:zim_matchable) 
     let g:zim_wiki_prompt['en']['?next'.s:i]='Move cursor to next '.s:i
endfor
for s:i in keys(g:zim_matchable) 
     let g:zim_wiki_prompt['en']['?prev'.s:i]='Move cursor to previous '.s:i
endfor
let g:loaded_zim=1
