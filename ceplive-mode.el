;;- - - - - - - - -
;; Cepl Minor Mode
;;- - - - - - - - -
;; Not mandatory but some parts of the coding experience live
;; outside of the language. This is a collection of things
;; to make cepl coding as easy (and hopefully fun) as possible.

(require 'yasnippet)

(make-variable-buffer-local
 (defvar *cepl-snippets-dir* "~/Code/lisp/ceplive-mode/snippets/"))

(defun cepl-test-func ()
  (interactive)
  (insert "(lambda () (print \"cepl-test\"))"))

(defun ceplive-first-hook ()
  (yas-reload-all)
  (yas-activate-extra-mode 'ceplive-mode)
  (ensure-ceplive-loaded))

(defun slime-eval-into-file ()
  "Evaluate the current toplevel form.
store the result in a new global and insert the
var into the code"
  (interactive)
  (cl-destructuring-bind (region-start region-end)
      (slime-region-for-defun-at-point)
    (slime-flash-region region-start region-end)
    (let* ((form (buffer-substring-no-properties region-start region-end))
           (full-form
            (concat "(let ((-res- (progn" form ")))
                       (list (format nil \"~s\" -res-)
                             (swank::save-presented-object -res-)
                             (labels ((lit (x) (or (numberp x)
                                                  (symbolp x)
                                                  (stringp x)
                                                  (and (listp x) (every #'lit x)))))
                                (if (lit -res-) 0 1))))")))

      (end-of-defun)
      (slime-eval-async `(swank:eval-and-grab-output ,full-form)
        (lambda (result)
          (cl-destructuring-bind (output value) result
            (cl-destructuring-bind (str id pres) (read value)
              (newline)
              (if (= pres 1)
                  (slime-insert-presentation str id)
                  (insert str))
              (backward-char (+ 1 (length str)))
              (previous-line))))))))


(defun ensure-ceplive-loaded ()
  "Evaluate the current toplevel form.
store the result in a new global and insert the
var into the code"
  (let* ((form "(unless (find-package :ceplive) (print \"loading ceplive-\") (ql:quickload :ceplive))"))
    (slime-eval-async `(swank:eval-and-grab-output ,form)
      (lambda (result)
        (slime-repl-set-package "ceplive")
        ;; (let ((form "(unless cgl::*gl-window* (cepl:repl) (print \"ceplive loaded-\"))"))
        ;;   (slime-eval-async `(swank:eval-and-grab-output ,form)
        ;;     (lambda (result))))
        ))))

;;;###autoload
(define-minor-mode ceplive-mode
  "Cepl live coding things"
  :lighter " ceplive"
  :keymap (let ((map (make-sparse-keymap)))
            (define-key map (kbd "C-c C-t") 'cepl-test-func)
            map)
  (when (and (not (memq *cepl-snippets-dir* yas-snippet-dirs))
             (file-exists-p *cepl-snippets-dir*))
    (setq yas-snippet-dirs (append yas-snippet-dirs
                                   (list *cepl-snippets-dir*))))
  (add-hook 'ceplive-mode-hook #'ceplive-first-hook))

(provide 'ceplive-mode)
