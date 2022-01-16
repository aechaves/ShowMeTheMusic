#  Show Me The Music

A widget to display the currently playing song in macOS. Uses private APIs to obtain the track information and to subscribe to notifications.

## TODOs

* Configurations
    * Display album artwork/Artist/Album name
* Large size
    * Display information about the queue (next song, etc)
    * Display if currently is in repeating/suffle modes
* Small size
    * Adapt current layout
* Publish to GitHub
* Create an icon and build an app
* Notarize it? and create a release in GitHub
* Change widget color based on tint color if available (kMRNowPlayingClientUserInfoKey). See
    ```
    AnyHashable("kMRNowPlayingClientUserInfoKey"): {
        bundleIdentifier = "com.apple.Music";
        displayName = Music;
        processIdentifier = 9830;
        processUserIdentifier = 501;
        tintColor =     {
            alpha = 1;
            blue = "0.9843137";
            green = "0.5294118";
            red = "0.1490196";
        };
    }
    ```
