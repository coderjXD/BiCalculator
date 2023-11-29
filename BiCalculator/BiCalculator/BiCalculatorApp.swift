//
//  BiCalculatorApp.swift
//  BiCalculator
//
//  Created by jay on 2023/11/25.
//

import SwiftUI

@main
struct BiCalculatorApp: App {
  var body: some Scene {
    WindowGroup {
      BiCalculatorView()
        .environmentObject(BiCalculatorViewModel())
    }
  }
}
