;;;; package.lisp

(defpackage #:ceplive
  (:use #:cl #:cepl #:cepl.events.sdl)
  (:shadow :defclass :step))

