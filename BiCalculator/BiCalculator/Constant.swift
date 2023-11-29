//
//  Constant.swift
//  BiCalculator
//
//  Created by jay on 2023/11/27.
//

import UIKit

enum Constant {
  static let screenWidth = UIScreen.main.bounds.width
  static let screenHeight = UIScreen.main.bounds.height

  static let minorScreenWidth = min(screenWidth, screenHeight)

  static let displayFormatter: NumberFormatter = {
    let fmt = NumberFormatter()
    fmt.minimumFractionDigits = 0
    fmt.maximumFractionDigits = 12
    fmt.numberStyle = .decimal
    return fmt
  }()
}
