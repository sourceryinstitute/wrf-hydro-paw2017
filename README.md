# WRF-Hydro submission to [PAW17]

## Prerequisites: 
LaTeX

## Build instructions

### On macOS 
1. Install and launch TeXShop
2. Open main.tex and click Typeset
3. Select BibTeX and click Typeset
4. At a command line, execute `makeglossaries main`
5. In TeXShop, select LaTeX and click Typeset

### On Linux

Try something of the form
```bash
pdflatex main && bibtex main && makeglossaries main && pdflatex main
```

## Known Issues
* Apple Preview will not display the animation.
* LaTeX must compile main.tex twice for Acrobat Reader to display the Figure 1 animation.

[PAW17]: http://sourceryinstitute.github.io/PAW/
