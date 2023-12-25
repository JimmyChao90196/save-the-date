//
//  Box.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/11/30.
//

import Foundation

final class Box<T> {
  // 1
  typealias Listener = (T) -> Void
  var listener: Listener?
  // 2
  var value: T {
    didSet {
      listener?(value)
    }
  }
  // 3
  init(_ value: T) {
    self.value = value
  }
  // 4
  func bind(listener: Listener?) {
    self.listener = listener
    listener?(value)
  }
}
