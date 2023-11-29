//
//  BiCalculatorViewModel.swift
//  BiCalculator
//
//  Created by jay on 2023/11/28.
//

import SwiftUI

class BiCalculatorViewModel: ObservableObject {

  @Published var state = CalculatorState.leftPending("0")
  @Published var stateSecond = CalculatorState.leftPending("0")
  @Published var isPortrait = true

  @Published var record = ""
  @Published var recordSecondary = ""

  private var historyFirst = [CalculatorItem.digit(0)]
  private var historySecond = [CalculatorItem.digit(0)]


  let pads: [[CalculatorItem]] = [
    [.command(.clear), .command(.negate), .command(.percent), .op(.divide)],
    [.digit(7), .digit(8), .digit(9), .op(.multiply)],
    [.digit(4), .digit(5), .digit(6), .op(.minus)],
    [.digit(1), .digit(2), .digit(3), .op(.plus)],
    [.digit(0), .dot, .op(.equal)],
  ]

  func apply(item: CalculatorItem, isSecondary: Bool = false) {
    if isSecondary {
      stateSecond = stateSecond.apply(item: item)
      if case .command(let cmd) = item, cmd == .clear {
        historySecond = [CalculatorItem.digit(0)]
        recordSecondary = ""
      }else {
        historySecond.append(item)
        recordSecondary = records(from: historySecond).last ?? ""
      }
    }else {
      state = state.apply(item: item)
      if case .command(let cmd) = item, cmd == .clear {
        historyFirst = [CalculatorItem.digit(0)]
        record = ""
      }else {
        historyFirst.append(item)
        record = records(from: historyFirst).last ?? ""
      }
    }
  }

  private func records(from history: [CalculatorItem]) -> [String] {
    var result = [String]()
    var prevState = CalculatorState.leftPending("0")
    for (index, item) in history.dropFirst().enumerated() {
      let isLast = index == history.dropFirst().count - 1
      let currentState = prevState.apply(item: item)
      if
        case .op = item,
        case .leftOpRightPending(left: let left, op: let op, right: let right) = prevState
      {
        if let currentLeft = currentState.left {
          let statement = left.finishedFormattedString + op.rawValue + right.finishedFormattedString + "=" + currentLeft.finishedFormattedString
          result.append(statement)
        }
      } else if
        case .op = item,
        case .leftOpRightDone(left: let left, op: let op, right: let right) = prevState
      {
        if let currentLeft = currentState.left {
          let statement = left.finishedFormattedString + op.rawValue + right.finishedFormattedString + "=" + currentLeft.finishedFormattedString
          result.append(statement)
        }
      } else if
        case .op(let itemOp) = item,
        itemOp == .equal,
        case .leftOp(left: let left, op: let op) = prevState
      {
        if let currentLeft = currentState.left {
          let statement = left.finishedFormattedString + op.rawValue + left.finishedFormattedString + "=" + currentLeft.finishedFormattedString
          result.append(statement)
        }
      } else {
        if isLast {
          let statement = (currentState.left ?? "").finishedFormattedString + (currentState.op ?? "") + (currentState.right ?? "").finishedFormattedString
          result.append(statement)
        }
      }
      prevState = currentState
    }
    return result
  }
}


