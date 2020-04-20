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

class PlayerViewEnvWrapper {
  var cancellable : Cancellable?
  
  init() {
  }
  
  fileprivate func start(_ position: TimeInterval = 0) -> Effect<PlayerView.Action> {
    let start = Date()
    self.cancellable?.cancel()
    return Timer.TimerPublisher(interval: 0.1, runLoop: .main, mode: .default)
      .autoconnect()
      .map { .effectResult(.playing(position: $0.timeIntervalSince(start) + position)) }
      .cancellable { self.cancellable = $0 }
      .eraseToEffect()
  }
  
  fileprivate func stop() -> Effect<PlayerView.Action> {
    return Effect.sync {
      self.cancellable?.cancel()
      self.cancellable = nil
      return .effectResult(.stopped(position: 0))
    }
  }
  
  var env : PlayerEnv {
    return { [unowned self] action in
      switch action {
      case .toggle:
        if self.cancellable == nil {
          return self.start()
        } else {
          return self.stop()
        }
      case .load:
        return Effect.sync {
          return .effectResult(.length( 120 ))
        }
      case let .position(position):
        self.cancellable?.cancel()
        self.cancellable = nil
        return self.start(position)
      }
    }
  }
}
