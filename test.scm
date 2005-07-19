;;;
;;; Test dbd.pg
;;;

(use gauche.test)
(use gauche.collection)
(use srfi-1)
(use srfi-13)

(test-start "dbd.pg")
(use dbi)
(use dbd.pg)
(test-module 'dbd.pg)

;; dbi-make-driver �Υƥ���:
;; "pg" �ɥ饤�С�����ɤ���
;; ���饹 <pg-driver> �Υ��󥹥��󥹤��ä�����
(define pg-driver (dbi-make-driver "pg"))
(test* "dbi-make-driver pg"
       #t
       (is-a? pg-driver <pg-driver>))

;; dbi-make-connection �Υƥ���:
;; <pg-driver>���Υ��󥹥��󥹤�����ˤ����Ȥ�
;; dbi-make-connection ������ͤ� 
;; <pg-connection>���Υ��󥹥��󥹤��ä�����
;; ��: (sys-getenv "USER")�Ǽ����������ߤΥ桼�������ѥ���ɤʤ���
;;     PostgreSQL�Υǥե���ȥǡ����١�������³�Ǥ���ɬ�פ����롣
(define current-user (sys-getenv "USER"))
(define pg-connection
  (dbi-make-connection pg-driver current-user "" ""))
(test* "dbi-make-connection <pg-driver>"
       #t
       (is-a? pg-connection <pg-connection>))

;; dbi-make-query �Υƥ���:
;; <pg-connection>���Υ��󥹥��󥹤�����ˤ����Ȥ�
;; dbi-make-query������ͤ�
;; <pg-query>���Υ��󥹥��󥹤��ä�����
(define pg-query (dbi-make-query pg-connection))
(test* "dbi-make-query <pg-connection>"
       #t
       (is-a? pg-query <pg-query>))

;;;; test�ơ��֥��drop���Ƥ���
(with-error-handler
    (lambda (e) #t)
  (lambda () (dbi-execute-query pg-query "drop table test")))
;;;; test�ơ��֥��������Ƥ���
(dbi-execute-query pg-query "create table test (id integer, name varchar)")
;;;; test�ơ��֥�˥ǡ�����insert���Ƥ���
(dbi-execute-query pg-query
		   "insert into test (id, name) values (10, 'yasuyuki')")
(dbi-execute-query pg-query
		  "insert into test (id, name) values (20, 'nyama')")

;; dbi-execute-query �Υƥ���:
;; <pg-query>���Υ��󥹥��󥹤�����ˤ����Ȥ�
;; dbi-execute-query ������ͤ�
;; <pg-result-set>���Υ��󥹥��󥹤��ä�����
(define pg-result-set (dbi-execute-query pg-query "select * from test"))
(test* "dbi-execute-query <pg-query>"
       #t
       (is-a? pg-result-set <pg-result-set>))

;; dbi-get-value�Υƥ���:
;; map ����� pg-get-value ��Ȥä� <pg-result-set> ���餹�٤ƤιԤ��������
;; ���餫���� insert���줿 (("10" "yasuyuki") ("20" "nyama")) ����������й��
(test* "dbi-get-value with map"
       '(("10" "yasuyuki") ("20" "nyama"))
  (map (lambda (row)
	      (list (dbi-get-value row 0) (dbi-get-value row 1)))
	    pg-result-set))

;; dbi-close <dbi-result-set> �Υƥ���:
;; <pg-result-set>���Υ��󥹥��󥹤�close���ƺ��٥�����������
;; <dbi-exception>��ȯ����������
(dbi-close pg-result-set)
(test* "dbi-close <pg-result-set>" *test-error*
       (dbi-close pg-result-set))

;; dbi-close <dbi-query> �Υƥ���:
;; <pg-query>���Υ��󥹥��󥹤�close���ƺ��٥�����������
;; <dbi-exception>��ȯ����������
(dbi-close pg-query)
(test* "dbi-close <pg-query>" *test-error*
       (dbi-close pg-query))

;; dbi-close <dbi-connection> �Υƥ���:
;; <pg-connection>���Υ��󥹥��󥹤�close���ƺ��٥�����������
;; <dbi-exception>��ȯ����������
(dbi-close pg-connection)
(test* "dbi-close <pg-connection>" *test-error*
       (dbi-close pg-connection))

;; epilogue
(test-end)





