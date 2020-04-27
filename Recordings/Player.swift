import Foundation
import AVFoundation
import Combine

class Player: NSObject, AVAudioPlayerDelegate {
  private var audioPlayer: AVAudioPlayer
  private var timer: Timer?
  
  @Published var didChange : Void
  
  var time: TimeInterval {
    get { audioPlayer.currentTime }
    set { audioPlayer.currentTime = newValue }
  }
  
  init?(url: URL) {
    print("Crteating player for \(url.lastPathComponent)")
    do {
      try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord)
      try AVAudioSession.sharedInstance().setActive(true)
    } catch {
      return nil
    }
    
    if let player = try? AVAudioPlayer(contentsOf: url) {
      audioPlayer = player
    } else {
      return nil
    }
    
    didChange = ()
    super.init()
    
    audioPlayer.delegate = self
  }
  
  func togglePlay() {
    if audioPlayer.isPlaying {
      audioPlayer.pause()
      timer?.invalidate()
      timer = nil
    } else {
      audioPlayer.play()
      if let t = timer {
        t.invalidate()
      }
      timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
        self?.didChange = ()
      }
    }
    
    didChange = ()
  }
  
  func setProgress(_ time: TimeInterval) {
    guard time != audioPlayer.currentTime else { return }
    
    audioPlayer.currentTime = time
    didChange = ()
  }
  
  func setState(isPlaying: Bool, time: TimeInterval) {
    guard audioPlayer.isPlaying != isPlaying else {
      self.time = time
      return
    }
    
    if audioPlayer.isPlaying {
      audioPlayer.pause()
      timer?.invalidate()
      timer = nil
    } else {
      audioPlayer.play()
      if let t = timer {
        t.invalidate()
      }
      timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
        self?.didChange = ()
      }
    }
  }
  
  func audioPlayerDidFinishPlaying(_ pl: AVAudioPlayer, successfully flag: Bool) {
    didChange = ()
    timer?.invalidate()
    timer = nil
  }
  
  var duration: TimeInterval {
    return audioPlayer.duration
  }
  
  var isPlaying: Bool {
    return audioPlayer.isPlaying
  }
  
  var isPaused: Bool {
    return !audioPlayer.isPlaying && audioPlayer.currentTime > 0
  }
  
  deinit {
    timer?.invalidate()
  }
}

extension Player {
  struct State {
    var isPlaying: Bool
    var position: TimeInterval
  }
  
  enum Action {
    case update(State)
  }
  
  var state : State { return .init(isPlaying: isPlaying, position:time) }
  static let reducer = Reducer<State, Action, ()>() { state, action, _ in
      guard case let .update(newState) = action else { return [] }
      state = newState
      return []
  }
}
