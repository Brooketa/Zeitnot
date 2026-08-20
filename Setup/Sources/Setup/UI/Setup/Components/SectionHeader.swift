import SwiftUI
import CoreUI

struct SectionHeader: View {

    let title: LocalizedStringResource

    var body: some View {
        Text(title)
            .label()
            .textCase(.uppercase)
    }

}
