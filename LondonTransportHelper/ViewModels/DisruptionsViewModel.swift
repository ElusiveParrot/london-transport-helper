import Foundation

class DisruptionsViewModel: ObservableObject {
    @Published var railBasedDisruptions: DisruptionForRailBasedTransportsList = DisruptionForRailBasedTransportsList(tube: [:], dlr: [], overground: [], elizabethLine: [])
    @Published var busDisruptions:       [Disruption] = []
    
    /*
     This flips to true when the first API request is completed (unless it fails) and flips again when the view disappears
     
     It's used so that when the disruptions view first loads it does not show "Service Fully Operational" message when there was no bus line entered at the start.
     */
    var firstBusRequestDone = false
    
    private let disruptionsSevice = DisruptionsService()
    
    /*
     Get disruptions for a single bus line
     */
    func getBusDisruptions(line: String) {
        disruptionsSevice.getDisruptionsForLine(line: line) { result in
            switch (result) {
            case .success(let disruptions):
                DispatchQueue.main.async {
                    self.busDisruptions = disruptions
                    self.firstBusRequestDone = true
                }
                
            case .failure(let error):
#if DEBUG
                print("Unable to fetch bus \(line) disruptions from API, \(error)")
#endif
                DispatchQueue.main.async {
                    self.busDisruptions = []
                }
            }
        }
    }
    
    /*
     Get disruptions for every rail based (ex: overground, tube) line
     */
    func getRailBasedDisruptions() {
        // DLR
        disruptionsSevice.getDisruptionsForMode(mode: .dlr) { result in
            switch (result) {
            case .success(let disruptions):
                DispatchQueue.main.async {
                    self.railBasedDisruptions.dlr = disruptions
                }
                
            case .failure(let error):
#if DEBUG
                print("Unable to fetch DLR disruptions from API, \(error)")
#endif
                DispatchQueue.main.async {
                    self.railBasedDisruptions.dlr = []
                }
            }
        }
        
        // Overground
        disruptionsSevice.getDisruptionsForMode(mode: .overground) { result in
            switch (result) {
            case .success(let disruptions):
                DispatchQueue.main.async {
                    self.railBasedDisruptions.overground = disruptions
                }
                
            case .failure(let error):
#if DEBUG
                print("Unable to fetch overground disruptions from API, \(error)")
#endif
                DispatchQueue.main.async {
                    self.railBasedDisruptions.overground = []
                }
            }
        }
        
        // Elizabeth Line
        disruptionsSevice.getDisruptionsForMode(mode: .elizabethLine) { result in
            switch (result) {
            case .success(let disruptions):
                DispatchQueue.main.async {
                    self.railBasedDisruptions.elizabethLine = disruptions
                }
                
            case .failure(let error):
#if DEBUG
                print("Unable to fetch elizabeth line disruptions from API, \(error)")
#endif
                DispatchQueue.main.async {
                    self.railBasedDisruptions.elizabethLine = []
                }
            }
        }
        
        // Tube (search for disruptions for each of tue line)
        for tubeLine in TFLHelper.tubeLines {
            disruptionsSevice.getDisruptionsForLine(line: tubeLine.id) { result in
                switch (result) {
                case .success(let disruptions):
                    DispatchQueue.main.async {
                        self.railBasedDisruptions.tube[tubeLine.name] = disruptions
                    }
                    
                case .failure(let error):
#if DEBUG
                    print("Unable to fetch tube line \(tubeLine) disruptions from API, \(error)")
#endif
                    DispatchQueue.main.async {
                        self.railBasedDisruptions.tube[tubeLine.name] = []
                    }
                }
            }
        }
    }
    
    /*
     Reset the view model, fixes CG bug.
     */
    func resetData() {
        railBasedDisruptions = DisruptionForRailBasedTransportsList(tube: [:], dlr: [], overground: [], elizabethLine: [])
        busDisruptions       = []
        firstBusRequestDone  = false
    }
}

