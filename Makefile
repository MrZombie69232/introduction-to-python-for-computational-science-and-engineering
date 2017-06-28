all:
	make check-py35
	make notebooks-html
	make notebooks-pdf

notebooks-pdf: *-*.ipynb templates/latex_template.tplx
	@echo "Attempting to create combined.pdf from notebooks"
	python3 -m bookbook.latex --pdf --template templates/latex_template.tplx
	@mkdir -p pdf
	mv -v combined.pdf pdf/Introduction-to-Python-for-Computational-Science-and-Engineering.pdf

notebooks-html: check-py35
	@echo "Attempting to create html version (in ./html)"
	python3 -m bookbook.html
	@echo "Output stored in html/*html; start with html/index.html"

install-conversion-deps: check-py35
	# for html
	pip install bookbook
	# for lalex/pdf
	pip install pandocfilters
	# for nbval
	pip install nbval

check-py35:
	@echo "Checking Python version is >= 3.5"
	@python3 -c "import sys; assert sys.version_info[0] >= 3"
	@python3 -c "import sys; assert sys.version_info[1] >= 5"
	@echo "        (ok)"

nbval:
	py.test -v --nbval-lax *.ipynb

clean:
	rm -rf *.aux *.out *.log combined_files


# To use Docker container for building and testing

# build docker image locally, needs to be done first
docker-build:
	cd tools/docker && docker build -t python4compscience .

# build pdf and html through container
docker-html:
	docker run -v `pwd`:/io python4compscience make notebooks-html

docker-pdf:
	docker run -v `pwd`:/io python4compscience make notebooks-pdf

docker-nbval:
	docker run -v `pwd`:/io python4compscience make nbval
