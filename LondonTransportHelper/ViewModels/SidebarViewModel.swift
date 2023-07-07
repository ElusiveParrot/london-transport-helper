import SwiftUI

enum SidebarOption {
    case home
}

class SidebarViewModel: ObservableObject {
    @Published var option: SidebarOption = .home
}
