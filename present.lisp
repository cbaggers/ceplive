(in-package :ceplive)
(named-readtables:in-readtable fn:fn-reader)

(defvar strm)
(defvar cam)

(defun-g vert ((vert g-pnt))
  (values (v! (pos vert) 1) (pos vert) (tex vert)))

(defun-g frag ((offset :vec3) (tc2 :vec2) &uniform (tex :sampler-2d) (background :sampler-2d) (ratio :vec2))
  (let* ((c (* tc2 ratio))
         (c2 (v! (min (x c) 1) (min (y c) 1)))
         (x (x (texture tex c2))))
    (+ (v! 0.1 0.1 0.1)
       (* (s~ (texture background tc2) :xyz) (- 1 x)))))

(defpipeline skybox () (cgl:g-> #'vert #'frag))

(defun make-cubemap-tex (&rest paths)
  (with-c-arrays (ca (mapcar #'devil-helper:load-image-to-c-array paths))
    (make-texture ca :internal-format :rgb8 :cubes t)))

(defun init ()
  (setf slide-size cgl:+DEFAULT-RESOLUTION+)
  (init-cairo-stuff)
  (let* ((bx (primitives:plain-data))
         (data (make-gpu-array (first bx) :element-type 'g-pnt))
         (ind (make-gpu-array (second bx) :element-type :ushort)))
    (setf strm (make-buffer-stream data :index-array ind
                                   :retain-arrays t)))
  (setf cam (make-camera)))

(defun step ()
  (gl:clear :color-buffer-bit :depth-buffer-bit)
  (gmap #'skybox strm :tex text-tex :background background-tex
        :ratio (v! (/ (first resolution) (first slide-size))
                   (/ (second resolution) (second slide-size))))
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

(observe (|window|) (when (eq (action e) :resized) (reshape (data e))))

(defun reshape (&optional (dims cgl:+default-resolution+))
  (apply #'gl:viewport 0 0 dims)
  (print dims)
  (setf slide-size (list (expt 2 (floor (log (first dims) 2)))
                         (expt 2 (floor (log (second dims) 2)))))
  (setf resolution dims)
  (when text-tex
    (print "free texture")
    (cgl::gl-free text-tex)
    (cairo:destroy sfc)
    (setf sfc (cairo:create-image-surface
               :A8 (first slide-size) (second slide-size)))
    (setf ctx (cairo:create-context sfc))
    (setf text-tex nil))
  (when last-args
    (apply #'make-text last-args)))

(live:main-loop :init init :step step)



;;(ql:quickload :cl-cairo2)

(defvar resolution cgl:+DEFAULT-RESOLUTION+)
(defvar slide-size cgl:+DEFAULT-RESOLUTION+)
(defvar sfc)
(defvar ctx)
(defvar background-tex nil)
(defvar text-tex nil)
(defparameter title-size 20)
(defparameter body-size 15)
(defparameter code-size 10)
(defvar last-args nil)
(defun init-cairo-stuff ()
  (cgl:clear-color 1.0 0 0 1.0)
  (setf sfc (cairo:create-image-surface
             :A8 (first slide-size) (second slide-size)))
  (setf ctx (cairo:create-context sfc))
  (setf background-tex (devil-helper:load-image-to-texture "/home/baggers/Code/lisp/ceplive-mode/back.jpg")))

(defun make-text (texts position &optional (clear t))

  (setf last-args (list texts position clear))
  (when clear (clear-surface))
  (let ((y (floor (v:y position))))
    (loop :for (type text) :in texts :do
       (let ((font-size (* (float (/ (first resolution) 640))
                           (case type
                             (:title title-size)
                             (:body body-size)
                             (:code code-size)
                             (otherwise 20)))))
         (cairo:set-font-size font-size ctx)
         (if (eq type :code)
             (cairo:select-font-face "Ubuntu Mono" :normal :bold ctx)
             (cairo:select-font-face "Ubuntu" :normal :bold ctx))
         (cairo:set-source-rgba 1.0 1.0 1.0 1 ctx)
         (let ((lines (split-sequence:split-sequence #\newline text)))
           (loop :for line :in lines :do
              (cairo:move-to (floor (v:x position)) y ctx)
              (cairo:show-text line ctx)
              (incf y (* 1.2 font-size)))))))
  (let ((ca (cgl:make-c-array-from-pointer
             slide-size :ubyte
             (cairo:image-surface-get-data sfc :pointer-only t))))
    (if text-tex (print "use tex") (print "new tex"))
    (if text-tex
        (push-g (print ca) (print text-tex))
        (setf text-tex (print (make-texture ca :internal-format :R8))))))

(defun clear-surface ()
  (cairo:set-operator :clear ctx)
  (cairo:set-source-rgba 1 1 1 1 ctx)
  (cairo:rectangle 0 0 (first slide-size) (second slide-size) ctx)
  (cairo:fill-path ctx)
  (cairo:surface-flush sfc)
  (cairo:set-operator :over ctx))
