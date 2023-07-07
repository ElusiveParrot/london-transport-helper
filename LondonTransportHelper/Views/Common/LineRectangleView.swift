import SwiftUI

/*
 Used for line names for stops
 */
struct LineRectangleView: View {
    var color: Color
    var name:  String
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(color)
                .cornerRadius(5)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 20, maxHeight: 20)
            Text(name.capitalized)
                .font(.subheadline)
                .foregroundColor(.white)
                .padding()
                .fontWeight(.bold)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

struct LineRectangleView_Previews: PreviewProvider {
    static var previews: some View {
        LineRectangleView(color: .blue, name: "Picadilly")
    }
}
