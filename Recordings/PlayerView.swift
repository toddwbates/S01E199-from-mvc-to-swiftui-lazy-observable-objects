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

enum PlayerEnvAction : Equatable {
  case load
  case unload
  case position(TimeInterval)
  case toggle
}

enum PlayerEnvResult : Equatable{
  case duration(TimeInterval)
  case isPlaying(Bool)
  case position(TimeInterval)
}

typealias PlayerEnv = (PlayerEnvAction)->Effect<PlayerView.Action>

fileprivate func effectReducer (_ state:inout PlayerView.State,_ action: PlayerEnvResult){
  switch action {
  case let .duration(length):
    state.duration = length
  case let .isPlaying(isPlaying):
    state.isPlaying = isPlaying
  case let .position(time):
    state.position = time
  }
}

let playerViewReducer = Reducer<PlayerView.State, PlayerView.Action, PlayerEnv> { state, action, env in
  switch action {
  case .load:
    return [env(.load)
    ,env(.position(state.position))]
  case .unload:
    _ = env(.unload)
  case let .setName(name):
    state.name = name
  case let .setPostion(position):
    return [env(.position(position))]
  case .togglePlay:
    return [env(.toggle)]
  case let .effectResult(effectResult):
    effectReducer(&state, effectResult)
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
      } else {
        return "Play"
      }
    }
  }
  
  enum Action : Equatable {
    case load
    case unload
    case setName(String)
    case setPostion(TimeInterval)
    case togglePlay
    case effectResult(PlayerEnvResult)
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
