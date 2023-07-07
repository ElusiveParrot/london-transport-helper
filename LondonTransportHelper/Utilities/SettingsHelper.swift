/*
 Represents various settings labels for @AppStorage annotation where enum's rawValue is used
 */
enum AppSetting: String {
    case theme                   = "theme"                // Application's color scheme
    case filterStopsWithoutLines = "filter-stops"         // Whether stops without any lines should not be displayed
    case arrivalTimeFormat       = "arrival-format"       // Format of the text that shows when the vehicle will arrie
    case nearbySearchRange       = "nearby-search-range"  // Range of search of 'Nearby Stops' function
    case favouritesSorting       = "fav-sort-by"          // How favourite stops are sorted
}

/*
 Possible values for individual non-primitive type settings
 */

enum AppSettingTheme: Int {
    case automatic // Whatever user's current iOS settings are
    case dark
    case light
}

enum AppSettingArrivalTimeFormat: Int {
    case minutes // X Minutes / Due
    case seconds // X Seconds / Due
    case clock   // XX:YY
}

enum AppSettingFavouritesSorting: Int {
    case name // Sort alphabetically
    case date // Sort by newest added
}
