//
//  CacheManager.swift
//  GitMarkSample
//
//  Created by Eido Goya on 2022/04/29.
//

import Kingfisher

protocol CacheManagerProtocol {
    
    func retrieveImage(
        with resource: Resource,
        options: KingfisherOptionsInfo?,
        progressBlock: DownloadProgressBlock?,
        downloadTaskUpdated: DownloadTaskUpdatedBlock?,
        completionHandler: ((Result<RetrieveImageResult, KingfisherError>) -> Void)?) -> DownloadTask?
    
}

extension KingfisherManager: CacheManagerProtocol {
}
