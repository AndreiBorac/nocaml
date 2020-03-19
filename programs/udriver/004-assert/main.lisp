;; copyright (c) 2020 by Andrei Borac

(require "abort.lisp")
(require "stdlib.lisp")
(require "stdopt.lisp")
(require "pitab.lisp")
(require "stdio.lisp")

(defun assert (stdio str f)
  (progn
    (stdio-write-fully stdio two str zero (blob-length str (Integer)))
    (case (f)
          ((False) (system-exit one))
          ((True) unit))))


(defun main (argv envp)
  (let ((stdio (stdio-new)))
    (progn
      (assert stdio
              blob-empty
              (lambda () false))
      zero)))
