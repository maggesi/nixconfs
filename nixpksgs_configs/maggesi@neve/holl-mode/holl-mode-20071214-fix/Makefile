ELC_FILES = holl-conf.elc holl.elc inferior-holl.elc

default : $(ELC_FILES)

$(ELC_FILES) : %.elc : %.el
	emacs --batch --directory . --funcall batch-byte-compile $<

clean :
	-rm -f $(ELC_FILES)

.PHONY : clean default
