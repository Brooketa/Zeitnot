import SwiftUI
import CoreUI

struct SectionHeader: View {

    let title: String

    var body: some View {
        Text(title)
            .label()
            .textCase(.uppercase)
    }

}
