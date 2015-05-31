(in-package :ceplive)
(named-readtables:in-readtable fn:fn-reader)

;; (gl:front-face :cw)

(defvar tx)
(defvar tx2)
(defvar strm)
(defvar cam)

(defun-g vert ((vert g-pnt) &uniform (mod-clip :mat4))
  (values (* mod-clip (v! (pos vert) 1))
          (pos vert)
          (tex vert)))

(defun-g frag ((tc :vec3) (tc2 :vec2) &uniform (tex :sampler-cube) (tex2 :sampler-2d))
  ;(texture tex tc)
  (s~ (texture tex2 tc2) :wyzx))

(defpipeline skybox () (cgl:g-> #'vert #'frag))

(defun make-cubemap-tex (&rest paths)
  (with-c-arrays (ca (mapcar #'devil-helper:load-image-to-c-array paths))
    (make-texture ca :internal-format :rgb8 :cubes t)))

(defun init ()
  (setf tx (make-cubemap-tex "left.png" "right.png" "up.png"
                             "down.png" "front.png" "back.png"))
  (let* ((bx (primitives:box-data))
         (data (make-gpu-array (first bx) :element-type 'g-pnt))
         (ind (make-gpu-array (primitives:swap-winding-order (second bx))
                              :element-type :ushort)))
    (setf strm (make-buffer-stream data :index-array ind
                                   :retain-arrays t)))
  (setf cam (make-camera)))

(defun step ()
  (gl:clear :color-buffer-bit :depth-buffer-bit)
  (gmap #'skybox strm :tex tx :tex2 text-tex :mod-clip (m4:m* (cam->clip cam) (world->cam cam)))
  (cgl:update-display))

(defvar mouse-ang (v! 0 0))
(evt:observe (evt:|mouse|)
  (when (typep e 'evt.sdl:mouse-motion)
    (let ((d (evt.sdl:delta e)))
      (setf mouse-ang (v2:v+ (v! (/ (v:x d) -100.0) (/ (v:y d) -100.0))
                             mouse-ang)
            (dir cam) (v! (sin (v:x mouse-ang))
                          (sin (v:y mouse-ang))
                          (cos (v:x mouse-ang)))))))

(observe (|window|) (when (eq (action e) :resized) (reshape (vec e))))
(defun reshape (&optional (dims cgl:+default-resolution+))
  (apply #'gl:viewport 0 0 dims))

(live:main-loop :init init :step step)


;; (ql:quickload :cl-cairo2)

(defvar slide-size cgl:+DEFAULT-RESOLUTION+)
(defvar sfc)
(defvar ctx)
(defvar background-tex nil)
(defvar text-tex nil)
(defun init-cairo-stuff ()
  (setf sfc (cairo:create-image-surface
             :argb32 (first slide-size) (second slide-size)))
  (setf ctx (cairo:create-context sfc)))

(defun make-text (text position)
  (cairo:select-font-face "Sans" :normal :bold ctx)
  (cairo:set-font-size 24 ctx)
  (cairo:move-to (floor (v:x position)) (floor (v:y position)) ctx)
  (cairo:show-text text ctx)
  (let ((ca (cgl:make-c-array-from-pointer
             slide-size :ubyte-vec4
             (cairo:image-surface-get-data sfc :pointer-only t))))
    (if text-tex
        (push-g ca text-tex)
        (setf text-tex (make-texture ca :internal-format :RGBA8)))))

(defun clear-surface ()
  (cairo:set-source-rgb 1 1 1 ctx)
  (cairo:rectangle 0 0 (first slide-size) (second slide-size) ctx)
  (cairo:fill-path ctx))
