;;; publish --- Publish org files to GitLab Pages

;;; Commentary:

;; This file takes care of exporting org files to the public directory.
;; Images and such are also exported without any processing.

;;; Code:

(require 'package)
(package-initialize)
(unless package-archive-contents
  (add-to-list 'package-archives '("org" . "https://orgmode.org/elpa/") t)
  (add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
  (package-refresh-contents))
(dolist (pkg '(org-plus-contrib htmlize))
  (unless (package-installed-p pkg)
    (package-install pkg)))

(require 'org)
(require 'ox-publish)

(defun literate-dotfiles--postamble-format (info)
  "Function that formats the HTML postamble.
INFO is a plist used as a communication channel."
  (let ((buffer (plist-get info :input-buffer)))
    (concat "<hr>
<p>
<p class=\"Source\">Source: "
            (format "<a href=\"%s/%s\">%s</a></p>"
                    "https://fred.com/to1ne/literate-dotfiles/blob/master"
                    buffer buffer)
            (unless (equal buffer "README.org")
              "<p>Return to <a href=\"index.html\">index</a>.</p>"))))

(defvar literate-dotfiles--site-attachments
  (regexp-opt '("jpg" "jpeg" "gif" "png" "svg"
                "ico" "cur" "css" "js"
                "eot" "woff" "woff2" "ttf"
                "html" "pdf"))
  "File types that are published as static files.")

(defvar literate-dotfiles--publish-project-alist
  (list
   (list "site-org"
         :base-directory "."
         :base-extension "org"
         :recursive t
         :publishing-function 'org-html-publish-to-html
         :publishing-directory "./public"
         :exclude (regexp-opt '("unused/"))
         :auto-sitemap nil
         :fault-style nil
         :html-head-include-scripts nil
         :html-htmlized-css-url "style.css"
         :html-head-extra
         "<link rel=\"icon\" type=\"image/x-icon\" href=\"/favicon.ico\" />"
         :html-postamble 'literate-dotfiles--postamble-format
         :sitemap-style 'list
         :sitemap-sort-files 'anti-chronologically)
   (list "site-static"
         :base-directory "."
         :exclude (regexp-opt '("public/" "img/design/"))
         :base-extension literate-dotfiles--site-attachments
         :publishing-directory "./public"
         :publishing-function 'org-publish-attachment
         :recursive t)
   (list "site"
         :components '("site-org"))
   ))

(defun literate-dotfiles-publish-all ()
  "Publish the literate dotfiles to HTML."
  (interactive)
  (let ((org-publish-project-alist       literate-dotfiles--publish-project-alist)
        (org-publish-timestamp-directory "./.timestamps/")
;;      (user-full-name                  nil) ;; avoid "Author: x" at the bottom
        (org-export-with-section-numbers nil)
        (org-export-with-smart-quotes    t)
        (org-export-with-toc             nil)
        (org-html-divs '((preamble  "header" "top")
                         (content   "main"   "content")
                         (postamble "footer" "postamble")))
        (org-html-container-element         "section")
        (org-html-metadata-timestamp-format "%Y-%m-%d")
        (org-html-checkbox-type             'html)
        (org-html-html5-fancy               t)
        (org-html-validation-link           nil)
        (org-html-doctype                   "html5")
        (org-html-htmlize-output-type       'css))
    (org-publish-all)))

;;; publish.el ends here
