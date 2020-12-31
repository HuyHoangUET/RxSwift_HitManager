//
//  SectionOfHit.swift
//  HitsManager
//
//  Created by LTT on 29/12/2020.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

struct SectionOfHit {
    var items: [Item]
  }
  extension SectionOfHit: SectionModelType {
    typealias Item = Hit

     init(original: SectionOfHit, items: [Item]) {
      self = original
      self.items = items
    }
  }
