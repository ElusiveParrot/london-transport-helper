import SwiftUI
import MapKit

/*
 Represents an annotation on the map view
 */
struct MapAnnotation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

/*
 Used to display a map inside a view
 */
struct MapView: View {
    let lat: Double
    let lon: Double
    
    var body: some View {
        Map(
            // Map coordinates
            coordinateRegion: .constant(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: lat, longitude: lon), span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001))),
            // Annotations
            annotationItems: [MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon))]) { annotation in
                MapMarker(coordinate: annotation.coordinate, tint: .red)
            }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(lat: 51.5074, lon: 0.1272)
            .previewLayout(PreviewLayout.sizeThatFits)
            .padding()
            .frame(height: 200)
    }
}
