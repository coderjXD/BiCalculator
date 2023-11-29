//
//  RoundedButton.swift
//  BiCalculator
//
//  Created by jay on 2023/11/27.
//

import SwiftUI

struct RoundedButton: View {

  @EnvironmentObject var viewModel: BiCalculatorViewModel

  let title: String
  let backgroundColorName: String
  let size: CGSize
  let action: () -> Void

  let foregroundColorName: String = "text.light"

  var body: some View {
    Button(action: action) {
      Text(title)
        .font(.system(size: viewModel.isPortrait ? 50 : 32))
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
