//
//  RoundedButton.swift
//  BiCalculator
//
//  Created by jay on 2023/11/27.
//

import SwiftUI

struct RoundedButton: View {

  @State private var fontSize: CGFloat = Constant.screenWidth > Constant.minorScreenWidth ? 32 : 50

  let title: String
  let backgroundColorName: String
  let size: CGSize
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
        .onRotate { orientation in
          fontSize = orientation.isPortrait ? 50 : 32
        }
    }
  }
}

#Preview {
  HStack {
    RoundedButton(
      title: "+",
      backgroundColorName: "background.operator",
      size: CGSize(width: 96, height: 80))
    {
      print("+")
    }

    RoundedButton(
      title: "+/-",
      backgroundColorName: "background.command",
      size: CGSize(width: 96, height: 80))
    {
      print("+/-")
    }

    RoundedButton(
      title: "DEL",
      backgroundColorName: "background.command",
      size: CGSize(width: 96, height: 80))
    {
      print("DEL")
    }
  }
}
