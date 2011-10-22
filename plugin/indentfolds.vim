" @Author:      Tom Link (micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @GIT:         http://github.com/tomtom/
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2011-10-21.
" @Last Change: 2011-10-22.
" @Revision:    13
" GetLatestVimScripts: 3780 0 :AutoInstall: indentfolds.vim
" Folds specific indentation levels

if &cp || exists("loaded_indentfolds")
    finish
endif
let loaded_indentfolds = 1

let s:save_cpo = &cpo
set cpo&vim


" :display: :Indentfolds LEVEL [FOLDLEVEL=g:indentfolds#foldlevel]
" See |indentfolds#Fold()| for help on LEVEL.
" FOLDLEVEL defaults to |g:indentfolds#foldlevel|.
command! -nargs=+ Indentfolds call indentfolds#Fold(<f-args>)


" :display: :IndentfoldsComment [LEVEL=2]
" Comment out all lines with fold level LEVEL or greater.
" Requires |g:indentfolds#comment_command| to be set.
command! -nargs=? IndentfoldsComment call indentfolds#Comment(<f-args>)


let &cpo = s:save_cpo
unlet s:save_cpo
