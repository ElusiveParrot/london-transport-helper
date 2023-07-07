import SwiftUI

/*
 Shows app's privacy policy
 */
struct PrivacyPolicyView: View {
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Image("ApplicationIcon")
                    .resizable()
                    .frame(width: 60, height: 60)
                Text("London Transport Helper")
                    .padding()
                Spacer()
            }
            
            VStack {
                Divider()
                Text("Privacy Policy")
                    .font(.headline)
                Divider()
                Text("This app does not collect any personal infromation about it's users apart from the location data which is used to find stops nearby your location. This data is sent to TFL (Transport for London) API in order to find stops mentioned above. As soon as a repsponse is received the location data is discarded - We do not rent, sell or share personal information about you with other people or non-affiliated companies")
            }
            
            VStack {
                Divider()
                Text("Changes")
                    .font(.headline)
                Divider()
                Text("This privacy policy is only valid for this specific version of the app, if you update the app please check the privacy policy again for any changes.")
            }
            
            VStack {
                Divider()
                Text("Contact Us")
                    .font(.headline)
                Divider()
                Text("Questions, comments and requests regarding this privacy policy are welcomed and should be addressed to Daniel Wenda at K2028420@kingston.ac.uk")
            }
            
            Spacer()
        }
        .padding()
    }
}

struct PrivacyPolicyView_Previews: PreviewProvider {
    static var previews: some View {
        PrivacyPolicyView()
    }
}
