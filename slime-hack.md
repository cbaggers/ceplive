needd suugestions while livecoding?

    (defun slime-background-activities-enabled-p ()
      (and (let ((con (slime-current-connection)))
             (and con
                  (eq (process-status con) 'open)))
           (or (not (slime-busy-p))
               t ;; baggers changed this
               (not slime-inhibit-pipelining))))
