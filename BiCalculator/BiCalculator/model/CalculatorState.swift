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
      left.pendingFormattedString
    case .leftDone(let left):
      left.finishedFormattedString
    case .leftOp(let left, _):
      left.finishedFormattedString
    case .leftOpRightPending(_, _, let right):
      right.pendingFormattedString
    case .leftOpRightDone(_, _, let right):
      right.finishedFormattedString
    case .error:
      "Error"
    }
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
    case .thirdInput(let number):
      applyThirdInput(number: number)
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
      applyNonEqualOperator(theOperator: .plus)
    case .minus:
      applyNonEqualOperator(theOperator: .minus)
    case .multiply:
      applyNonEqualOperator(theOperator: .multiply)
    case .divide:
      applyNonEqualOperator(theOperator: .divide)
    case .equal:
      applyEqual()
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

  private func applyThirdInput(number: String) -> CalculatorState {
    let state: CalculatorState =
    switch self {
    case .leftPending, .leftDone, .leftOpRightPending, .leftOpRightDone, .error:
        .leftDone(number)
    case .leftOp(let left, let op):
        .leftOpRightDone(left: left, op: op, right: number)
    }
    return state
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
        .leftOpRightPending(left: left, op: op, right: negate(string: right))
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

  private func applyEqual() -> CalculatorState {
    switch self {
    case .leftPending(let left):
      return .leftDone(left)
    case .leftDone(let left):
      return .leftDone(left)
    case .leftOp(let left, let op):
      // [2 +] takes in `=`, this means [2 + 2 =]
      // calculate as the input sequence, not as the arithmetic associative property
      guard let leftDecimal = Decimal(string: left) else { return .error }
      // divided by zero
      if isDividedByZero(number: leftDecimal, op: op) { return .error }
      let resultDecimal = calculate(left: leftDecimal, op: op, right: leftDecimal)
      return .leftDone(resultDecimal.description)
    case .leftOpRightPending(let left, let op, let right):
      guard let leftDecimal = Decimal(string: left), let rightDecimal = Decimal(string: right) else { return .error }
      // divided by zero
      if isDividedByZero(number: rightDecimal, op: op) { return .error }
      let resultDecimal = calculate(left: leftDecimal, op: op, right: rightDecimal)
      return .leftDone(resultDecimal.description)
    case .leftOpRightDone(left: let left, op: let op, right: let right):
      guard let leftDecimal = Decimal(string: left), let rightDecimal = Decimal(string: right) else { return .error }
      // divided by zero
      if isDividedByZero(number: rightDecimal, op: op) { return .error }
      let resultDecimal = calculate(left: leftDecimal, op: op, right: rightDecimal)
      return .leftDone(resultDecimal.description)
    case .error:
      return .leftPending("0")
    }
  }

  private func applyNonEqualOperator(theOperator: Operator) -> CalculatorState {
    switch self {
    case .leftPending(let left):
      return .leftOp(left: left, op: theOperator)
    case .leftDone(let left):
      return .leftOp(left: left, op: theOperator)
    case .leftOp(let left, _):
      return .leftOp(left: left, op: theOperator)
    case .leftOpRightPending(let left, let op, let right):
      guard let leftDecimal = Decimal(string: left), let rightDecimal = Decimal(string: right) else { return .error }
      // divided by zero
      if isDividedByZero(number: rightDecimal, op: op) { return .error }
      let resultDecimal = calculate(left: leftDecimal, op: op, right: rightDecimal)
      return .leftOp(left: resultDecimal.description, op: theOperator)
    case .leftOpRightDone(left: let left, op: let op, right: let right):
      // calculate as the input sequence, not as the arithmetic associative property
      guard let leftDecimal = Decimal(string: left), let rightDecimal = Decimal(string: right) else { return .error }
      if isDividedByZero(number: rightDecimal, op: op) { return .error }
      let resultDecimal = calculate(left: leftDecimal, op: op, right: rightDecimal)
      return .leftOp(left: resultDecimal.description, op: theOperator)
    case .error:
      return .leftOp(left: "0", op: theOperator)
    }
  }

  // MARK: - Helpers

  private func isDividedByZero(number: Decimal, op: Operator) -> Bool {
    return number == .zero && op == .divide
  }

  private func negate(string: String) -> String {
    guard let number = Decimal(string: string) else { return "Error" }
    return (number * Decimal(string: "-1")!).description
  }

  private func percent(string: String) -> String {
    guard let number = Decimal(string: string) else { return "Error" }
    return (number / 100).description
  }

  public func calculate(left: Decimal, op: Operator, right: Decimal) -> Decimal {
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
    case .equal:  // there is no such state that an `equal` is between two operands, so this would never be executed
      Decimal.zero
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
