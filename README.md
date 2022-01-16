#  Show Me The Music

A widget to display the currently playing song in macOS. Uses private APIs to obtain the track information and to subscribe to notifications.
The widget should (hopefulyl) update when you play/pause or when changing tracks. Otherwise it refreshes every 5 minutes.

<img width="344" alt="Screen Shot 2022-01-08 at 22 09 12" src="https://user-images.githubusercontent.com/7105354/149683255-c3c6796b-485c-4471-9fa4-c59b5aec5546.png">
<img width="365" alt="Screen Shot 2022-01-16 at 20 53 12" src="https://user-images.githubusercontent.com/7105354/149683273-40d94184-ba5e-44d4-ad0c-a1036ae74146.png">



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
