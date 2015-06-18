(in-package #:ceplive)

;;--------------------------------------------------

(defun process-class-slot (slot)
  (let ((name (first slot))
        (initform (unless (keywordp (second slot))
                    (second slot))))
    (let* ((slot (append slot `(:initform ,initform)))
           (slot (if (not (member-any '(:accessor :reader :writer) slot))
                     (append slot `(:accessor ,name))
                     slot))
           (slot (if (not (member :initarg slot))
                     (append slot `(:initarg ,(intern (symbol-name name) :keyword)))
                     slot))
           (slot (if (null (second (member :initarg slot)))
                     (let ((ia-pos (position :initarg slot)))
                       (append (subseq slot 0 ia-pos)
                               (subseq slot (+ 2 ia-pos))))
                     slot)))
      slot)))

(defmacro defclass+ (name direct-superclasses &body args)
  (fns ((sym-only-name (x) (when (symbolp x) (symbol-name x))))
    (let* ((option-start (position "&OPTIONS" args :key #'sym-only-name
                                   :test #'equal))
           (options (when option-start (subseq args option-start)))
           (direct-slots (subseq args 0 (or option-start (length args)))))
      `(cl::defclass ,name ,direct-superclasses
         ,(mapcar #'process-class-slot
                  (mapcar #'listify direct-slots))
         ,@options))))

;;--------------------------------------------------

(defmacro let+ (bindings &body body)
  (fns ((gen-form (binding)
                   (if (= (length binding) 3)
                       `(labels (,binding))
                       `(let (,binding)))))
    (if bindings
        (append (gen-form (first bindings))
                `((let+ ,(rest bindings) ,@body)))
        `(progn ,@body))))

;;--------------------------------------------------

(defun call (function &rest arguments)
  (apply #'funcall function arguments))
(def-compiler-macro call (function &rest arguments)
  `(funcall ,function ,@arguments))

;;--------------------------------------------------

(defun member-any (items list &key (key #'id) (test #'eql) test-not)
  (when (and test-not test)
    (error ":TEST and :TEST-NOT were both supplied."))
  (labels ((test (x) (member x items :key key :test test))
           (test-not (x) (member x items :key key :test-not test-not)))
    (if test-not
        (member-if #'test-not list)
        (member-if #'test list))))

(def-compiler-macro member-any (items list &key key test test-not)
  (when (and test-not test)
    (error ":TEST and :TEST-NOT were both supplied."))
  (let ((gitems (gensym "items")))
    `(let ((,gitems ,items))
       (labels (,@(if test-not
                      `((test-not (x) (member x ,gitems
                                          ,@(if key `(:key ,key))
                                          ,@(if test-not `(:test ,test-not)))))
                      `((test (x) (member x ,gitems
                                          ,@(if key `(:key ,key))
                                          ,@(if test `(:test ,test)))))))
         ,(if test-not
              `(member-if #'test-not ,list)
              `(member-if #'test ,list))))))

;;--------------------------------------------------

(defun listify (x) (if (listp x) x (list x)))

;;--------------------------------------------------
