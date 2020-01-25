;; copyright (c) 2020 by andrei borac

(require "stdio.rb")

(defun stdio-new ()
  (StandardIO (Blob int-65536)))

(defun stdio-fail-fast (err) ;; => 'a
  (case err
        ((ErrorSuccess a) a)
        ((ErrorFailure errno) (system-exit one)))) ;; TODO: print errno

(defun stdio-read (stdio-object fd count) ;; => ErrorSuccess blob:Blob | ErrorFailure errno:Integer
  (case stdio-object
        ((StandardIO common-blob)
         (let ((count (int-min count (blob-length common-blob (Integer)) (Integer)))
               (common-blob-address (Integer))
               (read-retv (Integer))
               (_ (system-blob-address common-blob zero common-blob-address read-retv)))
           (progn
             (system-read fd common-blob-address count read-retv)
             (case (int-lt read-retv zero)
                   ((False) (ErrorSuccess (blob-extract-range common-blob zero read-retv)))
                   ((True) (ErrorFailure (int-negate read-retv)))))))))

(defun stdio-write (stdio-object fd blob off len) ;; => ErrorSuccess written:Integer | ErrorFailure errno:Integer
  (case (int-lte (int-add off len (Integer)) (blob-length blob (Integer)))
        ((False) (ErrorFailure int-22))
        ((True) (let ((blob-address (Integer))
                      (write-retv (Integer))
                      (_ (system-blob-address blob off blob-address write-retv)))
                  (progn
                    (system-write fd blob-address len write-retv)
                    (case (int-lt write-retv zero)
                          ((False) (ErrorSuccess write-retv))
                          ((True) (ErrorFailure (int-negate write-retv)))))))))

(defun stdio-write-fully (stdio-object fd blob off len) ;; => unit:Unit
  (case (int-gt len zero)
        ((False) unit)
        ((True) (let ((written (stdio-fail-fast (stdio-write stdio-object fd blob off len)))
                      (next-off (int-add off written (Integer)))
                      (next-len (int-sub len written (Integer))))
                  (stdio-write-fully stdio-object fd blob next-off next-len)))))
