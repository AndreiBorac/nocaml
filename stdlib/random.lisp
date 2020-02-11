;; copyright (c) 2020 by Andrei Borac

(require "random.rb")

(defun random-new () ;; => Random
  (Random (AmoQueue list-int-random-24 list-fini) (AmoQueue list-int-random-31 list-fini)))

(defun random-next (r) ;; => Pair(Integer, Random)
  (case r
        ((Random qj qk)
         (case (stdopt-fail-fast (amoqueue-take qj))
               ((Pair ej qjp)
                (let ((qkp (amoqueue-give qk ej)))
                  (case (stdopt-fail-fast (amoqueue-take qkp))
                        ((Pair ek qkpp)
                         (let ((sum (int-add ej ek (Integer))))
                           (let ((qjpp (amoqueue-give qjp sum)))
                             (Pair sum (Random qjpp qkpp))))))))))))

(defun random-skip (r a) ;; => Random
  (case (int-gt a zero)
        ((False) r)
        ((True) (random-skip (case (random-next r) ((Pair _ rp) rp)) (int-sub a one (Integer))))))
