(defpackage :cl-upp
  (:use :common-lisp :st-json)
  (:export #:read-spec #:include-c++))

(cl::in-package :cl-upp)

(defun adjust-symbol (name)
  "C convention to Common Lisp name convention"
  (substitute #\- #\_ (string-upcase name)))

(defun read-builtin (obj)
  (if (from-json-bool (getjso "float" obj))
      (case (getjso "bits" obj)
        (32 :float)
        (64 :double)
        (128 :long-double))
      (if (from-json-bool (getjso "signed" obj))
          (case (getjso "bits" obj)
            (8 :byte)
            (16 :int16-t)
            (32 :int32-t)
            (64 :int64-t))
          (case (getjso "bits" obj)
            (8 :unsigned-byte)
            (16 :uint16-t)
            (32 :uint32-t)
            (64 :uint64-t)))))

(defun read-type (obj)
  (let ((kind (getjso "kind" obj)))
    (cond ((string= kind "Builtin") (read-builtin obj))
          ((string= kind "Pointer")
           (let ((pointee (getjso "pointee" obj)))
             (if (string= "Record" (getjso "kind" pointee))
                 :pointer-void
                 `(* ,(read-type pointee)))))
          (t :unknown-kind))))

(defun read-function (name obj)
  "Read function from a JSON object"
  (let ((cname (getjso "cname" obj)))
    `(ffi:def-function (,cname ,(intern (adjust-symbol cname)))
         ,(mapcar #'(lambda (val) (list (intern (adjust-symbol (getjso "cname" val)))
                                        (read-type (getjso "type" val))))
                  (getjso "args" obj))
       :returning ,(read-type (getjso "return" obj)))))

(defun read-class (name obj) "Read class from a JSON object"
  `(ffi:def-foreign-type ,(intern (adjust-symbol (getjso "cname" obj))) :pointer-void))

(defun read-spec (path)
  (format t "Read library: ~A~%" path)
  (let* ((spec (read-json-as-type (open path :direction :input) 'st-json:jso))
         (classes (getjso "class" spec))
         (functions (getjso "function" spec))
         (output '())
         (count 0))
    ;; declare pointers
    (mapjso #'(lambda (key value)
                (format t "Class #~A: ~A~%" count key) (incf count)
                (push (read-class key value) output))
            classes)
    ;; declare the foreign C function
    (setq count 0)
    (mapjso #'(lambda (key value)
                (format t "Function #~A: ~A ~S~%" count key (read-function key value)) (incf count)
                (push (read-function key value) output))
            functions)
    (push 'progn output)
    output))

(defmacro include-c++ (path)
  (read-spec (eval path)))
