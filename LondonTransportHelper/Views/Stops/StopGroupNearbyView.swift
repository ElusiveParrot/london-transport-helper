import SwiftUI

/*
 Searching for nearby stop groups that contain individual stops using user's location
 */
struct StopGroupNearbyView: View {
    @ObservedObject var viewModel = StopGroupNearbyViewModel()
    
    var body: some View {
        VStack {
            if (viewModel.locationAvailable) {
                VStack {
                    MapView(lat: viewModel.locationManager.location!.coordinate.latitude, lon: viewModel.locationManager.location!.coordinate.longitude)
                        .frame(height: 200)
                    
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
                        InfoTextView(text: "No stops nearby found")
                    }
                }
            } else {
                // Tell the user why there there are no stops showns and to check the privacy policy in settings in case he is concerned about how his data is used
                InfoTextView(text: "We need location permission in order to show you the stops near you. Please enable location services for London Transport Helper in your device's settings. Please check our privacy policy in the settings if you have any concerns about how this data is used")
                InfoTextView(text: "If you think this is a mistake (or you enabled location services now), please click refresh button above")
            }
        }
        .navigationTitle("Nearby Stops")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem {
                Button {
                    viewModel.searchForStopGroupsNearby()
                } label: {
                    Image(systemName: "goforward")
                }
            }
        }
        .onAppear() {
            viewModel.locationManager.requestWhenInUseAuthorization()
            viewModel.searchForStopGroupsNearby()
        }
        .onDisappear() {
            // Used to make sure API refresh, fixes CG crash
            viewModel.resetData()
        }
    }
}

struct StopGroupNearbyView_Previews: PreviewProvider {
    static var previews: some View {
        StopGroupNearbyView()
    }
}
