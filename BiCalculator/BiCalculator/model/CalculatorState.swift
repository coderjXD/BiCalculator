//
//  CalculatorState.swift
//  BiCalculator
//
//  Created by jay on 2023/11/28.
//

import Foundation

enum CalculatorState {
  case left(String)
  case leftOp(left: String, op: CalculatorItem.Operator)
}
