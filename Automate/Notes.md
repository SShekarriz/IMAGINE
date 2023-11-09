Automating the generation of documents
======================================

1. Create a template document so that you only change one thing
3. Figure out how to automatically populate the .Rmd situation
2. Use the R command that RStudio uses to typeset the documents
		* `rmarkdown::render('/home/jcszamosi/Projects/Mine/IMAGINE/ParticipantDocument/Example.Rmd', encoding = 'UTF-8', knit_root_dir = '~/Projects/Mine/IMAGINE/ParticipantDocument');`

This is probably a MAKE situation.

Targets: 
* the .Rmd files
* the .tex files
* the .pdf files
* clean data

Prerequisites:
* clean data
* the asv table
* the tax table
* the sample data

Steps:
* Run whatever preparatory scripts are required to clean the data
* Use `cat`, maybe `python`, to generate the .Rmd files
* Use R to generate the .tex files
* Use R or pdfLaTeX to generate the .pdf files

To Do:

* Start by writing an R script that runs `rmarkdown::render()` once
