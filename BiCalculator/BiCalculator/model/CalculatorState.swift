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

  // pending means you can still append digits to this operand, like 2 -> 23 -> 234
  case leftPending(String)
  // done means the operand is a result of previous calculation, it cannot append digits any more.
  // e.g. 2 x 3 = 6, then you input a `2`, it cannot become 62, but start a new calculation
  case leftDone(String)
  case leftOp(left: String, op: Operator)
  case leftOpRightPending(left: String, op: Operator, right: String)
  case leftOpRightDone(left: String, op: Operator, right: String)
  case error

  var output: String {
    switch self {
    case .leftPending(let left):
      pendingOutput(str: left)
    case .leftDone(let left):
      doneOutput(str: left)
    case .leftOp(let left, _):
      doneOutput(str: left)
    case .leftOpRightPending(_, _, let right):
      pendingOutput(str: right)
    case .leftOpRightDone(_, _, let right):
      doneOutput(str: right)
    case .error:
      "Error!"
    }
  }

  private func pendingOutput(str: String) -> String {
    guard let number = Double(str) else { return "Error" }
    return NumberFormatter.localizedString(from: number as NSNumber, number: .decimal)
  }

  private func doneOutput(str: String) -> String {
    guard let number = Double(str) else { return "Error" }
    let formatted =
      (Constant.displayFormatter.string(from: number as NSNumber) ?? "0").trimmingFragmentZeros()
    return formatted
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
    case .leftPending(let left):
      .leftPending(left.takesIn(digit: digit))
    case .leftOp(let left, let op):
      .leftOpRightPending(left: left, op: op, right: "\(digit)")
    case .leftOpRightPending(let left, let op, let right):
      .leftOpRightPending(left: left, op: op, right: right.takesIn(digit: digit))
    case .leftDone, .leftOpRightDone, .error:
      .leftPending("\(digit)")
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
      applyOperator(operatr: .plus)
    case .minus:
      applyOperator(operatr: .minus)
    case .multiply:
      applyOperator(operatr: .multiply)
    case .divide:
      applyOperator(operatr: .divide)
    case .equal:
      applyOperator(operatr: .equal)
    }
  }

  private func applyDot() -> CalculatorState {
    switch self {
    case .leftPending(let left):
      .leftPending(left.takesInDot())
    case .leftOp(let left, let op):
      .leftOpRightPending(left: left, op: op, right: "0.")
    case .leftOpRightPending(let left, let op, let right):
      .leftOpRightPending(left: left, op: op, right: right.takesInDot())
    case .leftDone, .leftOpRightDone, .error:
      .leftPending("0.")
    }
  }

  // MARK: - Apply command

  private func applyClear() -> CalculatorState {
    .leftPending("0")
  }

  private func applyNegate() -> CalculatorState {
    switch self {
    case .leftPending(let left):
      .leftPending(negate(string: left))
    case .leftDone(let left):
      .leftDone(negate(string: left))
    case .leftOp(left: let left, op: let op):
      .leftOpRightPending(left: left, op: op, right: "-0")
    case .leftOpRightPending(left: let left, op: let op, right: let right):
      .leftOpRightDone(left: left, op: op, right: negate(string: right))
    case .leftOpRightDone, .error:
      .leftPending("-0")
    }
  }

  private func applyPercent() -> CalculatorState {
    switch self {
    case .leftPending(let left):
      .leftDone(percent(string: left))
    case .leftDone(let left):
      .leftDone(percent(string: left))
    case .leftOp(left: let left, op: let op):
      .leftOp(left: percent(string: left), op: op)
    case .leftOpRightPending(left: let left, op: let op, right: let right):
      .leftOpRightDone(left: left, op: op, right: percent(string: right))
    case .leftOpRightDone, .error:
        .leftPending("0")
    }
  }

  // MARK: - Apply operator

  private func applyOperator(operatr: Operator) -> CalculatorState {
    switch self {
    case .leftPending(let left):
      return operatr == .equal ? .leftDone(left) : .leftOp(left: left, op: operatr)
    case .leftDone(let left):
      return operatr == .equal ? .leftDone(left) : .leftOp(left: left, op: operatr)
    case .leftOp(let left, let op):
      guard operatr == .equal else { return .leftOp(left: left, op: operatr) }
      // [2 +] takes in `=`, this means [2 + 2 =]
      guard let left = Double(left) else { return .error }
      let result = calculate(left: left, op: op, right: left)
      return .leftDone("\(result)")
    case .leftOpRightPending(let left, let op, let right):
      // calculate as the input sequence, not as the arithmetic associative property
      guard let left = Double(left), let right = Double(right) else { return .error }
      // divided by zero
      guard !(right == 0 && op == .divide) else { return .error }
      let result = calculate(left: left, op: op, right: right)
      return operatr == .equal ? .leftDone("\(result)") : .leftOp(left: "\(result)", op: operatr)
    case .leftOpRightDone(left: let left, op: let op, right: let right):
      // calculate as the input sequence, not as the arithmetic associative property
      guard let left = Double(left), let right = Double(right) else { return .error }
      // divided by zero
      guard !(right == 0 && op == .divide) else { return .error }
      let result = calculate(left: left, op: op, right: right)
      return operatr == .equal ? .leftDone("\(result)") : .leftOp(left: "\(result)", op: operatr)
    case .error:
      return .leftOp(left: "0", op: operatr)
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
    case .leftPending(let left):
      left
    case .leftDone(let left):
      left
    case .leftOp(let left, _):
      left
    case .leftOpRightPending(let left, _, _):
      left
    case .leftOpRightDone(let left, _, _):
      left
    case .error:
      nil
    }
  }

  var right: String? {
    switch self {
    case .leftPending, .leftDone, .leftOp, .error:
      nil
    case .leftOpRightPending(_, _, let right):
      right
    case .leftOpRightDone(_, _, let right):
      right
    }
  }

  var op: String? {
    switch self {
    case .leftPending, .leftDone, .error:
      nil
    case .leftOp(_, op: let op):
      op.rawValue
    case .leftOpRightPending(_, op: let op, _):
      op.rawValue
    case .leftOpRightDone(_, op: let op, _):
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

extension CalculatorState: Equatable { }

extension String {
  fileprivate func takesIn(digit: Int) -> String {
    if digit == 0 && (self == "0" || self == "-0") {
      self
    } else if self == "0" {
      "\(digit)"
    } else if self == "-0" {
      "-\(digit)"
    } else {
      self + "\(digit)"
    }
  }

  fileprivate func takesInDot() -> String {
    self.contains(".") ? self : (self + ".")
  }

  fileprivate func trimmingFragmentZeros() -> String {
    var result = self
    if result.contains(".") {
      result = result.trimmingCharacters(in: CharacterSet(arrayLiteral: "0"))
    }
    if result.hasSuffix(".") {
      result = String(result.dropLast())
    }
    if result == "" {
      result = "0"
    }
    if result.starts(with: ".") {
      result = "0" + result
    }
    return result
  }
}
