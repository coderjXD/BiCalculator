//
//  StringExtensions.swift
//  BiCalculator
//
//  Created by jay on 2023/11/29.
//

import Foundation

// MARK: - formatting

extension String {
  var pendingFormattedString: String {
    if self == "" { return "" }
    guard let number = Constant.displayFormatter.number(from: self) else {
      return "Error"
    }
    let components = self.components(separatedBy: ".")
    let formattedFragment = components.count > 1 ? components[1] : ""
    let formattedInt = Constant.displayFormatter.string(from: number.doubleValue.rounded(.towardZero) as NSNumber) ?? "0"

    return self.contains(".") ? (formattedInt + "." + formattedFragment) : formattedInt
  }

  var finishedFormattedString: String {
    if self == "" { return "" }
    guard let number = Constant.displayFormatter.number(from: self) else {
      return "Error"
    }
    let formatted =
      (Constant.displayFormatter.string(from: number) ?? "0").trimmingFragmentZeros()
    return formatted
  }
}

// MARK: - takes in contents

extension String {
  func takesIn(digit: Int) -> String {
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

  func takesInDot() -> String {
    self.contains(".") ? self : (self + ".")
  }

  func trimmingFragmentZeros() -> String {
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
