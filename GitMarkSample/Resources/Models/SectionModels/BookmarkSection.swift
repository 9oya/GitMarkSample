//
//  BookmarkSection.swift
//  GitMarkSample
//
//  Created by Eido Goya on 2022/05/02.
//

import RxDataSources

struct BookmarkSection {
    var header: String
    var items: [Item]
}

extension BookmarkSection: SectionModelType {
    typealias Item = CellConfigType
    
    init(original: BookmarkSection, items: [Item]) {
        self = original
        self.items = items
    }
}
