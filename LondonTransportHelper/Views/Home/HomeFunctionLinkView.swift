import SwiftUI

/*
 Links in home list that link to individual app features
 */
struct HomeFunctionLinkView<Destination>: View where Destination: View {
    // Destination for navigation link
    var destination: Destination
    
    var text: String
    
    // Apple's SF Icon name
    var iconSystemName: String
    
    var body: some View {
        NavigationLink(destination: destination) {
            Label(text, systemImage: iconSystemName)
        }
    }
}

struct HomeFunctionLinkView_Previews: PreviewProvider {
    static var previews: some View {
        HomeFunctionLinkView(destination: EmptyView(), text: "Search", iconSystemName: "magnifyingglass")
            .previewLayout(PreviewLayout.sizeThatFits)
            .padding()
    }
}
