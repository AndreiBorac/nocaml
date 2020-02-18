;; copyright (c) 2020 by Andrei Borac

(require "stdopt.rb")

(defun stdopt-fail-fast (opt)
  (case opt
        ((OptionSuccess a) a)
        ((OptionFailure unknown) (abort))))
