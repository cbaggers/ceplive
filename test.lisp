(in-package :ceplive)




(defun step ()
  (gl:clear :color-buffer-bit :depth-buffer-bit)
  (cgl:update-display))

(observe (|window|) (when (eq (action e) :resized) (reshape (vec e))))
(defun reshape (&optional (dims cgl:+default-resolution+))
  (apply #'gl:viewport 0 0 dims))

(live:main-loop :step step)
