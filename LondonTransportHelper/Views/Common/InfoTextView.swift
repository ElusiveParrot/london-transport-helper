import SwiftUI

/*
 Used to convey important information to the user (errors, no data etc)
 */
struct InfoTextView: View {
    var text: String
    
    var body: some View {
        VStack {
            Spacer()
            Text(text)
                .font(.headline)
                .foregroundColor(.gray)
                .padding()
            Spacer()
        }
    }
}

struct InfoTextView_Previews: PreviewProvider {
    static var previews: some View {
        InfoTextView(text: "Hello, World!")
    }
}
