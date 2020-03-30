;; copyright (c) 2020 by Andrei Borac

(require "abort.lisp")
(require "stdlib.lisp")
(require "stdopt.lisp")
(require "pitab.lisp")
(require "stdio.lisp")

(defun main (argv envp)
  (let ((args (pitab-concat-all (map (lambda (argi) (pitab-new-blob argi)) argv))))
    (progn
      (let ((coal (pitab-coalesce args)))
        (stdio-write-fully (stdio-new) one coal zero (blob-length coal (Integer))))
      zero)))
