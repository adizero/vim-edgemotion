"=============================================================================
" FILE: plugin/edgemotion.vim
" AUTHOR: haya14busa
" License: MIT license
"=============================================================================
scriptencoding utf-8
if expand('%:p') ==# expand('<sfile>:p')
  unlet! g:loaded_edgemotion
endif
if exists('g:loaded_edgemotion')
  finish
endif
let g:loaded_edgemotion = 1

noremap <Plug>(edgemotion-j) <Cmd>call edgemotion#do_move(1, v:count1)<CR>
noremap <Plug>(edgemotion-k) <Cmd>call edgemotion#do_move(0, v:count1)<CR>

" __END__
" vim: expandtab softtabstop=2 shiftwidth=2 foldmethod=marker
