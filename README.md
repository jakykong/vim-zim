Zim Desktop Wiki plugin for Vim
================================
```
            ___    /   /                                              
           |_ _|  /  /         _________      _                       
    ___      |_  / /          |_______  |    | |                      
   |_ _|  .-'   //                  ,' ,'     _     _  ____   ____    
       \ '     /  '    ___        ,' ,'      | |     \/ __ \ / __ \   
        |          | -|_ _|     ,' ,'        | |    | |   | |    | |  
        '.        .'          ,' ,'_____     | |    | |   | |    | |  
     ___/ '- __ -'          __|_________|__ _|_|_ __|_|   |_|    |_|__
    |_ _|     _|_                                                     
             |_ _|      Zim -  A Desktop Wiki  (for Vim 7.0 or newer) 
```

How to install
================================
Download zip or do `git clone` using button 'Clone or download'.
The shall be `~/vim/pack/org/start/zim` (or arbitrary `/path/to/vim-zim` with Vim version<8 ).

Then add this in your vim rc.

In Vim 8, you shall just verify this line present :
```vim
syntax on
packloadall
```
``` Vim

If you use Vim version<8 :
```vim
syntax on
set rtp+=/path/to/vim-zim
```
Restart Vim.

Do in command line :

* To get every commands and parameters ->  `:h Zim`
* To get a list of your notes -> `:ZimList`


Usage
=====

This plugin allow to use all Zim notes in Vim.
It is especially useful :

* when you want to use Vim to edit your note
* when you need to fetch informations stored in your NoteBooks

Use cases :
* you want all notes mentioning 'foo' : just do `:ZimGrep foo`
* you want all notes named 'something-foo' : do `:ZimList foo`
* you want to create a new note : `:ZimNewNote Notes/foo/A Great Name For Bar` will create the files `foo.txt` titled `foo`, and `foo/A_Great_Name_For_Bar.txt` titled `A Great Name For Bar`
* note that you can use <Tab> completion to get your path with `:ZimNewNote` and `:ZimList`
* you need to organize the notes in the Notebook foo `:ZimList foo` and use d(detect double) D(delete) N(new note) m(move) R(Rename) keys
* you need to format the current line as a title, and you don't know the keybind  `:ZimCmd title`

About zim-vim
=============
This section give some details about the development of this plugin.

Authors : [Jack Mudge](https://github.com/jakykong/vim-zim), [Luffah](https://github.com/luffah/vim-zim)
```
License : Public Domain
          CC-BY-SA for documentation and logo

## Known issues  
* When adding note, you shall refresh manually (restart) the index in Zim.
  In GNU linux see `:h g:zim_update_index_key`.
* No real Windows Support.
* Windows :Zim header command uses strftime, but due to working around Microsoft issues,
  it presently only supports Pacific Time Zone .

## Changelog
#### version 0.1 2016-09-13 - Jack Mudge <jakykong@theanythingbox.com>
* Initial commit and upload to Github. 
* This Zim plugin provides the following additions to Vim for use with Zim wiki files:
    * Syntax highlighting and filetype detection for Zim files
    * Commands to bold, italicize, strike, or mark text.
    * A command to add a header to new Zim files.

#### version 1.0 2017-06-13 - Luffah <luffah@runbox.com>
* Add documentation and logo
* Provide customisation, helpfile, and navigation features
* (change) Header accept user dialog instead of count
* (change) Syntax color reviewed in order to look more like Zim
* Mod. CreateZimHeader + minimal support of Linux strftime() + automatic title
* Customazible keymappings limited to zim buffers stored in g:zim_keymapping
* Filetype detection based on a path
* In insert mode : add bullet, numbering, or checkbox on <Leader><CR> with the result of ZimNextBullet
* Multilingual : English, French // translations can be added in file plugin/zim.vim
* You can now Search and jump to another note

#### version 1.1 2017-07-18 - Luffah <luffah@runbox.com>
* Allow to open files listed in a note with an external editor
* Add some tricks in help

#### version 1.2 2018-06-16 - Luffah <luffah@runbox.com>
* Add codeblock support
* Add [>] "moving" checkbox
* Now conceal url link (to only see the title)
* Can fill a note from a web page.
```
