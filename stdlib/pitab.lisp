;; copyright (c) 2020 by andrei borac

(require "pitab.rb")

(defun pitab-new-empty () ;; => list(PitabEntry)
  list-fini)

(defun pitab-new-blob (blob) ;; => list(PitabEntry)
  (let ((len (blob-length blob (Integer))))
    (case (int-gt len zero)
          ((False) list-fini)
          ((True) (ListCons (PitabEntry blob zero len) list-fini)))))

(defun pitab-concat (pta ptb) ;; => list(PitabEntry)
  (concat pta ptb))

(defun pitab-concat-all (pts) ;; => list(PitabEntry)
  (concat-all pts))

(defun pitab-length (pts) ;; => Integer
  (foldl (lambda (z e)
           (case e ((PitabEntry blob off len) (int-add z len (Integer)))))
         zero
         pts))

(defun pitab-coalesce-private-form-instructions (pts sum acc)
  (case pts
        ((ListFini) acc)
        ((ListCons head tail)
         (case head ((PitabEntry head-blob head-off head-len)
                     (selfcall tail
                               (int-add sum head-len (Integer))
                               (ListCons (Vector4 sum head-len head-blob head-off) acc)))))))

(defun pitab-coalesce-private-handle-element (out e)
  (case e
        ((Vector4 off len src src-off)
         (blob-copy-range out off len src src-off))))

(defun pitab-coalesce-private-iter (ins out)
  (case ins
        ((ListFini)
         unit)
        ((ListCons head tail)
         (progn
           (pitab-coalesce-private-handle-element out head)
           (selfcall tail out)))))

(defun pitab-coalesce (pts) ;; => Blob
  (let ((oal (pitab-length pts))
        (ins (pitab-coalesce-private-form-instructions pts zero list-fini))
        (out (Blob oal)))
    (progn
      (pitab-coalesce-private-iter ins out)
      out)))

(defun pitab-head-private (pts len acc)
  (case pts
        ((ListFini) (OptionFailure unit))
        ((ListCons head tail)
         (case head
               ((PitabEntry head-blob head-off head-len)
                (case (int-lt head-len len)
                      ((False)
                       ;; head-len >= len, so we can end here
                       (OptionSuccess (reverse (ListCons (PitabEntry head-blob head-off len) acc))))
                      ((True)
                       ;; head-len < len, so we must continue
                       (pitab-head-private tail (int-sub len head-len (Integer)) (ListCons head acc)))))))))

(defun pitab-head (pts len) ;; => OptionSuccess list(PitabEntry) | OptionFailure Unit
  (pitab-head-private pts len list-fini))

(defun pitab-rest (pts ska) ;; => OptionSuccess list(PitabEntry) | OptionFailure Unit
  (case pts
        ((ListFini)
         ;; no more pieces
         (case (int-lte ska zero)
               ((False)
                ;; ska > 0, but we have no more pieces
                (OptionFailure unit))
               ((True)
                ;; ska == 0, ok
                (OptionSuccess list-fini))))
        ((ListCons head tail)
         ;; at least one piece left
         (case head
               ((PitabEntry head-blob head-off head-len)
                (case (int-lt ska head-len)
                      ((False)
                       ;; ska < head-len, start here
                       (OptionSuccess (ListCons (PitabEntry head-blob
                                                            (int-add head-off ska (Integer))
                                                            (int-sub head-len ska (Integer)))
                                                tail)))
                      ((True)
                       ;; ska >= head-len, continue
                       (pitab-rest tail (int-sub ska head-len (Integer))))))))))
