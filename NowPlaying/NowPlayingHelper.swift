//
//  NowPlayingHelper.swift
//  ShowMeTheMusic
//
//  Created by Angelo Chaves on 2022-01-03.
//  Built with the help of: https://stackoverflow.com/questions/61003379/how-to-get-currently-playing-song-on-mac-swift

import Foundation
import MediaPlayer
import WidgetKit

typealias MRMediaRemoteGetNowPlayingInfoFunction = @convention(c) (DispatchQueue, @escaping ([String: Any]) -> Void) -> Void

struct Song {
    let artist: String
    let title: String
    let album: String
    let duration: String
    let artwork: Data
}

class NowPlayingHelper {
    static var shared = NowPlayingHelper()
    
    var bundle: CFBundle?
    var MRMediaRemoteGetNowPlayingInfo: MRMediaRemoteGetNowPlayingInfoFunction?
    var currentSong: Song?
    
    init() {
        // Load framework
        bundle = CFBundleCreate(kCFAllocatorDefault, NSURL(fileURLWithPath: "/System/Library/PrivateFrameworks/MediaRemote.framework"))

        // Get a Swift function for MRMediaRemoteGetNowPlayingInfo
        guard let MRMediaRemoteGetNowPlayingInfoPointer = CFBundleGetFunctionPointerForName(bundle, "MRMediaRemoteGetNowPlayingInfo" as CFString) else { return }
        MRMediaRemoteGetNowPlayingInfo = unsafeBitCast(MRMediaRemoteGetNowPlayingInfoPointer, to: MRMediaRemoteGetNowPlayingInfoFunction.self)
        
        // Get the private notification name for when playing state and playing information changes
        let playingStateNotificationPointer = CFBundleGetDataPointerForName(bundle, "MRMediaRemoteNowPlayingApplicationIsPlayingDidChangeNotification" as CFString)
        let playingStateNotification = unsafeBitCast(playingStateNotificationPointer, to: Notification.Name.self)
        
        let playingInfoNotificationPointer = CFBundleGetDataPointerForName(bundle, "MRMediaRemoteNowPlayingInfoDidChangeNotification" as CFString)
        let playingInfoNotification = unsafeBitCast(playingInfoNotificationPointer, to: Notification.Name.self)
        
        // Notifications
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playingStateChanged),
                                               name: playingStateNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playingInfoChanged),
                                               name: playingInfoNotification,
                                               object: nil)
    }
    
    func getSong(callback: @escaping (String, String, String) -> ()) {
        MRMediaRemoteGetNowPlayingInfo!(DispatchQueue.main, { (information) in
            //print(information["kMRMediaRemoteNowPlayingInfoDuration"] as! String) // not a string
            //let artwork = NSImage(data: information["kMRMediaRemoteNowPlayingInfoArtworkData"] as! Data)
            
            callback(
                information["kMRMediaRemoteNowPlayingInfoArtist"] as! String,
                information["kMRMediaRemoteNowPlayingInfoTitle"] as! String,
                information["kMRMediaRemoteNowPlayingInfoAlbum"] as! String
            )
        })
    }
    
    @objc
    func playingStateChanged(notification: Notification) {
        WidgetCenter.shared.reloadTimelines(ofKind: "link.anco.ShowMeTheMusic.NowPlaying")
    }
    
    @objc
    func playingInfoChanged(notification: Notification) {
        WidgetCenter.shared.reloadTimelines(ofKind: "link.anco.ShowMeTheMusic.NowPlaying")
    }
}
