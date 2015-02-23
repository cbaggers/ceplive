;;; Compiled snippets and support files for `ceplive-mode'
;;; Snippet definitions:
;;;
(yas-define-snippets 'ceplive-mode
                     '(("bnd" "(bind (${1:x}) (${2})\n$0)" "ceplive bind" nil nil nil nil "direct-keybinding" nil)
                       ("bndv" "(bind-values (${1:x}) (${2})\n$0)" "ceplive bind-values" nil nil nil nil "direct-keybinding" nil)
                       ("bootstrap" "\n$0\n\n(defun $1 ()\n  (gl:clear :color-buffer-bit :depth-buffer-bit)\n  (cgl:update-display))\n\n(observe (|window|) (when (eq (action e) :resized) (reshape (vec e))))\n(defun reshape (&optional (dims cgl:+default-resolution+))\n  (apply #'gl:viewport 0 0 dims))\n\n(live:main-loop :step ${1:step})" "bootstrap" nil nil nil nil "direct-keybinding" nil)
                       ("cdff" "(deffshader ${1:vert} (${4:&uniform (i :int)})\n  $0)" "Cepl deffshader" nil nil nil nil "direct-keybinding" nil)
                       ("cdfm" "(defsmacro ${1:name} ($2:x)\n  $0)" "Cepl defsmacro" nil nil nil nil "direct-keybinding" nil)
                       ("cdfn" "(defsfun $1 ((${2:arg} ${3::float}))\n$0)" "Cepl defsfun" nil nil nil nil "direct-keybinding" nil)
                       ("cdfp" "(defpipeline ${1:prog-1} ((${2:vert} ${3::vec4})$0)\n(:vertex (setf gl-position ${4:$2)))\n(:fragment (out outputcolor ${5:(v! 0.2 0.5 0.2 1.0)})))" "Cepl Defpipeline" nil nil nil nil "direct-keybinding" nil)
                       ("cdfs" "(defglstruct ${1:gs} ()\n(${2:position} ${3::vec4} :accessor ${4:pos})\n$0)" "Cepl defglstruct" nil nil nil nil "direct-keybinding" nil)
                       ("cdfv" "(defvshader ${1:vert} ((${2:x} ${3::vec4})${4: &uniform (i :int)})\n$0)" "Cepl defvshader" nil nil nil nil "direct-keybinding" nil)
                       ("clear" "(gl:clear ${0::color-buffer-bit :depth-buffer-bit})\n" "gl clear" nil nil nil nil "direct-keybinding" nil)
                       ("df" "(def ${1:name} (${0:val}))" "ceplive def" nil nil nil nil "direct-keybinding" nil)
                       ("dfc" "(defclass ${1:name} (${2})\n$0)" "ceplive defclass" nil nil nil nil "direct-keybinding" nil)
                       ("dfg" "(defmethod ${1:name} ((${2:x} ${3:t}))\n$0)" "ceplive defmethod" nil nil nil nil "direct-keybinding" nil)
                       ("dfn" "(defun ${1:name} (${2:x})\n$0)" "ceplive defun" nil nil nil nil "direct-keybinding" nil)
                       ("gl-options" "(cgl:clear-color 0.0 0.0 0.0 0.0)\n(gl:enable :cull-face)\n(gl:cull-face :back)\n(gl:front-face :ccw)\n(gl:enable :depth-test)\n(gl:depth-mask :true)\n(gl:depth-func :lequal)\n(gl:depth-range 0.0 1.0)\n(gl:enable :depth-clamp)" "Cepl - some basic gl options" nil nil nil nil "direct-keybinding" nil)
                       ("gmap" "(gmap #'${1:draw} ${0:stream})" "cepl gmap" nil nil nil nil "direct-keybinding" nil)
                       ("λ" "λ($0)" "Cepl fn_" nil nil nil nil "direct-keybinding" nil)
                       ("let" "(let ((${1:name} (${2:val}))$3)\n$0)" "ceplive let" nil nil nil nil "direct-keybinding" nil)
                       ("quick-quad" "(defvar ${1:*quad*} (make-gpu-array (list (v! -${2:0.2}  $2 0.0 1.0)\n                                          (v! -$2 -$2 0.0 1.0)\n                                          (v!  $2 -$2 0.0 1.0)\n                                          (v! -$2  $2 0.0 1.0)\n                                          (v!  $2 -$2 0.0 1.0)\n                                          (v!  $2  $2 0.0 1.0))\n                                    :element-type :vec4))\n(defvar ${3:*gstream*} (make-vertex-stream $1))\n$0" "Cepl make a quick quad gpu array" nil nil nil nil "direct-keybinding" nil)))


;;; Do not edit! File generated at Sun Feb 22 19:58:22 2015
