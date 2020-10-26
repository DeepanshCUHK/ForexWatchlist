//
//  NetworkConfig.swift
//  ForexWatchlist
//
//  Created by Deepansh Jagga on 23/10/2020.
//  Copyright © 2020 Deepansh Jagga. All rights reserved.
//

import Foundation
import Alamofire

class NetworkConfig {
    
    typealias WebServiceResponse = (NSDictionary?, Error?) -> Void
    
    func execute (_ url: URL, completion: @escaping WebServiceResponse) {
        AF.request(url).validate().responseJSON(completionHandler: { response in
            if let error = response.error {
                completion(nil, error)
            }else if let jsonArray = response.value as? NSDictionary {
                completion(jsonArray, nil)
            }
        })
    }
}
