import SwiftUI

/*
 Shows individual stops in a stop group which can be accessed
 */
struct StopGroupStopsView: View {
    /*
     Inject persistent storage object.
     
     Also fetch favourite stops so that new ones can be added/deleted
     */
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(sortDescriptors: []) var favouriteStops: FetchedResults<FavouriteStop>
    
    @ObservedObject var viewModel: StopGroupViewModel
    
    // Find if this stop already exists in favourites
    var isFavourite: Bool {
        for stop in favouriteStops {
            if (stop.stopGroup == viewModel.stopGroup) {
                return true
            }
        }
        
        return false
    }
    
    var stopGroup: StopPointGroup
    
    init(stop: StopPointGroup) {
        self.stopGroup = stop
        self.viewModel = StopGroupViewModel(stopGroup: self.stopGroup)
    }
    
    var body: some View {
        VStack {
            // Focus the map on the stop group location
            MapView(lat: viewModel.stopGroup.lat, lon: viewModel.stopGroup.lon)
                .frame(height: 200)
            List {
                Section(header: Text("Buses")) {
                    ForEach(viewModel.stopList.bus, id: \.self) { stop in
                        IndividualStopBannerView(stop: stop, transportMode: .bus)
                    }
                }
                Section(header: Text("Other")) {
                    ForEach(viewModel.stopList.tube, id: \.self) { stop in
                        IndividualStopBannerView(stop: stop, transportMode: .tube)
                    }
                    ForEach(viewModel.stopList.dlr, id: \.self) { stop in
                        IndividualStopBannerView(stop: stop, transportMode: .dlr)
                    }
                    ForEach(viewModel.stopList.elizabethLine, id: \.self) { stop in
                        IndividualStopBannerView(stop: stop, transportMode: .elizabethLine)
                    }
                    ForEach(viewModel.stopList.overground, id: \.self) { stop in
                        IndividualStopBannerView(stop: stop, transportMode: .overground)
                    }
                }
            }
        }
        .listStyle(GroupedListStyle())
        .navigationTitle(viewModel.stopGroup.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem {
                Button {
                    if (!isFavourite) {
                        // Add the stop to favourites
                        do {
                            let favourite = FavouriteStop(context: managedObjectContext)
                            favourite.stopGroup = stopGroup
                            
                            // Add the date as well so that it can be used for sorting
                            favourite.dateAdded = Date.now
                            
                            try managedObjectContext.save()
                        } catch {
#if DEBUG
                            print("Unable to save stop to favourites")
#endif
                        }
                    }
                    else {
                        // Remove from favourites
                        for stop in favouriteStops {
                            if (stop.stopGroup == viewModel.stopGroup) {
                                managedObjectContext.delete(stop)
                            }
                        }
                    }
                } label: {
                    // Make the star icon filled if it's in favourites and empty if it's not
                    Label("Favourite", systemImage: "star" + (isFavourite ? ".fill" : ""))
                        .foregroundColor(.yellow)
                }
            }
        }
        .onAppear() {
            viewModel.searchForStops()
        }
        .onDisappear() {
            // Used to make sure API refresh, fixes CG crash
            viewModel.resetData()
        }
    }
}

struct StopGroupStopsView_Previews: PreviewProvider {
    static var previews: some View {
        StopGroupStopsView(stop: StopPointGroup(id: "490G00003791", name: "Hounslow Bus Station", lat: 51.5074, lon: 0.1272, modes: [.bus, .elizabethLine, .nationalRail, .overground, .tube]))
    }
}
