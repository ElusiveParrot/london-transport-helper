import SwiftUI

/*
 Shows how long is the wait for each line
 */
struct ArrivalsView: View {
    @ObservedObject var viewModel: ArrivalsViewModel
    
    // Used to refresh the arrivals once every 60 seconds automatically
    @ObservedObject var timer: TimerHelper
    
    // Used to filter arrivals, by default it will be TFLHelper filter based on transport mode
    var arrivalsFilter: (Arrival) -> Bool
    
    /*
     Returns a header for a given line, with it's matching colour
     */
    private func getLineHeader(name: String) -> some View {
        return LineRectangleView(color: TFLHelper.getColourNameForLine(name: name), name: name)
    }
    
    init(stopIdOrNaptan: String, arrivalsFilter: @escaping (Arrival) -> Bool) {
        self.arrivalsFilter = arrivalsFilter
        self.viewModel      = ArrivalsViewModel(stopIdOrNaptan: stopIdOrNaptan)
        self.timer          = TimerHelper(limit: 60) {
            // Empty, add actual action in .onAppear
        }
    }
    
    var body: some View {
        VStack {
            if (!viewModel.arrivals.isEmpty) {
                List {
                    ForEach(Array(viewModel.arrivals.keys.sorted(by: <)), id: \.self) { key in
                        Section(header: getLineHeader(name: key)) {
                            ForEach(viewModel.arrivals[key]!.sorted(by: <), id: \.self) { arrival in
                                ArrivalEntryView(arrival: arrival)
                            }
                        }
                    }
                }
            } else {
                InfoTextView(text: "There are no arrivals for this stop. Try refreshing.")
            }
        }
        .listStyle(GroupedListStyle())
        .navigationTitle("Arrivals")
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
                    viewModel.getArrivals(filter: arrivalsFilter)
                    timer.reset()
                } label: {
                    Image(systemName: "goforward")
                }
            }
        }
        .onAppear() {
            viewModel.getArrivals(filter: arrivalsFilter)
            
            // Change timer's action to refresh arrivals every 60 seconds
            timer.changeOnLimitAction() {
                viewModel.getArrivals(filter: arrivalsFilter)
            }
        }
        .onDisappear() {
            // Used to make sure API refresh, fixes CG crash
            viewModel.resetData()
            timer.reset()
        }
    }
}

struct ArrivalsView_Previews: PreviewProvider {
    static var previews: some View {
        ArrivalsView(stopIdOrNaptan: "490003788E") { _ in
            // Don't filter anything for preview
            return true
        }
    }
}
