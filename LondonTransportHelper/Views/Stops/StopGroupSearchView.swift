import SwiftUI

/*
 Searching for stop groups that contain individual stops
 */
struct StopGroupSearchView: View {
    @ObservedObject var viewModel = StopGroupSearchViewModel()
    
    @State private var searchText = ""
    
#if DEBUG
    // Used by Preview below so entries can be seen without typing query in
    var withDataForPreview: some View {
        self.viewModel.searchForStopGroups(query: "Hounslow")
        
        return self
    }
#endif
    
    var body: some View {
        VStack {
            CustomTextFieldView(text: $searchText, imageName: "magnifyingglass", backgroundText: "Search") {
                viewModel.searchForStopGroups(query: searchText)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(20)
            .padding(5)
            
            Divider()
            Spacer()
            
            if (!viewModel.stops.isEmpty) {
                ScrollView {
                    ForEach(viewModel.stops, id: \.self) { stop in
                        StopGroupBannerView(stop: stop)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 20)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(20)
                            .padding(5)
                    }
                }
            } else {
                InfoTextView(text: "Enter the stop name that you want to search for above")
            }
            
            Spacer()
        }
        .navigationTitle("Stop Search")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct StopGroupSearchView_Previews: PreviewProvider {
    static var previews: some View {
        StopGroupSearchView().withDataForPreview
    }
}
