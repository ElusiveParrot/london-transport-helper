import SwiftUI

/*
 Landing page of the application from which the user navigates to features
 */
struct HomeView: View {
    @State private var settingsMenuShown = false
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section(header: Text("Journey")) {
                        HomeFunctionLinkView(destination: JourneyPlannerView(), text: "Journey Planner", iconSystemName: "map")
                        
                        HomeFunctionLinkView(destination: DisruptionsView(), text: "Disruptions", iconSystemName: "xmark")
                    }
                    
                    Section(header: Text("Stops")) {
                        HomeFunctionLinkView(destination: StopGroupFavouritesView(), text: "Favourites", iconSystemName: "star")
                        HomeFunctionLinkView(destination: StopGroupNearbyView(), text: "Nearby", iconSystemName: "location")
                        HomeFunctionLinkView(destination: StopGroupSearchView(), text: "Search", iconSystemName: "magnifyingglass")
                    }
                    
                    // Miscellanious functions, most of them just open a relevant web page
                    Section(header: Text("Other")) {
                        HomeFunctionLinkView(destination: SafariView(url: URL(string: "https://tfl.gov.uk/help-and-contact/contact-us-about-bus-staff#on-this-page-4")!).navigationTitle("Complaint Form").navigationBarTitleDisplayMode(.inline), text: "TFL Staff Feedback Form", iconSystemName: "pencil.tip")
                        
                        HomeFunctionLinkView(destination: SafariView(url: URL(string: "https://www.nationalrail.co.uk/")!).navigationTitle("Timetables").navigationBarTitleDisplayMode(.inline), text: "National Rail Timetables", iconSystemName: "train.side.front.car")
                        
                        HomeFunctionLinkView(destination: SafariView(url: URL(string: "https://content.tfl.gov.uk/standard-tube-map.pdf")!).navigationTitle("Tube Map").navigationBarTitleDisplayMode(.inline), text: "Tube Map", iconSystemName: "map")
                    }
                }
                .listStyle(GroupedListStyle())
            }
            .navigationTitle("Welcome")
            .toolbar {
                ToolbarItem {
                    Button {
                        settingsMenuShown = true
                    } label: {
                        Label("Settings", systemImage: "gearshape")
                    }
                }
            }
        }
        .sheet(isPresented: $settingsMenuShown)
        {
            SettingsView() {
                settingsMenuShown = false
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
