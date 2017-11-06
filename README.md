Zim Desktop Wiki plugin for Vim
================================
This plugin allow to use all Zim notes in Vim.
It is especially useful :

* when you want to use Vim to edit your note
* when you need to fetch informations stored in your NoteBooks

Examples :

* you want all notes mentioning 'foo' : just do `:ZimGrep foo`
* you want all notes named 'something-foo' : do `:ZimList foo`
* you want to create a new note : `:ZimNewNote Notes/foo/A Great Name For Bar` will create the files `foo.txt` titled `foo`, and `foo/A_Great_Name_For_Bar.txt` titled `A Great Name For Bar`
* note that you can use <Tab> completion to get your path with `:ZimNewNote` and `:ZimList`
* you need to organize the notes in the Notebook foo `:ZimList foo` and use d(detect double) D(delete) N(new note) m(move) R(Rename) keys

Here we go
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
This version is a beta of what could be published by Jack Mudge
on VimScript.org.

|Version|Author|License             | Comment      |
|:--:|:--------------------------------------------------|:------------|:-----------------------------------|
|0   | [Jack Mudge](https://github.com/jakykong/vim-zim) |Public Domain| See : README for more informations |
|1   | [Luffah](https://github.com/luffah/vim-zim)       |Public Domain| What i added is in the doc `:h Zim`|

Current version : 1.1

How to install
================================
You can just add this in your vim rc:
```
set rtp+=/path/to/vim-zim
```

Restart Vim.

Do in command line :

* To get every commands and parameters ->  `:h Zim`
* To get a list of your notes -> `:ZimList`

About zim-vim
=============
This section give some details about the development of this plugin.

## Known issues  
* Windows :Zim header command uses strftime, but due to working around Microsoft issues,
  it presently only supports Pacific Time Zone .
* Not an issue with the plugin, but with Zim: There is no way to refresh the index
  in Zim without restarting Zim. This implies that new files added from Vim will
  not be visible there until it's restarted.
  In linux : this can be worked around with XdoTool and by setting a shortcut in Zim. See Doc.
* Beta Version : Most of the devellopement has been done on Linux.
  There is no guaranty for navigating and note creation functionnalities to work on Vim Windows.
* On terminal version of Vim : the notebook explorer is not perfectly redrawed.

## Changelog
#### 2016-09-13 - Jack Mudge <jakykong@theanythingbox.com>
* Initial commit and upload to Github. 
* This Zim plugin provides the following additions to Vim for use with Zim wiki files:
    * Syntax highlighting and filetype detection for Zim files
    * Commands to bold, italicize, strike, or mark text.
    * A command to add a header to new Zim files.

#### 2017-06-13 - Luffah <luffah@runbox.com>
* v1 : Provide customisation, helpfile, and navigation features
* (change) Header accept user dialog instead of count
* (change) Syntax color reviewed in order to look more like Zim
* Mod. CreateZimHeader + minimal support of Linux strftime() + automatic title
* Customazible keymappings limited to zim buffers stored in g:zim_keymapping
* Filetype detection based on a path
* In insert mode : add bullet, numbering, or checkbox on <Leader><CR> with the result of ZimNextBullet
* Multilingual : English, French // translations can be added in file plugin/zim.vim
* You can now Search and jump to another note

#### 2017-07-18 - Luffah
* Allow to open files listed in a note with an external editor
* Add some tricks in help

