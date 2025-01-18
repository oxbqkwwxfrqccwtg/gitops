augroup filetypedetect
    autocmd!
    autocmd BufRead,BufNewFile *.ac-*.m4 set filetype=config
    autocmd BufRead,BufNewFile **/*.yaml.m4 set filetype=yml
augroup END
