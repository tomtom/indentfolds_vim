" indentfolds.vim
" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2011-10-21.
" @Last Change: 2011-10-21.
" @Revision:    91


if !exists('g:indentfolds#cycleplus_map')
    " Use this map for cycling through indentation levels (focus lower 
    " section levels).
    let g:indentfolds#cycleplus_map = '<tab>'   "{{{2
endif

if !exists('g:indentfolds#cycleminus_map')
    " Use this map for cycling through indentation levels (focus higher 
    " section levels).
    let g:indentfolds#cycleminus_map = '<s-tab>'   "{{{2
endif

if !exists('g:indentfolds#foldlevel')
    " If >= 0, |indentfolds#Fold()| sets 'foldlevel' to this value.
    let g:indentfolds#foldlevel = 2   "{{{2
endif

if !exists('g:indentfolds#comment_command')
    " An ex-command to evaluate on a range of lines in order to comment 
    " that lines out.
    "
    " If the tcomment plugin is installed, this defaults to:
    "   TComment!
    " Otherwise, commenting is disabled.
    "
    " You can set this variable to "delete" to delete lines instead of 
    " commenting them out.
    " :read: let g:indentfolds#comment_command = ...   "{{{2
    if exists('g:loaded_tcomment')
        let g:indentfolds#comment_command = 'TComment!'
    else
        let g:indentfolds#comment_command = ''
    endif
endif

let s:levels = [0]


" :display: indentfolds#Fold(LEVELS, foldlevel=g:indentfolds#foldlevel)
" Set the indentation levels (see also |fold-indent|) that should be 
" considered a top level fold. The fold level is the smallest difference 
" between the current line's indentation level and the levels set with 
" this function.
"
" The LEVELS argument can have the following forms:
"   LEVEL     ... Indentation LEVEL is fold level 1
"   LOW-HIGH  ... Indentation levels from LOW to HIGH are fold level 1
"   L1,L2,... ... Indentation levels L1, L2 etc. are fold level 1
function! indentfolds#Fold(...) "{{{3
    if a:0 > 0 && a:1 =~ '^\d\+\(,\d\+\)*$'
        let s:levels = split(a:0, ',')
    elseif a:0 > 0 && a:1 =~ '^\d\+-\d\+$'
        let s:levels = call('range', split(a:0, '-'))
    else
        throw "IndentFolds: Argument format (one of): Level L1-L2 L1,L2"
    endif
    setlocal foldmethod=expr
    setlocal foldexpr=indentfolds#Expr(v:lnum)
    let foldlevel = a:0 >= 2 ? a:2 : g:indentfolds#foldlevel
    if foldlevel > 0 && &l:foldlevel != foldlevel
        let &l:foldlevel = foldlevel
    endif
    if !empty('g:indentfolds#cycleplus_map')
        exec 'noremap <buffer>' g:indentfolds#cycleplus_map ':call indentfolds#Cycle(1)<cr>'
    endif
    if !empty('g:indentfolds#cycleminus_map')
        exec 'noremap <buffer>' g:indentfolds#cycleminus_map ':call indentfolds#Cycle(-1)<cr>'
    endif
endf


" Comment out lines whose fold level is greater or equal the LEVEL 
" argument.
" :display: indentfolds#Comment(LEVEL)
function! indentfolds#Comment(...) "{{{3
    if empty(g:indentfolds#comment_command)
        throw 'IndentFolds: Commenting not supported! Please see :help g:indentfolds#comment_command'
    else
        let pos = getpos('.')
        try
            let level = a:0 >= 1 ? a:1 : 2
            let lbeg = 0
            for lnum in range(1, line('$'))
                if foldlevel(lnum) >= level
                    if lbeg == 0
                        let lbeg = lnum
                    endif
                elseif lbeg > 0
                    let lend = lnum - 1
                    " echom "DBG" lbeg .",". lend . g:indentfolds#comment_command
                    silent exec lbeg .",". lend . g:indentfolds#comment_command
                    let lbeg = 0
                endif
            endfor
            if lbeg > 0
                " echom "DBG" lbeg .",$" . g:indentfolds#comment_command
                silent exec lbeg .",$" . g:indentfolds#comment_command
            endif
        finally
            call setpos('.', pos)
        endtry
    endif
endf


function! indentfolds#Expr(lnum) "{{{3
    let indent = indent(a:lnum)
    let level = indent / &shiftwidth
    if index(s:levels, level) != -1
        return 1
    else
        let val = min(map(copy(s:levels), 'abs(v:val - level)')) + 1
        return val
    endif
endf


function! indentfolds#Cycle(delta) "{{{3
    let s:levels = map(s:levels, 'v:val + a:delta')
    echom "IndentFolds: Set top indentation levels to:" join(s:levels, ', ')
    norm! zx
    if g:indentfolds#foldlevel > 0
        let &l:foldlevel = g:indentfolds#foldlevel
        norm! zv
    endif
endf

