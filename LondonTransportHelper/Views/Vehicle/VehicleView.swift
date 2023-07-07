import SwiftUI

/*
 Shows every stop that the specific vehicle is going to arrive at and when
 */
struct VehicleView: View {
    @ObservedObject var viewModel: VehicleViewModel
    
    // User to automatically refresh the arrivals every 60 seconds
    @ObservedObject var timer: TimerHelper
    
    init(vechicleId: String) {
        self.viewModel = VehicleViewModel(vehicleId: vechicleId)
        self.timer = TimerHelper(limit: 60) {
            // Empty, add actual function in .onAppear
        }
    }
    
    // Get line name based on the first prediction's line (due to filtering that is used this is 100% reliable in my testing)
    var lineName: String? {
        return viewModel.predictions.isEmpty ? nil : viewModel.predictions[0].lineName
    }
    
    var body: some View {
        VStack {
            if (!viewModel.predictions.isEmpty) {
                List {
                    Section(header: LineRectangleView(color: .secondary, name: viewModel.vehicleId)) {
                        ForEach(viewModel.predictions.sorted(by: <), id: \.self) { prediction in
                            VehicleStopEntryView(prediction: prediction)
                        }
                    }
                }
            } else {
                InfoTextView(text: "There are no arrivals for this vehicle")
            }
        }
        .listStyle(GroupedListStyle())
        .navigationTitle("Vehicle Location")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // Auto refresh timer
            ToolbarItem {
                Text("\(60 - timer.counter)")
                    .fixedSize()
            }
            
            // Refresh Button
            ToolbarItem {
                Button {
                    viewModel.getArrivalPredictions()
                    timer.reset()
                } label: {
                    Image(systemName: "goforward")
                }
            }
        }
        .onAppear() {
            viewModel.getArrivalPredictions()
            
            // Change timer action to refresh arrivals every 60 seconds
            timer.changeOnLimitAction() {
                viewModel.getArrivalPredictions()
            }
        }
        .onDisappear() {
            // Used to make sure API refresh, fixes CG crash
            viewModel.resetData()
            
            timer.reset()
        }
    }
}

struct VehicleView_Previews: PreviewProvider {
    static var previews: some View {
        VehicleView(vechicleId: "SN12AUF")
    }
}
