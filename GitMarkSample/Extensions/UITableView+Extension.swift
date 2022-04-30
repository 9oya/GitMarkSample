//
//  UITableView+Extension.swift
//  GitMarkSample
//
//  Created by Eido Goya on 2022/04/30.
//

import UIKit

extension UITableView {
    
    func registerCellsWithNib(_ cellTypes: [UITableViewCell.Type]) {
        cellTypes.forEach { cellType in
            let id = String(describing: cellType)
            self.register(UINib(nibName: id,
                                bundle: nil),
                          forCellReuseIdentifier: id)
        }
    }
    
    func registerCells(_ cellTypes: [UITableViewCell.Type]) {
        cellTypes.forEach { cellType in
            let id = String(describing: cellType)
            self.register(cellType.self, forCellReuseIdentifier: id)
        }
    }
    
}
