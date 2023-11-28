//
//  CalculatorState.swift
//  BiCalculator
//
//  Created by jay on 2023/11/28.
//

import Foundation

enum CalculatorState {
  typealias Operator = CalculatorItem.Operator
  typealias Command = CalculatorItem.Command

  case left(String)
  case leftOp(left: String, op: Operator)
  case leftOpRight(left: String, op: Operator, right: String)
  case error

  var output: String {
    let result =
    switch self {
    case .left(let left):
      left
    case .leftOp(let left, _):
      left
    case .leftOpRight(_, _, let right):
      right
    case .error:
      "Error!"
    }
    guard let number = Double(result) else { return "Error" }
    return Constant.displayFormatter.string(from: number as NSNumber) ?? "0"
  }

  // state transfer function
  func apply(item: CalculatorItem) -> CalculatorState {
    switch item {
    case .command(let command):
      apply(command: command)
    case .digit(let number):
      apply(digit: number)
    case .op(let op):
      apply(op: op)
    case .dot:
      applyDot()
    }
  }

  private func apply(digit: Int) -> CalculatorState {
    switch self {
    case .left(let left):
        .left(left.takesIn(digit: digit))
    case .leftOp(let left, let op):
        .leftOpRight(left: left, op: op, right: "\(digit)")
    case .leftOpRight(let left, let op, let right):
        .leftOpRight(left: left, op: op, right: right.takesIn(digit: digit))
    case .error:
        .left("\(digit)")
    }
  }

  private func apply(command: Command) -> CalculatorState {
    switch command {
    case .clear:
      applyClear()
    case .negate:
      applyNegate()
    case .percent:
      applyPercent()
    }
  }

  private func apply(op: Operator) -> CalculatorState {
    switch op {
    case .plus:
      applyPlus()
    case .minus:
      applyMinus()
    case .multiply:
      applyMultiply()
    case .divide:
      applyDivide()
    case .equal:
      applyEqual()
    }
  }

  private func applyDot() -> CalculatorState {
    switch self {
    case .left(let left):
      return .left(left.takesInDot())
    case .leftOp(let left, let op):
      return op == .equal ? .left("0.") : .leftOpRight(left: left, op: op, right: "0.")
    case .leftOpRight(let left, let op, let right):
      let newRight = right.contains(".") ? right : (right + ".")
      return .leftOpRight(left: left, op: op, right: right.takesInDot())
    case .error:
      return .left("0.")
    }
  }

  // MARK: - Apply command

  private func applyClear() -> CalculatorState {
    .left("0")
  }

  private func applyNegate() -> CalculatorState {
    switch self {
    case .left(let left):
      .left(negate(string: left))
    case .leftOp(left: let left, op: let op):
      .leftOpRight(left: left, op: op, right: "-0")
    case .leftOpRight(left: let left, op: let op, right: let right):
      .leftOpRight(left: left, op: op, right: negate(string: right))
    case .error:
      .left("-0")
    }
  }

  private func applyPercent() -> CalculatorState {
    switch self {
    case .left(let left):
      .left(percent(string: left))
    case .leftOp(left: let left, op: let op):
      .leftOp(left: percent(string: left), op: op)
    case .leftOpRight(left: let left, op: let op, right: let right):
      .leftOpRight(left: left, op: op, right: percent(string: right))
    case .error:
      .error
    }
  }

  // MARK: - Apply operator

  private func applyOperator(operatr: Operator) -> CalculatorState {
    switch self {
    case .left(let left):
      return .leftOp(left: left, op: operatr)
    case .leftOp(let left, _):
      return .leftOp(left: left, op: operatr)
    case .leftOpRight(let left, let op, let right):
      // calculate as the input sequence, not as the arithmetic associative property
      guard let left = Double(left), let right = Double(right) else { return .error }
      // divided by zero
      if right == 0 && op == .divide { return .error }
      let result = calculate(left: left, op: op, right: right)
      return .leftOp(left: "\(result)", op: operatr)
    case .error:
      return .leftOp(left: "0", op: operatr)
    }
  }

  private func applyPlus() -> CalculatorState {
    applyOperator(operatr: .plus)
  }

  private func applyMinus() -> CalculatorState {
    applyOperator(operatr: .minus)
  }

  private func applyMultiply() -> CalculatorState {
    applyOperator(operatr: .multiply)
  }

  private func applyDivide() -> CalculatorState {
    applyOperator(operatr: .divide)
  }

  private func applyEqual() -> CalculatorState {
    switch self {
    case .left(let left):
      return .left(left)

    case .leftOp(let left, let op):
      // 2+ takes in =, means 2+2

      guard let left = Double(left) else { return .error }
      // divided by zero
      if left == 0 && op == .divide { return .error }
      let result = calculate(left: left, op: op, right: left)
      return .leftOp(left: "\(result)", op: op)
    case .leftOpRight(let left, let op, let right):
      guard let left = Double(left), let right = Double(right) else { return .error }
      // divided by zero
      if right == 0 && op == .divide { return .error }
      let result = calculate(left: left, op: op, right: right)
      return .left("\(result)")
    case .error:
      return .left("0")
    }
  }

  // MARK: - Helpers

  private func negate(string: String) -> String {
    string.starts(with: "-") ? String(string.dropFirst()) : "-\(string)"
  }

  private func percent(string: String) -> String {
    guard let number = Double(string) else { return "Error" }
    return "\(number/100)"
  }

  public func calculate(left: Double, op: Operator, right: Double) -> Double {
    let result =
    switch op {
    case .plus:
      left + right
    case .minus:
      left - right
    case .multiply:
      left * right
    case .divide:
      left / right
    case .equal:  // there is no such state that an `equal` is between two operands
      0.0
    }
    return result
  }
}

// MARK: - description for debugging & testing

extension CalculatorState {
  var left: String? {
    switch self {
    case .left(let left):
      left
    case .leftOp(let left, _):
      left
    case .leftOpRight(let left, _, _):
      left
    case .error:
      nil
    }
  }

  var right: String? {
    switch self {
    case .left, .leftOp, .error:
      nil
    case .leftOpRight(_, _, let right):
      right
    }
  }

  var op: String? {
    switch self {
    case .left, .error:
      nil
    case .leftOp(_, op: let op):
      op.rawValue
    case .leftOpRight(_, op: let op, _):
      op.rawValue
    }
  }

  var isError: Bool {
    if case .error = self {
      true
    } else {
      false
    }
  }
}

extension CalculatorState: Equatable {
  static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.left == rhs.left
    && lhs.right == rhs.right
    && lhs.op == rhs.op
    && lhs.isError == rhs.isError
  }
}

extension String {
  func takesIn(digit: Int) -> String {
    if digit == 0 && (self == "0" || self == "-0") {
      self
    } else {
      self + "\(digit)"
    }
  }

  func takesInDot() -> String {
    self.contains(".") ? self : (self + ".")
  }
}
