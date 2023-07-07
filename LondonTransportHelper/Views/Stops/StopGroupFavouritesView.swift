import SwiftUI

/*
 Shows stop groups are favourited by the user
 */
struct StopGroupFavouritesView: View {
    // Use app's settings to decide on the sorting
    @AppStorage(AppSetting.favouritesSorting.rawValue) private var favouritesSorting = AppSettingFavouritesSorting.name
    
    /*
     Injected persistent storage context.
     
     Fetch request is made to get the favourite stops.
     */
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(sortDescriptors: []) var favouriteStops: FetchedResults<FavouriteStop>
    
    var favourites: [FavouriteStop] {
        switch (favouritesSorting) {
        case .name:
            return favouriteStops.sorted(by: { first, second in
                first.name < second.name
            })
            
        case .date:
            return favouriteStops.sorted(by: { first, second in
                first.dateAdded > second.dateAdded
            })
        }
    }
    
    var body: some View {
        ZStack {
            if (!favouriteStops.isEmpty) {
                ScrollView {
                    ForEach(favourites, id: \.self) { favourite in
                        StopGroupBannerView(stop: favourite.stopGroup)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 20)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(20)
                            .padding(5)
                    }
                }
            } else {
                InfoTextView(text: "You have not added any stops to favourites yet")
            }
        }
        .navigationTitle("Favourites")
        .navigationBarTitleDisplayMode(.inline)
    }
}


struct StopGroupFavouritesView_Previews: PreviewProvider {
    static var previews: some View {
        StopGroupFavouritesView()
    }
}

