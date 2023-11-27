//
//  RoundedButton.swift
//  BiCalculator
//
//  Created by jay on 2023/11/27.
//

import SwiftUI

let scaleRatio = min(UIScreen.main.bounds.width, UIScreen.main.bounds.width) / 414

struct RoundedButton: View {
  
  let title: String
  // default width/height ration is 1.2
  let size: CGSize = CGSize(width: 96, height: 80)
  let fontSize: CGFloat = 46
  let backgroundColor: Color = Color.backgroundDigit
  let backgroundColorPressed: Color = Color.backgroundDigitPressed
  let foregroundColor: Color = Color.textLight
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Text(title)
        .font(.system(size: fontSize * scaleRatio))
        .foregroundStyle(foregroundColor)
        .frame(width: size.width, height: size.height)
        .scaleEffect(scaleRatio)
    }
    .pressedStyle(
      normalColor: backgroundColor,
      pressedColor: backgroundColorPressed,
      cornerRadius: 10
    )
  }
}

#Preview {
  HStack {
    RoundedButton(title: "+") {
      print("+")
    }

    RoundedButton(title: "+/-") {
      print("+/-")
    }

    RoundedButton(title: "DEL") {
      print("DEL")
    }
  }
}
