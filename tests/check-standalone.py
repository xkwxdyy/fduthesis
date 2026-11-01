#!/usr/bin/env python3
"""Check docstrip parity, enhanced theorem counters and the 2026 bibliography."""
from pathlib import Path
import os
import re
import shutil
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]


def run(command, cwd, env=None):
    result = subprocess.run(command, cwd=cwd, env=env, text=True,
                            stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    if result.returncode:
        raise AssertionError(result.stdout[-7000:])
    return result.stdout


def code(path):
    return [line for line in path.read_text().splitlines()
            if line.strip() and not line.lstrip().startswith('%')]


def main():
    run(['l3build', 'unpack', '-q'], ROOT)
    generated = ROOT / 'build/unpacked'
    for name in ('fduthesis.cls', 'fduthesis-en.cls', 'fduthesis.def', 'fdulogo.sty'):
        assert code(ROOT / name) == code(generated / name), name + ' differs from its source'
    with tempfile.TemporaryDirectory(prefix='fduthesis-independent-') as temporary:
        work = Path(temporary)
        for name in ('fduthesis.cls', 'fduthesis-en.cls', 'fduthesis.def', 'fdulogo.sty'):
            shutil.copy2(generated / name, work / name)
        for name in ('fudan-name.pdf', 'gb7714-FDU-2025.bbx', 'gb7714-FDU-2025.cbx'):
            shutil.copy2(ROOT / name, work / name)
        (work / 'main.bib').write_text(
            '@misc{check, author={Template Example}, title={Bibliography check}, year={2026}}\n')
        (work / 'main.tex').write_text(r'''\documentclass[oneside]{fduthesis}
\fdusetup{style={spec=2026,font=lm,cjk-font=fandol,bib-backend=biblatex},
  info={title={独立构建检查},author={示例作者}}}
\addbibresource{main.bib}
\begin{document}
\chapter{检查}
\begin{theorem}\label{thm:one}恒等算子的范数等于一。\end{theorem}
\begin{proof}结论由范数定义得到。\end{proof}
\begin{example}\label{ex:one}恒等算子。\end{example}
\cref{thm:one,ex:one}。文献引用\parencite{check}。
\printbibliography
\end{document}
''')
        env = os.environ.copy()
        env.update(TEXMFHOME=str(work / 'empty-texmf'),
                   TEXMFLOCAL=str(work / 'empty-texmf'), TEXINPUTS='.:', BIBINPUTS='.:')
        command = ['xelatex', '-no-shell-escape', '-halt-on-error',
                   '-interaction=nonstopmode', '-recorder', 'main.tex']
        run(command, work, env)
        run(['biber', 'main'], work, env)
        run(command, work, env)
        run(command, work, env)
        log = (work / 'main.log').read_text()
        assert not re.search(r'^!|undefined references|undefined citations|Overfull', log, re.M)
        assert (work / 'main.pdf').is_file()
        assert 'gb7714-FDU-2025.cbx' in (work / 'main.fls').read_text()
    print('Generated classes, theorem counters, references and 2026 bibliography passed.')


if __name__ == '__main__':
    main()
