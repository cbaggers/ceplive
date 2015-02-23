;;;; ceplive.asd

(asdf:defsystem #:ceplive
  :description "Describe ceplive here"
  :author "Your Name <your.name@example.com>"
  :license "Specify license here"
  :serial t
  :depends-on (#:cepl #:optima)
  :components ((:file "package")
               (:file "ceplive")))

