//
//  PlayerViewEnvWrapper.swift
//  Recordings
//
//  Created by Todd Bates on 4/20/20.
//  Copyright © 2020 objc.io. All rights reserved.
//

import Foundation
import Combine

extension Publisher {
  func cancellable(_ store:@escaping (AnyCancellable)->()) -> AnyPublisher<Output, Failure> {
    return Deferred { () -> PassthroughSubject<Output, Failure> in
      let subject = PassthroughSubject<Output, Failure>()
      store(self.subscribe(subject))
      return subject
    }
    .eraseToAnyPublisher()
  }
}

protocol PlayerType : ObservableObject {
  var duration: TimeInterval { get }
  var time: TimeInterval { get set }
  
  var isPlaying: Bool { get }
  
  func togglePlay()->()
}

class PlayerViewEnvWrapper<T : PlayerType>  {
  var cancellable : Cancellable?
  var player : T! = nil
  let factory : ()->T?
  
  init(_ factory: @escaping ()->T?) {
    self.factory = factory
  }
  
  fileprivate func load()->Effect<PlayerView.Action> {
    player = factory()
    return self.player.objectWillChange
      .cancellable( { self.cancellable = $0} )
      .map { _ in .effectResult(self.time) }
      .prepend(Just(.effectResult(.duration(self.player.duration))))
      .eraseToEffect()
  }
  
  fileprivate var time : PlayerEnvResult {
    if player.isPlaying {
      return .playing(time: player.time)
    } else {
      return .stopped(time: player.time)
    }
  }
  
  var env : PlayerEnv {
    return { [unowned self] action in
      switch action {
      case .toggle:
        self.player.togglePlay()
        return Effect.sync {
          .effectResult(self.time)
        }
      case .load:
        return self.load()
      case .unload:
        let time = PlayerEnvResult.stopped(time: self.player.time)
        self.cancellable?.cancel()
        self.player = nil
        return Effect.sync {
          .effectResult(time)
        }
      case let .position(time):
        self.player.time = time
        return Effect.sync {
          .effectResult(self.time)
        }
      }
    }
  }
}

extension Player : PlayerType {
}

