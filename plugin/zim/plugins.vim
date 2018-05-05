let g:zim_python_path=substitute(system("find /usr/lib/python* -name 'zim' -type d"),
      \"\n.*",'','')

command! ZimArithmetic call zim#plugins#arithmetic#processfile()
