import SwiftUI

/*
 Simple text field wih an image next to it
 */
struct CustomTextFieldView: View {
    @Binding var text: String
    
    var imageName:      String // Apple's SF Icon Image name
    var backgroundText: String
    
    // Called when user submits the text in the text field
    var onSubmitAction: () -> ()
    
    // Called when the text inside the text field changes, nothing by default
    var onChangeAction: () -> () = {}
    
    var body: some View {
        HStack {
            Image(systemName: imageName)
            TextField(backgroundText, text: $text)
                .autocapitalization(.none)
                .onSubmit {
                    onSubmitAction()
                }
                .onChange(of: text) { _ in
                    onChangeAction()
                }
        }
    }
}

struct CustomTextFieldView_Previews: PreviewProvider {
    static var previews: some View {
        CustomTextFieldView(text: .constant(""), imageName: "magnifyingglass", backgroundText: "Search", onSubmitAction: {})
    }
}
