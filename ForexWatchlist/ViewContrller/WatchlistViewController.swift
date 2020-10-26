//
//  WatchlistViewController.swift
//  ForexWatchlist
//
//  Created by Deepansh Jagga on 22/10/2020.
//  Copyright © 2020 Deepansh Jagga. All rights reserved.
//

import UIKit
import RxSwift
import HandyJSON
import SwiftyJSON
import RealmSwift

class WatchlistViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var equityLabel: UILabel!
    
    let disposeBag = DisposeBag()
    //var newSelectedSymbolsArray: [String] = []
    let activityIndicatorView = UIActivityIndicatorView()
    var vieww = UIView()
    let realmSymbolsInWatchListArray = try! Realm().objects(Forex.self).sorted(by: ["symbol"])
    let realm = try! Realm()
    var networkHelp = NetworkConfig()
    
    override func viewWillAppear(_ animated: Bool) {
        self.showActivityIndicator()
        updateView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setTimerforRegularRateFetch()
    }
    
    private func setupUI() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        tableView.backgroundColor = UIColor.clear
        tableView.separatorColor = UIColor.clear
        
        let getForexObjectsfromRealM = self.realm.objects(Forex.self)
        let getBalanceArrayfromRealM = getForexObjectsfromRealM.value(forKeyPath:"balance") as! [Double]
        let getEquityArrayfromRealM = getForexObjectsfromRealM.value(forKeyPath:"equity") as! [Double]
        
        self.balanceLabel.text = "\(AppConfig().numberWithCommaDisplayFormat(number: getBalanceArrayfromRealM.reduce(0,+)))"
        self.equityLabel.text = "\(AppConfig().numberWithCommaDisplayFormat(number: getEquityArrayfromRealM.reduce(0, +)))"
        
    }
    
    private func setTimerforRegularRateFetch() {
        _ = Timer.scheduledTimer(timeInterval: TimeInterval(AppConfig().rateRefreshInterval), target: self, selector: #selector(timerTriggerupdateForexList), userInfo: nil, repeats: true)
    }
    
    @objc private func timerTriggerupdateForexList() {
        print("Refresh: Get Rate")
        let getForexObjectsfromRealM = self.realm.objects(Forex.self)
        let getForexArrayfromRealM = getForexObjectsfromRealM.value(forKeyPath:"symbol") as! [String]
        updateForexList(newSelectedSymbolsArray: getForexArrayfromRealM)
    }
    
    private func updateView() {
        DispatchQueue.main.async {
            UIView.transition(with: self.tableView,
                              duration: 0.8,
                              options: .transitionCrossDissolve,
                              animations: { self.tableView.reloadData() })
            
            self.balanceLabel.text = "\(AppConfig().numberWithCommaDisplayFormat(number: (self.realm.objects(Forex.self).value(forKeyPath:"balance") as! [Double]).reduce(0,+)))"
            
            self.equityLabel.text = "\(AppConfig().numberWithCommaDisplayFormat(number: (self.realm.objects(Forex.self).value(forKeyPath:"equity") as! [Double]).reduce(0, +)))"
            self.hideActivityIndicator()
        }
    }
    
    @IBAction func refreshButton(_ sender: Any) {
        let getForexObjectsfromRealM = self.realm.objects(Forex.self)
        let getForexArrayfromRealM = getForexObjectsfromRealM.value(forKeyPath:"symbol") as! [String]
        self.showActivityIndicator()
        updateForexList(newSelectedSymbolsArray: getForexArrayfromRealM)
    }
    
    @objc private func updateForexList(newSelectedSymbolsArray: [String]) {
        
        let getForexObjectsfromRealM = self.realm.objects(Forex.self)
        let getForexArrayfromRealM = getForexObjectsfromRealM.value(forKeyPath:"symbol") as! [String]
        
        // Remove non-selected symbols in Watchlist
        for symbol in getForexArrayfromRealM {
            if(!newSelectedSymbolsArray.contains(symbol)){
                let data = self.realm.object(ofType: Forex.self, forPrimaryKey: symbol)
                if data != nil {try! self.realm.write {self.realm.delete(data!)}}
            }
        }
        
        // Add/Update new/old symbols in Watchlist
        if !newSelectedSymbolsArray.indices.contains(0) {
            self.updateView()
            return
        } else {
            let selectedSymbolsCommaSeparatedString = newSelectedSymbolsArray.joined(separator: ",")
            
            guard let url = URL(string: "https://www.freeforexapi.com/api/live?pairs=" + selectedSymbolsCommaSeparatedString) else {
                return
            }
            
            self.networkHelp.execute(url, completion: { (json, error) in
                if let error = error {
                    print("Error in network request: \(error.localizedDescription)")
                } else if let json: NSDictionary = json {
                    outer: for (newForexName, newForexData) in json["rates"]  as! NSDictionary {
                        if let newForexData = newForexData as? NSDictionary {
                            inner: for oldForexObj in getForexObjectsfromRealM {
                                if (newForexName as! String) == oldForexObj.symbol {
                                    try! self.realm.write {
                                        oldForexObj.rate = newForexData["rate"] as! Double
                                        oldForexObj.timeStamp = newForexData["timestamp"] as! Double
                                        ForexViewModel(oldForexObj).updateBuyAndSellRate()
                                        ForexViewModel(oldForexObj).updateChange()
                                        ForexViewModel(oldForexObj).updateEquity()
                                        ForexViewModel(oldForexObj).updateProfitAndLoss()
                                    }
                                    continue outer
                                }
                            }
                            let newForexObj = Forex(symbol: newForexName as! String, rate: newForexData["rate"] as! Double, timeStamp: newForexData["timestamp"] as! Double)
                            try! self.realm.write {self.realm.add(newForexObj)}
                        }
                    }
                    self.updateView()
                }
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowForexDetailsViewController" {
            let forexDetailVC = segue.destination as! WatchlistDetailViewController
//            print(self.realmSymbolsInWatchListArray[self.tableView.indexPathForSelectedRow!.section])
            forexDetailVC.forex =
                self.realmSymbolsInWatchListArray[self.tableView.indexPathForSelectedRow!.section]
        }
        else{
            guard let navVC = segue.destination as? UINavigationController,
                let WatchlistEditVC = navVC.viewControllers.first as? WatchlistEditViewController else {
                    fatalError("No Controller")
            }
            WatchlistEditVC.selectedSymbolsObservable.subscribe(onNext: { selectedSymbols in
                //self.newSelectedSymbolsArray = selectedSymbols
                self.showActivityIndicator()
                self.updateForexList(newSelectedSymbolsArray: selectedSymbols)
            }).disposed(by: disposeBag)
        }
    }
}

// MARK: - Activity Indicator method
extension WatchlistViewController {
    func showActivityIndicator() {
        activityIndicatorView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        activityIndicatorView.center = self.view.center
        activityIndicatorView.style = .whiteLarge
        activityIndicatorView.color = .black
        vieww.frame = CGRect(x:0, y:0, width: self.view.frame.width, height: self.view.frame.height)
        vieww.isOpaque = true
        view.addSubview(vieww)
        view.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
    }
    
    func hideActivityIndicator() {
        activityIndicatorView.stopAnimating()
        activityIndicatorView.removeFromSuperview()
        vieww.removeFromSuperview()
    }
}

// MARK: - UITableViewDataSource
extension WatchlistViewController {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return realmSymbolsInWatchListArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    // Make the background color show through
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WatchlistViewCell", for: indexPath) as! WatchlistTableViewCell
        
        cell.forex = self.realmSymbolsInWatchListArray[indexPath.section]
        
        // Design
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 2
        cell.layer.cornerRadius = 12
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOpacity = .infinity
        cell.layer.shadowRadius = 3
        cell.layer.zPosition = 1
        cell.backgroundColor = .darkGray
        cell.isSelected = false
        cell.selectionStyle = .none
        
        return cell
    }
    
}
