import SwiftUI
import CoreUI

struct StartGameBar: View {

    let model: Model
    let action: (Action) -> Void

    var body: some View {
        Button {
            action(.start)
        } label: {
            content
        }
        .buttonStyle(.plain)
        .padding(.horizontal, .large)
        .padding(.vertical, .extraSmall)
        .maxWidth()
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
		HStack(spacing: .large) {
			label
				.alignLeading()

			arrow
		}
		.padding(.horizontal, .extraLarge)
		.padding(.vertical, .medium)
		.maxWidth()
		.background(ColorPalette.accent)
		.clipShape(.capsule)
		.contentShape(.rect)
	}

	var label: some View {
		VStack(alignment: .leading, spacing: .extraSmall) {
			Text(.startGame)
				.buttonLabel()
				.textCase(.uppercase)

			Text(.selectedRuleset(model.category, model.baseMinutes, model.incrementSeconds))
				.footnote(ColorPalette.inkInverse)
		}
	}

	var arrow: some View {
		Image.forward
			.font(.system(size: Constants.arrowSize, weight: .bold))
			.foregroundStyle(ColorPalette.inkInverse)
			.frame(width: Constants.arrowDiameter, height: Constants.arrowDiameter)
			.background(Circle().fill(ColorPalette.accentRaised))
	}

}

extension StartGameBar {

    struct Model {

        let category: String
        let baseMinutes: Int
        let incrementSeconds: Int

    }

}

extension StartGameBar {

    enum Action {

        case start

    }

}

private extension StartGameBar {

    enum Constants {

        static let arrowSize: CGFloat = 14
        static let arrowDiameter: CGFloat = 36

    }

}
