syntax on
set tabstop=4
set shiftwidth=4
set backspace=indent,eol,start  " allow backspacing over everything
set laststatus=2  " always display status line

set number relativenumber
augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
  autocmd BufLeave,FocusLost,InsertEnter   * set norelativenumber
augroup END
