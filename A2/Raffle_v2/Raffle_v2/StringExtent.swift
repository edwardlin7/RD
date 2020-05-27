//
//  StringExtent.swift
//  Raffle_v2
//
//  Created by Chengming Liu on 24/5/20.
//  Copyright © 2020 University of Tasmania. All rights reserved.
//

import Foundation

extension String {
  
  // Returns true if the string has at least one character in common with matchCharacters.
  func containsCharactersIn(matchCharacters: String) -> Bool {
    let characterSet = CharacterSet(charactersIn: matchCharacters)
    return self.rangeOfCharacter(from: characterSet) != nil
  }
  
  // Returns true if the string contains only characters found in matchCharacters.
  func containsOnlyCharactersIn(matchCharacters: String) -> Bool {
    let disallowedCharacterSet = CharacterSet(charactersIn: matchCharacters).inverted
    return self.rangeOfCharacter(from: disallowedCharacterSet) == nil
  }
  
  // Returns true if the string has no characters in common with matchCharacters.
  func doesNotContainCharactersIn(matchCharacters: String) -> Bool {
    let characterSet = CharacterSet(charactersIn: matchCharacters)
    return self.rangeOfCharacter(from: characterSet) == nil
  }

}
