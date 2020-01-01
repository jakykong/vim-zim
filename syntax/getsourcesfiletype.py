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

def langsubst(lzim):
    langsubsts=[
        (0, ' ', '-'),
        (1,'gettext-translation', 'po'),
        (1,'dos-batch', 'dosbatch'),
        (1,'.ini', 'dosini'),
        (1,"c/c++/objc-header", "cpp"),
        (0, '#', 's'),
        (0, '++', 'pp'),
        (0, 'objective-', 'o'),
        (0,'literate-', ''),
        (0,'.','')
    ]
    lvim = lzim.lower()
    for b, z, v in langsubsts:
        if z in lvim:
            lvim = lvim.replace(z, v)
            if b:
                break
    return lzim, lvim

ret = []
for (lzim, lvim) in [langsubst(l) for l in LANGUAGES]:
    if glob('/usr/share/vim/*/syntax/'+lvim+'.vim') :
        ret.append('"' + lzim + '" : "' + lvim +  '"')
print "let g:zim_codeblock_syntax = { %s }" % "\n \\ ".join(ret)
