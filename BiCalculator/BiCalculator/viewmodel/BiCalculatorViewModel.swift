//
//  BiCalculatorViewModel.swift
//  BiCalculator
//
//  Created by jay on 2023/11/28.
//

import SwiftUI

class BiCalculatorViewModel: ObservableObject {
  
  @Published var state = CalculatorState.leftPending("0")

  @Published var isPortrait = true

  let pads: [[CalculatorItem]] = [
    [.command(.clear), .command(.negate), .command(.percent), .op(.divide)],
    [.digit(7), .digit(8), .digit(9), .op(.multiply)],
    [.digit(4), .digit(5), .digit(6), .op(.minus)],
    [.digit(1), .digit(2), .digit(3), .op(.plus)],
    [.digit(0), .dot, .op(.equal)],
  ]

  func apply(item: CalculatorItem) {
    state = state.apply(item: item)
  }
}


