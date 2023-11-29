//
//  BiCalculatorView.swift
//  BiCalculator
//
//  Created by jay on 2023/11/28.
//

import SwiftUI

struct BiCalculatorView: View {

  @EnvironmentObject var viewModel: BiCalculatorViewModel

  var body: some View {
    Group {
      if viewModel.isPortrait {
        CalculatorView(isSecondary: false)
      } else {
        HStack {
          CalculatorView(isSecondary: false)
          VStack {
            rightButton
            leftButton
            Spacer()
            deleteButton
          }
          .padding(.bottom, 8)
          .padding(.top, 86)
          CalculatorView(isSecondary: true)
        }
      }
    }
    .onRotate { orientation in
      viewModel.isPortrait = orientation.isPortrait
    }
    .onAppear {
      viewModel.isPortrait = UIScreen.main.bounds.height > Constant.minorScreenWidth
    }
  }

  private var rightButton: some View {
    button(title: "→", color: .green) {
      viewModel.applyThirdInput(forSecondary: true)
    }
  }

  private var leftButton: some View {
    button(title: "←", color: .green) {
      viewModel.applyThirdInput(forSecondary: false)
    }
  }

  private var deleteButton: some View {
    button(title: "DEL", color: .gray) {
      viewModel.withdrawThirdInput()
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
