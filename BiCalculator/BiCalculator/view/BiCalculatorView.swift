//
//  BiCalculatorView.swift
//  BiCalculator
//
//  Created by jay on 2023/11/28.
//

import SwiftUI

struct BiCalculatorView: View {

  @State private var isPortrait = UIScreen.main.bounds.height > Constant.minorScreenWidth

  var body: some View {
    Group {
      if isPortrait {
        CalculatorView()
      }else {
        HStack {
          CalculatorView()
          VStack {
            rightButton
            leftButton
            Spacer()
            deleteButton
          }
          .padding(.bottom, 8)
          .padding(.top, 86)
          CalculatorView()
        }
      }
    }
    .onRotate { orientation in
      isPortrait = orientation.isPortrait
    }
  }

  private var rightButton: some View {
    button(title: "→", color: .green) {

    }
  }

  private var leftButton: some View {
    button(title: "←", color: .green) {

    }
  }

  private var deleteButton: some View {
    button(title: "DEL", color: .gray) {

    }
  }

  private func button(title: String, color: Color, action: @escaping () -> Void) -> some View {
    Button(action: action) {
      Text(title)
        .font(.system(size: 25))
        .foregroundStyle(Color.white)
        .frame(width: 60, height: 50)
        .background(color)
        .cornerRadius(10)
    }
  }
}

#Preview {
  BiCalculatorView()
}
