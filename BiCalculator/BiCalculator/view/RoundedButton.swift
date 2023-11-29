//
//  RoundedButton.swift
//  BiCalculator
//
//  Created by jay on 2023/11/27.
//

import SwiftUI

struct RoundedButton: View {

  let title: String
  let backgroundColorName: String
  let size: CGSize
  let fontSize: CGFloat
  let action: () -> Void

  let foregroundColorName: String = "text.light"

  var body: some View {
    Button(action: action) {
      Text(title)
        .font(.system(size: fontSize))
        .foregroundStyle(Color(foregroundColorName))
        .frame(width: size.width, height: size.height)
        .background(Color(backgroundColorName))
        .cornerRadius(10)
    }
  }
}

#Preview {
  HStack {
    RoundedButton(
      title: "+",
      backgroundColorName: "background.operator",
      size: CGSize(width: 96, height: 80),
      fontSize: 50)
    {
      print("+")
    }

    RoundedButton(
      title: "+/-",
      backgroundColorName: "background.command",
      size: CGSize(width: 96, height: 80),
      fontSize: 50)
    {
      print("+/-")
    }

    RoundedButton(
      title: "DEL",
      backgroundColorName: "background.command",
      size: CGSize(width: 96, height: 80),
      fontSize: 50)
    {
      print("DEL")
    }
  }
}
