//
//  PressedButtonStyle.swift
//  BiCalculator
//
//  Created by jay on 2023/11/27.
//

import SwiftUI

struct PressedButtonStyle: ButtonStyle {
  let normalColor: Color
  let pressedColor: Color
  let cornerRadius: CGFloat
  func makeBody(configuration: Configuration) -> some View {
    configuration
      .label
      .background(configuration.isPressed ? pressedColor : normalColor)
      .cornerRadius(cornerRadius)
  }
}

extension Button {
  func pressedStyle(normalColor: Color, pressedColor: Color, cornerRadius: CGFloat = 10) -> some View {
    self.buttonStyle(
      PressedButtonStyle(normalColor: normalColor, pressedColor: pressedColor, cornerRadius: cornerRadius)
    )
  }
}
