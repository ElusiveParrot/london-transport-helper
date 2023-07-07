import SwiftUI

/*
 Shows all the current disruptons to the service
 */
struct DisruptionsView: View {
    @ObservedObject var viewModel = DisruptionsViewModel()
    
    // Used for refreshing every 60 seconds
    @ObservedObject var timer: TimerHelper
    
    /*
     Used to check whether the bus line text box is currently in focus
     
     It is checked so that the service message automaticaly updates even when the user haven't actually submitted the query (when it loses focus only) so that user doesn't get invalid information
     
     Let's say the user enters bus lane '123' that is fully operational but then wants to check bus lane '321' however he does not submit as after typing the lane number he received an important message on facebook and changed app to check it. He might've forgotten that he did not submit and would technically (incorrectly) see that under bus line '321' it says that it is fully operational while it might not be. This prevents it.
     */
    @FocusState var isTextFieldFocused: Bool
    
    @State var busLineSearchText = ""
    
    init() {
        timer = TimerHelper(limit: 60) {
            // Empty action for now, set in .onAppear
        }
    }
    
    /*
     Returns a header for a given line, with it's matching colour
     */
    private func getLineHeader(name: String) -> some View {
        return LineRectangleView(color: TFLHelper.getColourNameForLine(name: name), name: name)
    }
    
    var body: some View {
        List {
            Section(header: getLineHeader(name: "Bus")) {
                TextField("Search For Bus Line", text: $busLineSearchText)
                    .autocapitalization(.none)
                    .onSubmit {
                        viewModel.getBusDisruptions(line: busLineSearchText)
                    }
                
                if (viewModel.firstBusRequestDone) {
                    DisruptionListView(disruptions: viewModel.busDisruptions)
                }
            }
            
            // Overground
            Section(header: getLineHeader(name: "London Overground")) {
                DisruptionListView(disruptions: Array(viewModel.railBasedDisruptions.overground))
            }
            
            // Elizabeth Line
            Section(header: getLineHeader(name: "Elizabeth Line")) {
                DisruptionListView(disruptions: Array(viewModel.railBasedDisruptions.elizabethLine))
            }
            
            
            // Tube
            ForEach(Array(viewModel.railBasedDisruptions.tube.keys).sorted(by: { first, second in
                // Sort by number of disruptions and if the same then alphabetically
                let disruptionCountFirst  = viewModel.railBasedDisruptions.tube[first]!.count
                let disruptionCountSecond = viewModel.railBasedDisruptions.tube[second]!.count
                
                if (disruptionCountFirst == disruptionCountSecond) {
                    // Same number of disruptuons so alphabetically
                    return first < second
                } else {
                    return disruptionCountFirst > disruptionCountSecond
                }
            }), id: \.self) { key in
                Section(header: getLineHeader(name: key)) {
                    DisruptionListView(disruptions: Array(viewModel.railBasedDisruptions.tube[key]!))
                }
            }
        }
        .listStyle(GroupedListStyle())
        .navigationTitle("Disruptions")
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
                    viewModel.getRailBasedDisruptions()
                    timer.reset()
                } label: {
                    Image(systemName: "goforward") // TODO: Change to actual refresh icon
                }
            }
        }
        .onAppear() {
            viewModel.getRailBasedDisruptions()
            
            // Change the timer's action so that the view model is refreshed every 60 seconds
            timer.changeOnLimitAction() {
                viewModel.getRailBasedDisruptions()
                if (busLineSearchText != "") {
                    viewModel.getBusDisruptions(line: busLineSearchText)
                }
            }
        }
        .onDisappear() {
            // Used to make sure API refresh, fixes CG crash
            viewModel.resetData()
            
            timer.reset()
        }
    }
}

struct DisruptionsView_Previews: PreviewProvider {
    static var previews: some View {
        DisruptionsView()
    }
}
