"=============================================================================
" FILE: autoload/edgemotion.vim
" AUTHOR: haya14busa
" License: MIT license
"
" TERMINOLOGY:
" - land: non-white code block.
" - shore: edge of land.
" - sea: white space.
"
" Visualization of code block:
" Code block regex: [^[:space:]][[:space:]]\ze[^[:space:]]\|[^[:space:]]
" :let @/ = '[^[:space:]][[:space:]]\ze[^[:space:]]\|[^[:space:]]' | set hls
"=============================================================================
scriptencoding utf-8

let s:DIRECTION = { 'FORWARD': 1, 'BACKWARD': 0 }

function! edgemotion#move(dir, count1) abort
  let delta = a:dir is# s:DIRECTION.FORWARD ? 1 : -1
  let curswant = getcurpos()[4]
  if curswant > 100000
    call winrestview({'curswant': len(getline('.'))-1})
  endif
  let vcol = virtcol('.')
  let orig_lnum = line('.')

  let lnum = orig_lnum
  let l:final_cmd = ''

  for i in range(1, a:count1)

    let island_start = s:island(lnum, vcol)
    let island_next = s:island(lnum + delta, vcol)

    let should_move_to_land = !(island_start && island_next)
    let last_lnum = line('$')

    if should_move_to_land
      if (island_start && !island_next)
        let lnum += delta
      endif
      while lnum != 0 && lnum <= last_lnum && !s:island(lnum, vcol)
        let lnum += delta
      endwhile
    else
      while lnum != 0 && lnum <= last_lnum && s:island(lnum, vcol)
        let lnum += delta
      endwhile
      let lnum -= delta
    endif

    " Edge not found.
    if lnum == 0 || lnum == last_lnum + 1
      return l:final_cmd
    endif

    let move_cmd = a:dir is# s:DIRECTION.FORWARD ? 'j' : 'k'
    let l:final_cmd = abs(lnum-orig_lnum) . move_cmd

  endfor

  return l:final_cmd
endfunction

function! edgemotion#do_move(dir, count1) abort
  let l:motion = edgemotion#move(a:dir, a:count1)
  if l:motion ==# ''
    return
  endif
  execute "normal! " . l:motion
endfunction

function! s:island(lnum, vcol) abort
  let c = s:get_virtcol_char(a:lnum, a:vcol)
  if c ==# ''
    return 0
  endif
  if !s:iswhite(c)
    return 1
  endif
  let pattern = printf('^.\{-}\zs.\%%<%dv.\%%>%dv.', a:vcol+1, a:vcol)
  let m = matchstr(getline(a:lnum), pattern)
  let chars = split(m, '\zs')
  if len(chars) !=# 3
    return 0
  endif
  return !s:iswhite(chars[0]) && !s:iswhite(chars[2])
endfunction

function! s:iswhite(str) abort
  return a:str =~# '^[ \t]$'
endfunction

function! s:get_virtcol_char(lnum, vcol) abort
  let pattern = printf('^.\{-}\zs\%%<%dv.\%%>%dv', a:vcol+1, a:vcol)
  return matchstr(getline(a:lnum), pattern)
endfunction

" __END__
" vim: expandtab softtabstop=2 shiftwidth=2 foldmethod=marker
