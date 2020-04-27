//
//  PlayerView.swift
//  Recordings
//
//  Created by Todd Bates on 4/19/20.
//  Copyright © 2020 objc.io. All rights reserved.
//

import SwiftUI
import CasePaths
import Combine

typealias PlayerViewEnv = (load: ()->TimeInterval, togglePlay: ()->Bool, position: (TimeInterval)->(),unload: ()->())
let playerViewReducer = Reducer<PlayerView.State, PlayerView.Action, PlayerViewEnv> { state, action, env in
    switch action {
    case .load:
      state.duration = env.load()
    case .unload:
      env.unload()
    case let .setName(name):
      state.name = name
    case let .setPostion(position):
      state.position = position
      env.position(position)
    case .togglePlay:
      state.isPlaying = env.togglePlay()
    }
    
    return []
}

struct PlayerView: View {
  
  struct State : Equatable{
    var name: String
    
    var duration: TimeInterval
    var position: TimeInterval = 0
    var isPlaying : Bool = false
    
    var buttonState : String {
      if isPlaying {
        return "Pause"
      } else if position > 0 {
        return "Resume"
      }
      
      return "Play"
    }
  }
  
  enum Action : Equatable {
    case load
    case unload
    case setName(String)
    case setPostion(TimeInterval)
    case togglePlay
  }
  
  @ObservedObject private var store: ViewStore<State, Action>
  var value : State { store.value }
  
  public init(store: ViewStore<State, Action>) {
    self.store = store
  }
  
  var body: some View {
    VStack(spacing: 20) {
      HStack {
        Text("Name")
        TextField("Name",
                  text: store.bind(\State.name , /Action.setName))
          .textFieldStyle(RoundedBorderTextFieldStyle())
      }
      HStack {
        Text(timeString(value.position))
        Spacer()
        Text(timeString(value.duration))
      }
      Slider(value: store.bind(\State.position , /Action.setPostion),
             in: 0...value.duration)
      Button( value.buttonState, action: store.curry(.togglePlay))
        .buttonStyle(PrimaryButtonStyle())
      Spacer()
    }
    .padding()
    .onAppear( perform: store.curry(.load) )
    .onDisappear( perform: store.curry(.unload) )
  }
}
