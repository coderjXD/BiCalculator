//
//  StringExtensions.swift
//  BiCalculator
//
//  Created by jay on 2023/11/29.
//

import Foundation

// MARK: - formatting

extension String {
  /// use String to avoid precision lost
  var pendingFormattedString: String {
    if self == "" { return "" }
    // fragment
    if self.contains(".") {
      let components = self.components(separatedBy: ".")
      let fullPart = components[0] == "" ? "0" : components[0]
      let fragmentPart = components[1]
      return fullPart.addingGroupSymbol + "." + fragmentPart
    }
    // Full number
    else {
      return self.addingGroupSymbol
    }
  }

  var finishedFormattedString: String {
    if self == "" { return "" }
    return pendingFormattedString.trimmingFragmentZeros()
  }

  private var addingGroupSymbol: String {
    let reversed = String(self.reversed())
    var result = ""
    for (index, ch) in reversed.enumerated() {
      result.append(ch)
      if index % 3 == 2 && index != reversed.count - 1 {
        result.append(",")
      }
    }

    return String(result.reversed())
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
