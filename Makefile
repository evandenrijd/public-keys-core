TARGETS:=index.html

.PHONY: all clean
all : $(TARGETS)

clean :
	rm $(TARGETS)

index.html : README.org
	emacs --batch --eval "(require 'org)" $< --funcall org-html-export-to-html
	mv README.html $@
