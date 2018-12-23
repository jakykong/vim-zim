#!/usr/bin/python2.7

from glob import glob
try:
    import gtksourceview2
except:
    gtksourceview2 = None


if gtksourceview2:
    lm = gtksourceview2.LanguageManager()
    lang_ids = lm.get_language_ids()
    lang_names = [lm.get_language(i).get_name() for i in lang_ids]

    LANGUAGES = dict((lm.get_language(i).get_name(), i) for i in lang_ids)
else:
    LANGUAGES = {}


langdict={
"objective-caml" : 'ocaml',
'objective-c':'objc',
'gettext-translation':'po',
'dos-batch':'dosbatch',
'.ini':'dosini',
'c#':'cs',
'c++':'cpp',
"c/c++/objc-header":"cpp"
}
ret = "let s:languages = {"
for i in LANGUAGES:
    lzim = i.lower().replace(' ','-')
    lvim = langdict.get(lzim, lzim).replace('#', 's').replace('literate-','').replace('.','')
    if glob('/usr/share/vim/*/syntax/'+lvim+'.vim') :
        ret += '"' + lzim + '" : "' + lvim +  '",'
ret += "}"
print ret
