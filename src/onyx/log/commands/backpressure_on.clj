(ns onyx.log.commands.backpressure-on
  (:require [taoensso.timbre :as timbre :refer [info error]]
            [clojure.set :refer [union]]
            [clojure.core.async :refer [>!!]]
            [clojure.data :refer [diff]]
            [onyx.log.commands.common :as common]
            [onyx.log.entry :refer [create-log-entry]]
            [onyx.extensions :as extensions]))

(defmethod extensions/apply-log-entry :backpressure-on
  [{:keys [args]} replica]
  (info "BACKPRESSURE WAS TURNED ON " args)
  (if (= :active (get-in replica [:peer-state (:peer args)]))
    (assoc-in replica [:peer-state (:peer args)] :backpressure)
    replica))

(defmethod extensions/replica-diff :backpressure-on
  [{:keys [args]} old new]
  (second (diff (:peer-state old) (:peer-state new))))

(defmethod extensions/reactions :backpressure-on
  [{:keys [args]} old new diff peer-args]
  [])

(defmethod extensions/fire-side-effects! :backpressure-on
  [{:keys [args]} old new diff state]
  state)

