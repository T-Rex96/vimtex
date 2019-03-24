" Parsing is mostly adapted from the Denite source
function! s:parse_toc()
python3 << EOF
import vim

def format_number(n):
  if not n or not type(n) is dict or not 'chapter' in n:
      return ''

  num = [str(n[k]) for k in [
         'chapter',
         'section',
         'subsection',
         'subsubsection',
         'subsubsubsection'] if n[k] != '0']

  if n['appendix'] != '0':
     num[0] = chr(int(num[0]) + 64)

  return '.'.join(num)

def create_candidate(e, depth):
  number = format_number(dict(e['number']))

  return f"{e.get('line', 0)} {e['file']} {e['title']:65} {number}"

entries = vim.eval('vimtex#parser#toc(b:vimtex.tex)')
depth = max([int(e['level']) for e in entries])
candidates = [create_candidate(e, depth) for e in entries]
vim.command(f"let candidates = {candidates}")
EOF

  return candidates
endfunction

function! vimtex#fzf#open_selection(sel)
  execute printf('edit +%s %s', split(a:sel)[0], split(a:sel)[1])
endfunction

function! vimtex#fzf#run()
  " The --with-nth 3.. option hides the first two words from the 
  " fzf window which we used to pass on the file name and line number
  call fzf#run({  'source':  <sid>parse_toc(),
        \   'sink':    function('vimtex#fzf#open_selection'),
        \   'options': '--ansi --with-nth 3..'  
        \ })
endfunction

