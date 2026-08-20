import SwiftUI
import CoreUI

struct StartGameBar: View {

    let rulesetName: String
    let action: (Action) -> Void

    var body: some View {
        Button {
            action(.start)
        } label: {
            content
        }
        .buttonStyle(.plain)
        .padding(.horizontal, .lg)
        .padding(.vertical, .xs)
        .frame(maxWidth: .infinity)
        .background {
            scrim
        }
    }

	var scrim: some View {
		LinearGradient(
			colors: [.clear, ColorPalette.background],
			startPoint: .top,
			endPoint: .bottom)
			.ignoresSafeArea(edges: .bottom)
	}

	var content: some View {
		HStack(spacing: .lg) {
			label

			Spacer(minLength: 0)

			arrow
		}
		.padding(.horizontal, .xl)
		.padding(.vertical, .md)
		.frame(maxWidth: .infinity)
		.background(ColorPalette.accent)
		.clipShape(.capsule)
		.contentShape(.rect)
	}

	var label: some View {
		VStack(alignment: .leading, spacing: .xs) {
			Text(Constants.title)
				.buttonLabel()
				.textCase(.uppercase)

			Text(rulesetName)
				.footnote(ColorPalette.inkInverse)
		}
	}

	var arrow: some View {
		Image(systemName: Constants.arrowSymbol)
			.font(.system(size: Constants.arrowSize, weight: .bold))
			.foregroundStyle(ColorPalette.inkInverse)
			.frame(width: Constants.arrowDiameter, height: Constants.arrowDiameter)
			.background(Circle().fill(ColorPalette.accentRaised))
	}

}

extension StartGameBar {

    enum Action {

        case start

    }

}

private extension StartGameBar {

    enum Constants {

        static var title: String { "Start Game" }
        static var arrowSymbol: String { "arrow.right" }

        static let arrowSize: CGFloat = 14
        static let arrowDiameter: CGFloat = 36

    }

}
