//
//  CalculatorView.swift
//  BiCalculator
//
//  Created by jay on 2023/11/27.
//

import SwiftUI

struct CalculatorView: View {

  let isSecondary: Bool
  @EnvironmentObject var viewModel: BiCalculatorViewModel

  var state: CalculatorState {
    isSecondary ? viewModel.stateSecond : viewModel.state
  }

  var body: some View {
    GeometryReader { geometry in
      let size = geometry.size
      VStack(spacing: 0) {
        Spacer()
        display(offeredSize: size)
        record(offeredSize: size)
        pads(offeredSize: size)
      }
      .padding([.bottom, .horizontal], Constants.Scale.buttonPadding)
    }
  }

  @ViewBuilder
  private func display(offeredSize: CGSize) -> some View {
    let fontSize = Constants.displayFont(isPortrait: viewModel.isPortrait)
    let height = Constants.displayHeight(isPortrait: viewModel.isPortrait)
    HStack {
      Spacer()
      Text(state.output)
        .font(.system(size: fontSize))
        .frame(height: height)
    }
  }

  @ViewBuilder
  private func record(offeredSize: CGSize) -> some View {
    let fontSize = Constants.recordFont(isPortrait: viewModel.isPortrait)
    let height = Constants.recordHeight(isPortrait: viewModel.isPortrait)
    HStack(alignment: .bottom) {
      Text("89x15=1335")
        .font(.system(size: fontSize))
        .frame(height: height)
      Spacer()
    }
  }

  @ViewBuilder
  private func pads(offeredSize: CGSize) -> some View {
    VStack(alignment: .leading, spacing: Constants.Scale.buttonPadding) {
      ForEach(viewModel.pads, id: \.self) { items in
        row(for: items, offeredSize: offeredSize)
      }
    }
    .padding(.top, Constants.Scale.buttonPadding)
  }

  @ViewBuilder
  private func row(for items: [CalculatorItem], offeredSize: CGSize) -> some View {
    HStack(spacing: Constants.Scale.buttonPadding) {
      ForEach(items, id: \.self) { item in
        let itemSize = Constants.itemSize(offeredTotal: offeredSize, isZero: item.isZero)
        RoundedButton(
          title: item.title,
          backgroundColorName: item.backgroundColorName,
          size: itemSize)
        {
          viewModel.apply(item: item, isSecondary: isSecondary)
        }
      }
    }
  }
}

extension CalculatorView {
  struct Constants {
    struct Font {
      static let portraitDisplay: CGFloat = 50
      static let landscapeDisplay: CGFloat = 35

      static let portraitRecord: CGFloat = 40
      static let landscapeRecord: CGFloat = 25
    }

    struct Scale {
      static let portraitDisplayHeight: CGFloat = 60
      static let landscapeDisplayHeight: CGFloat = 40

      static let portraitRecordHeight: CGFloat = 45
      static let landscapeRecordHeight: CGFloat = 30

      static let buttonPadding: CGFloat = 8
      static let maxButtonHeight: CGFloat = 80
    }

    struct Quantity {
      static let buttonRow = 5
      static let buttonColumn = 4
    }

    static func displayHeight(isPortrait: Bool) -> CGFloat {
      isPortrait ? Scale.portraitDisplayHeight : Scale.landscapeDisplayHeight
    }

    static func recordHeight(isPortrait: Bool) -> CGFloat {
      isPortrait ? Scale.portraitRecordHeight : Scale.landscapeRecordHeight
    }

    static func displayFont(isPortrait: Bool) -> CGFloat {
      isPortrait ? Font.portraitDisplay : Font.landscapeDisplay
    }

    static func recordFont(isPortrait: Bool) -> CGFloat {
      isPortrait ? Font.portraitRecord : Font.landscapeRecord
    }

    // `AC` top left  ->  `=` bottom right, size of this area, no outer padding included
    static func padSize(offeredTotal: CGSize) -> CGSize {
      let isPortrait = offeredTotal.height > Constant.minorScreenWidth
      let displayHeight = Constants.displayHeight(isPortrait: isPortrait)
      let recordHeight = Constants.recordHeight(isPortrait: isPortrait)

      // offeredSize includes top padding + display + record + gap(padding) + pads + bottom padding
      let nonPadHeight = displayHeight + recordHeight + Constants.Scale.buttonPadding * 3
      let nonPadWidth = Constants.Scale.buttonPadding * 2
      let padSize = CGSize(width: offeredTotal.width - nonPadWidth, height: offeredTotal.height - nonPadHeight)
      return padSize
    }

    static func itemSize(offeredTotal: CGSize, isZero: Bool) -> CGSize {

      let padSize = padSize(offeredTotal: offeredTotal)
      // 3 inner gaps
      let gapCountH = Quantity.buttonColumn - 1
      let allGapH = Scale.buttonPadding * CGFloat(gapCountH)
      let itemWidth = (padSize.width - allGapH) / CGFloat(Quantity.buttonColumn)
      // 4 inner gaps
      let gapCountV = Quantity.buttonRow - 1
      let allGapV = Scale.buttonPadding * CGFloat(gapCountV)
      let itemHeight = (padSize.height - allGapV) / CGFloat(Quantity.buttonRow)

      let spanWidth = itemWidth * 2 + Scale.buttonPadding
      return CGSize(width: isZero ? spanWidth : itemWidth, height: min(itemHeight, Scale.maxButtonHeight))
    }
  }
}

#Preview("Portrait", traits: .portrait) {
  HStack {
    CalculatorView(isSecondary: false)
  }
}

#Preview("Landscape", traits: .landscapeLeft) {
  HStack {
    CalculatorView(isSecondary: false)
    CalculatorView(isSecondary: true)
  }
}
