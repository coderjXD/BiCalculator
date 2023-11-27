//
//  ButtonItem.swift
//  BiCalculator
//
//  Created by jay on 2023/11/27.
//

import Foundation

enum ButtonItem {

  enum Command: String {
    case clear = "AC"
    case negate = "+/-"
    case percent = "%"
  }

  enum Operator: String {
    case plus = "+"
    case minus = "-"
    case multiply = "x"
    case divide = "÷"
    case equal = "="
  }

  case command(Command)
  case digit(Int)
  case op(Operator)
  case dot

  var isZero: Bool {
    if case let .digit(number) = self, number == 0 {
      true
    }else {
      false
    }
  }
}

// MARK: - convenience methods

extension ButtonItem {
  var title: String {
    switch self {
    case .command(let command):
      command.rawValue
    case .digit(let number):
      "\(number)"
    case .op(let op):
      op.rawValue
    case .dot:
      "."
    }
  }

  var backgroundColorName: String {
    switch self {
    case .command:
      "background.command"
    case .digit, .dot:
      "background.digit"
    case .op:
      "background.operator"
    }
  }
}

// MARK: - Hashable

extension ButtonItem: Hashable { }
