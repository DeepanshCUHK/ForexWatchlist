//
//  WatchlistEditViewController.swift
//  ForexWatchlist
//
//  Created by Deepansh Jagga on 23/10/2020.
//  Copyright © 2020 Deepansh Jagga. All rights reserved.
//

import UIKit
import RxSwift
import RealmSwift

class WatchlistEditViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!

    var checkedRows = [IndexPath]()
    let realm = try! Realm()
    private let selectedSymbols = PublishSubject<[String]>()
    var selectedSymbolsObservable: Observable<[String]>{
        selectedSymbols.asObservable()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    @IBAction func saveButton(_ sender: Any) {
        var selectedSymbols: [String] = []
        for indexpath in checkedRows {
            selectedSymbols.append(AppConfig().symbols[indexpath.row])
        }
        self.selectedSymbols.onNext(selectedSymbols)
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource

extension WatchlistEditViewController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AppConfig().symbols.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WatchlistSymbolsViewCell", for: indexPath) as! WatchlistEditTableViewCell
        let getForexObjectsfromRealM = self.realm.objects(Forex.self)
        let getForexArrayfromRealM = getForexObjectsfromRealM.value(forKeyPath:"symbol") as! [String]
        
        if getForexArrayfromRealM.contains(AppConfig().symbols[indexPath.row]) {
            cell.accessoryType = .checkmark
            checkedRows.append(indexPath)
        }

        cell.symbolLabel.text = AppConfig().symbolDisplayFormat(symbol: AppConfig().symbols[indexPath.row])
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell:WatchlistEditTableViewCell = tableView.cellForRow(at: indexPath) as! WatchlistEditTableViewCell
        let getForexObjectsfromRealM = self.realm.objects(Forex.self)
        let getForexArrayfromRealM = getForexObjectsfromRealM.value(forKeyPath:"symbol") as! [String]

        if(!getForexArrayfromRealM.contains(AppConfig().symbols[indexPath.row])){
            cell.accessoryType = .checkmark
            checkedRows.append(indexPath)
        }else{
            cell.accessoryType = .none
            if let checkedItemIndex = checkedRows.firstIndex(of: indexPath){
                checkedRows.remove(at: checkedItemIndex)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell:WatchlistEditTableViewCell = tableView.cellForRow(at: indexPath) as! WatchlistEditTableViewCell
        let getForexObjectsfromRealM = self.realm.objects(Forex.self)
        let getForexArrayfromRealM = getForexObjectsfromRealM.value(forKeyPath:"symbol") as! [String]

        if(!getForexArrayfromRealM.contains(AppConfig().symbols[indexPath.row])){
            cell.accessoryType = .none
            if let checkedItemIndex = checkedRows.firstIndex(of: indexPath){
                checkedRows.remove(at: checkedItemIndex)
            }
        }else{
            cell.accessoryType = .checkmark
            checkedRows.append(indexPath)
        }
    }
}

