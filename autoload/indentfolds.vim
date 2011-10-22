" indentfolds.vim
" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2011-10-21.
" @Last Change: 2011-10-22.
" @Revision:    126


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
"
"   LEVEL     ... Indentation LEVEL is fold level 1
"   LOW-HIGH  ... Indentation levels from LOW to HIGH are fold level 1
"   L1,L2,... ... Indentation levels L1, L2 etc. are fold level 1
"
" The LEVELS argument can have a "+" or "-" prefix. In such case, the 
" listed levels are added or removed from the list of top indentation 
" levels.
function! indentfolds#Fold(...) "{{{3
    let levels = a:0 >= 1 ? a:1 : ''
    if levels =~ '^[+-]'
        let meth = levels[0:0]
        let levels = strpart(levels, 1)
    else
        let meth = ''
    endif
    " TLogVAR levels, meth
    if levels =~ '^\d\+\(,\d\+\)*$'
        let llevels = split(levels, ',')
    elseif levels =~ '^\d\+-\d\+$'
        let llevels = call('range', split(levels, '-'))
    else
        throw "IndentFolds: Invalid argument format (must be one of: Level L1-L2 L1,L2): ". string(a:000)
    endif
    " TLogVAR llevels
    if meth == "+"
        let s:levels += llevels
    elseif meth == "-"
        let s:levels = filter(s:levels, 'index(llevels, v:val) == -1')
    else
        let s:levels = llevels
    endif
    if empty(s:levels)
        throw "IndentFolds: List of indentation levels must not be empty"
    endif
    echom "IndentFolds: Indentation levels =" join(s:levels, ', ')
    setlocal foldmethod=expr
    setlocal foldexpr=indentfolds#Expr(v:lnum)
    let foldlevel = a:0 >= 2 ? a:2 : min([&l:foldlevel, g:indentfolds#foldlevel])
    if foldlevel > 0
        call s:SetFoldLevel(foldlevel)
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
                    let lend = prevnonblank(lnum - 1)
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
    let prev = prevnonblank(a:lnum)
    let next = nextnonblank(a:lnum)
    let indent = indent(prev)
    if prev != next
        let indent = min([indent, indent(next)])
    endif
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
    call s:SetFoldLevel(&l:foldlevel)
endf


function! s:SetFoldLevel(foldlevel) "{{{3
    norm! zx
    let &l:foldlevel = a:foldlevel
endf

