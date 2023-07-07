import SwiftUI

/*
 App settings accessed by the gear icon on the home screen
 */
struct SettingsView: View {
    /*
     User settings, for their explaination see SettingsHelper in Utilities
     */
    @AppStorage(AppSetting.theme.rawValue) private var theme = AppSettingTheme.automatic
    
    @AppStorage(AppSetting.filterStopsWithoutLines.rawValue) private var filterStops = true
    
    @AppStorage(AppSetting.arrivalTimeFormat.rawValue) private var arrivalTimeFormat = AppSettingArrivalTimeFormat.minutes
    
    @AppStorage(AppSetting.nearbySearchRange.rawValue) private var nearbySearchRange = 200
    
    @AppStorage(AppSetting.favouritesSorting.rawValue) private var favouritesSorting = AppSettingFavouritesSorting.name
    
    // Executed on window (modal) dismissal
    let dismiss: () -> Void
    
    // This is here so that if theme option is changed SettingsView also changes its theme without needing to be reappeared just like home view
    var colorScheme: Optional<ColorScheme> {
        switch (theme) {
        case .automatic:
            return Optional.none
            
        case .light:
            return Optional.some(ColorScheme.light)
            
        case .dark:
            return Optional.some(ColorScheme.dark)
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("General")) {
                    // Theme Picker
                    Picker(selection: $theme, label: HStack {
                        Image(systemName: "paintpalette")
                            .foregroundColor(.accentColor)
                        Text("Theme")
                    }) {
                        Text("Automatic").tag(AppSettingTheme.automatic)
                        Text("Light")    .tag(AppSettingTheme.light)
                        Text("Dark")     .tag(AppSettingTheme.dark)
                    }
                }
                Section(header: Text("Options")) {
                    // Filter Empty Stops
                    Toggle(isOn: $filterStops) {
                        HStack {
                            Image(systemName: "camera.filters")
                                .foregroundColor(.accentColor)
                            Text("Filter Stops Without Lines")
                        }
                    }
                    
                    // Arrival time format picket
                    Picker(selection: $arrivalTimeFormat, label: HStack {
                        Image(systemName: "clock")
                            .foregroundColor(.accentColor)
                        Text("Arrival Time Format")
                    }) {
                        Text("Minutes").tag(AppSettingArrivalTimeFormat.minutes)
                        Text("Seconds").tag(AppSettingArrivalTimeFormat.seconds)
                        Text("Clock")  .tag(AppSettingArrivalTimeFormat.clock)
                    }
                    
                    // Nearby Search Range
                    Picker(selection: $nearbySearchRange, label: HStack {
                        Image(systemName: "location")
                            .foregroundColor(.accentColor)
                        Text("Nearby Search Range")
                    }) {
                        // Limites user choices as there are problem with tfl's api with certain values
                        Text("Default").tag(200)
                        Text("Close")  .tag(100)
                        Text("Far")    .tag(500)
                    }
                    
                    // Favourites Sorting
                    Picker(selection: $favouritesSorting, label: HStack {
                        Image(systemName: "star")
                            .foregroundColor(.accentColor)
                        Text("Sort Favourites By")
                    }) {
                        Text("Name").tag(AppSettingFavouritesSorting.name)
                        Text("Date").tag(AppSettingFavouritesSorting.date)
                    }
                }
                Section(header: Text("Other")) {
                    NavigationLink(destination: PrivacyPolicyView()) {
                        Label("Privacy Policy", systemImage: "info.circle")
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem {
                    // Dissmisses the settings menu
                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
                    }
                }
            }
            .preferredColorScheme(colorScheme)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(dismiss: {})
    }
}
