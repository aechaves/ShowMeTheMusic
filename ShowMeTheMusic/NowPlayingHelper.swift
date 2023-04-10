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
typealias MRMediaRemoteGetNowPlayingApplicationIsPlayingFunction = @convention(c) (DispatchQueue, @escaping (Bool) -> Void) -> Void

enum PlayingState: String {
    case stopped = "stop.circle"
    case paused = "pause.circle"
    case playing = "play.circle"
}

class NowPlayingHelper {
    static var shared = NowPlayingHelper()
    
    var bundle: CFBundle?
    var MRMediaRemoteGetNowPlayingInfo: MRMediaRemoteGetNowPlayingInfoFunction?
    var MRMediaRemoteGetNowPlayingApplicationIsPlaying: MRMediaRemoteGetNowPlayingApplicationIsPlayingFunction?
    var playingState: PlayingState = .stopped
    
    init() {
        // Load framework
        bundle = CFBundleCreate(kCFAllocatorDefault, NSURL(fileURLWithPath: "/System/Library/PrivateFrameworks/MediaRemote.framework"))

        // Get a Swift function for MRMediaRemoteGetNowPlayingInfo
        guard let MRMediaRemoteGetNowPlayingInfoPointer = CFBundleGetFunctionPointerForName(bundle, "MRMediaRemoteGetNowPlayingInfo" as CFString) else { return }
        MRMediaRemoteGetNowPlayingInfo = unsafeBitCast(MRMediaRemoteGetNowPlayingInfoPointer, to: MRMediaRemoteGetNowPlayingInfoFunction.self)
        
        // Get a Swift function for MRMediaRemoteGetNowPlayingApplicationIsPlaying
        guard let MRMediaRemoteGetNowPlayingApplicationIsPlayingPointer = CFBundleGetFunctionPointerForName(bundle, "MRMediaRemoteGetNowPlayingApplicationIsPlaying" as CFString) else { return }
        MRMediaRemoteGetNowPlayingApplicationIsPlaying = unsafeBitCast(MRMediaRemoteGetNowPlayingApplicationIsPlayingPointer, to: MRMediaRemoteGetNowPlayingApplicationIsPlayingFunction.self)
        
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
        
        // Playing state
        MRMediaRemoteGetNowPlayingApplicationIsPlaying!(DispatchQueue.main, { [weak self] isPlaying in
            self?.playingState = isPlaying ? .playing : .paused
        })
    }
    
    func getSong(callback: @escaping (String, String, String, Data?) -> ()) {
        // Refresh playing state
        MRMediaRemoteGetNowPlayingApplicationIsPlaying!(DispatchQueue.main, { [weak self] isPlaying in
            self?.playingState = isPlaying ? .playing : .paused
        })
        
        MRMediaRemoteGetNowPlayingInfo!(DispatchQueue.main, { [weak self] (information) in
            
            if information.isEmpty {
                self?.playingState = .stopped
                callback("-", "-", "-", nil)
            } else {
                let artwork: Data?
                if let artworkDataKeyIndex = information.index(forKey: "kMRMediaRemoteNowPlayingInfoArtworkData") {
                    artwork = information[artworkDataKeyIndex].value as? Data
                } else {
                    artwork = nil
                }
                
                callback(
                    information["kMRMediaRemoteNowPlayingInfoArtist"] as! String,
                    information["kMRMediaRemoteNowPlayingInfoTitle"] as! String,
                    information["kMRMediaRemoteNowPlayingInfoAlbum"] as! String,
                    artwork
                )
            }
        })
    }
    
    @objc
    func playingStateChanged(notification: Notification) {
        // we don't refresh the playingState with kMRMediaRemoteNowPlayingApplicationIsPlayingUserInfoKey here
        // because sometimes multiple notifications will be sent and the few last ones will not have the key, making us think that the playback has stopped
        // (At least during debugging)
        WidgetCenter.shared.reloadTimelines(ofKind: "link.anco.ShowMeTheMusic.NowPlaying")
    }
    
    @objc
    func playingInfoChanged(notification: Notification) {
        WidgetCenter.shared.reloadTimelines(ofKind: "link.anco.ShowMeTheMusic.NowPlaying")
    }
}
