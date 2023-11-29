//
//  BiCalculatorViewModel.swift
//  BiCalculator
//
//  Created by jay on 2023/11/28.
//

import SwiftUI

class BiCalculatorViewModel: ObservableObject {

  @Published var statePrimary = CalculatorState.leftPending("0")
  @Published var stateSecondary = CalculatorState.leftPending("0")

  @Published var recordPrimary = ""
  @Published var recordSecondary = ""

  private var historyPrimary = [CalculatorItem.digit(0)]
  private var historySecondary = [CalculatorItem.digit(0)]

  private var lastThirdInputIsFromPrimary: Bool = true

  let pads: [[CalculatorItem]] = [
    [.command(.clear), .command(.negate), .command(.percent), .op(.divide)],
    [.digit(7), .digit(8), .digit(9), .op(.multiply)],
    [.digit(4), .digit(5), .digit(6), .op(.minus)],
    [.digit(1), .digit(2), .digit(3), .op(.plus)],
    [.digit(0), .dot, .op(.equal)],
  ]

  func apply(item: CalculatorItem, isSecondary: Bool = false) {
    if isSecondary {
      stateSecondary = stateSecondary.apply(item: item)
      if case .command(let cmd) = item, cmd == .clear {
        historySecondary = [CalculatorItem.digit(0)]
        recordSecondary = ""
      } else {
        historySecondary.append(item)
        recordSecondary = records(from: historySecondary).last ?? ""
      }
    } else {
      statePrimary = statePrimary.apply(item: item)
      if case .command(let cmd) = item, cmd == .clear {
        historyPrimary = [CalculatorItem.digit(0)]
        recordPrimary = ""
      } else {
        historyPrimary.append(item)
        recordPrimary = records(from: historyPrimary).last ?? ""
      }
    }
  }

  func applyThirdInput(forSecondary: Bool) {
    let number = forSecondary ? statePrimary.output : stateSecondary.output
    // when with comma, parsing to double would fail
    let numberWithoutComma = number.replacingOccurrences(of: ",", with: "")
    let inputItem = CalculatorItem.thirdInput(numberWithoutComma)
    apply(item: inputItem, isSecondary: forSecondary)
    lastThirdInputIsFromPrimary = forSecondary
  }

  func withdrawThirdInput() {
    var history = lastThirdInputIsFromPrimary ? historySecondary : historyPrimary

    var state: CalculatorState = lastThirdInputIsFromPrimary ? stateSecondary : statePrimary
    if let lastItem = history.last, lastItem.isThirdInput {
      history.removeLast()
      state = history.reduce(CalculatorState.leftPending("0")) {
        partialResult, item in
        return partialResult.apply(item: item)
      }
    }

    if lastThirdInputIsFromPrimary {
      historySecondary = history
      stateSecondary = state
    } else {
      historyPrimary = history
      statePrimary = state
    }

    lastThirdInputIsFromPrimary.toggle()
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


