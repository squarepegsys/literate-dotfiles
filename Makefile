cache_dir := .cache
publish_dir := public
timestamps_dir := .timestamps
docs := ReadMe.org sitemap.org
orgs := $(filter-out $(docs), $(wildcard *.org))
emacs_pkgs := org
export PATH := /opt/local/bin/:$(PATH)

publish_el := elisp/publish.el
tangle_el := elisp/tangle.el

^el = $(filter %.el,$^)
EMACS.funcall = ~/bin/emacs --batch --no-init-file $(addprefix --load ,$(^el)) --funcall

all: publish tangle

test: tangle

publish: $(publish_el) $(orgs)
	$(EMACS.funcall) literate-dotfiles-publish-all

clean:
	rm -rf $(publish_dir)
	rm -rf $(timestamps_dir)s
	rm -rf $(cache_dir)

tangle: $(basename $(orgs))

# https://emacs.stackexchange.com/a/27128/2780
$(cache_dir)/%.out: %.org $(tangle_el) $(cache_dir)/
	$(EMACS.funcall) literate-dotfiles-tangle $< > $@

%/:
	mkdir -p $@

%: %.org $(cache_dir)/%.out
	@$(NOOP)

git: emacs_pkgs = gitconfig-mode gitattributes-mode gitignore-mode

.PHONY: all clean
.PRECIOUS: $(cache_dir)/ $(cache_dir)/%.out
