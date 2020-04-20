//
//  PlayerViewTests.swift
//  RecordingsTests
//
//  Created by Todd Bates on 4/19/20.
//  Copyright © 2020 objc.io. All rights reserved.
//

import XCTest
import SwiftUI
import SnapshotTesting
@testable import UnitTestHostApp

class PlayerViewTests: XCTestCase {
  var playing  = false
  var position : TimeInterval = 0
  
  func env() -> PlayerEnv {
    return {
      switch $0 {
      case .load:
        return Effect.sync {
          return .effectResult(.length( 100 ))
        }
      case let .position(newPostion):
        return Effect.sync {
          self.position = newPostion
          if self.playing {
            return .effectResult(.playing(position: self.position))
          }
          else {
            return .effectResult(.stopped(position: self.position))
          }
        }
      case .toggle:
        return Effect.sync {
          self.playing = !self.playing
          if self.playing {
            return .effectResult(.playing(position: self.position))
          }
          else {
            return .effectResult(.stopped(position: self.position))
          }
        }
      }
    }
  }
  
  func testStartSnapshot()  {
    let store = Store(
      initialValue: PlayerView.State(name: "Peter", duration: 0, position: 50, buttonState: .start),
      reducer: playerViewReducer, environment: env())
    
    let view = PlayerView(store: store.view)
    let vc = UIHostingController(rootView: view)
    
    assertSnapshot(matching: vc, as: .image)
  }
  
  func testPauseSnapshot()  {
    let store = Store(
      initialValue: PlayerView.State(name: "Peter", duration: 0, position: 0, buttonState: .pause),
      reducer: playerViewReducer, environment: env())
    
    let view = PlayerView(store: store.view)
    let vc = UIHostingController(rootView: view)
    
    assertSnapshot(matching: vc, as: .image)
  }
  
  func testResumeSnapshot()  {
    let store = Store(
      initialValue: PlayerView.State(name: "Peter", duration: 0, position: 0, buttonState: .resume),
      reducer: playerViewReducer, environment: env())
    
    let view = PlayerView(store: store.view)
    let vc = UIHostingController(rootView: view)
    
    assertSnapshot(matching: vc, as: .image)
  }
  
  func testReducer() {
    assert(
      initialValue: PlayerView.State(name: "Peter", duration: 0, position: 50, buttonState: .resume),
      reducer: playerViewReducer,
      environment: env(),
      steps:
      Step(.send, .load) { _ in },
      Step(.receive, .effectResult(.length(100))) { $0.duration = 100 },
      Step(.send, .setName("New Name")) { $0.name = "New Name" },
      Step(.send, .togglePlay) { _ in },
      Step(.receive, .effectResult(.playing(position: 0))) {
        $0.buttonState = .pause
        $0.position = 0
      },
      Step(.send, .togglePlay) { _ in self.position = 20},
      Step(.receive, .effectResult(.stopped(position: 20))) {
        $0.buttonState = .resume
        $0.position = 20
      },
      Step(.send, .togglePlay) { _ in },
      Step(.receive, .effectResult(.playing(position: 20))) {
        $0.buttonState = .pause
      },
      Step(.send, .togglePlay) { _ in self.position = 0 },
      Step(.receive, .effectResult(.stopped(position: 0))) {
        $0.buttonState = .start
        $0.position = 0
      },
      Step(.send, .setPostion(50)) { _ in  },
      Step(.receive, .effectResult(.stopped(position: 50))) {
        $0.buttonState = .resume
        $0.position = 50
      }
    )
  }
}
