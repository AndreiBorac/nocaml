;; copyright (c) 2020 by Andrei Borac

(require "amoqueue.rb")

(defun amoqueue-new () ;; => AmoQueue
  (AmoQueue list-fini list-fini))

(defun amoqueue-give (aq e) ;; => AmoQueue
  (case aq ((AmoQueue ff rr) (AmoQueue ff (ListCons e rr)))))

(defun amoqueue-private-normalize (aq) ;; => AmoQueue
  (case aq ((AmoQueue ff rr)
            (case ff
                  ((ListFini)
                   (AmoQueue (reverse rr) list-fini))
                  ((ListCons _ _) aq)))))

(defun amoqueue-peek (aq) ;; => OptionSuccess Pair(e:'a, AmoQueue) | OptionFailure unit:Unit
  (let ((aq (amoqueue-private-normalize aq)))
    (case aq ((AmoQueue ff rr)
              (case ff
                    ((ListFini) (OptionFailure unit))
                    ((ListCons ffhd fftl) (OptionSuccess (Pair ffhd aq))))))))

(defun amoqueue-take (aq) ;; => OptionSuccess Pair(e:'a, AmoQueue) | OptionFailure unit:Unit
  (let ((aq (amoqueue-private-normalize aq)))
    (case aq ((AmoQueue ff rr)
              (case ff
                    ((ListFini) (OptionFailure unit))
                    ((ListCons ffhd fftl) (OptionSuccess (Pair ffhd (AmoQueue fftl rr)))))))))
