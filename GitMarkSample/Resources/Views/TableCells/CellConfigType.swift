//
//  CellConfigType.swift
//  GitMarkSample
//
//  Created by Eido Goya on 2022/04/30.
//

import UIKit

protocol CellConfigType {
    
    var cellIdentifier: String { get }
    var cellHeight: CGFloat { get }
    
    func configure(cell: UITableViewCell,
                   with indexPath: IndexPath)
    -> UITableViewCell
    
    func distinctIdentifier()
    -> String
    
}
