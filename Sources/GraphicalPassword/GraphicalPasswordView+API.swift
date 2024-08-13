//
//  GraphicalPasswordView+API.swift
//
//  Created by Savva Shuliatev.
//

import SwiftUI

extension GraphicalPasswordView {
  func onDrawEnded(_ action: @escaping (_ password: String) -> Void) -> Self {
    self.onDrawEndedActions.append(action)
    return self
  }

}
