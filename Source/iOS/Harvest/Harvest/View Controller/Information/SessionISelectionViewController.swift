//
//  SessionInformationViewController.swift
//  Harvest
//
//  Created by Letanyan Arumugam on 2018/05/04.
//  Copyright © 2018 Letanyan Arumugam. All rights reserved.
//

import UIKit

class SessionSelectionViewController: UITableViewController {
  var pageIndex: String?
  let pageSize: UInt = 21
  var isLoading = false
  var selectedSession: Session?
  var sessions = SortedDictionary<Date, SortedSet<Session>>(>)
  typealias SessionsIndex = SortedDictionary<Date, SortedSet<Session>>.Index
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    refreshControl = UIRefreshControl()
    refreshControl?.addTarget(self, action: #selector(refreshList(_:)), for: .valueChanged)
    tableView.addSubview(refreshControl!)
    
    loadNewPage()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    selectedSession = nil
    if let selPath = tableView.indexPathForSelectedRow {
      tableView.deselectRow(at: selPath, animated: true)
    }
  }
  
  func loadNewPage() {
    guard !isLoading else {
      return
    }
    
    isLoading = true
    tableView.reloadData()
    HarvestDB.getSessions(limitedToLast: pageSize) { psessions in
      self.sessions.accumulateByDay(with: psessions)
      DispatchQueue.main.async {
        self.isLoading = false
        self.tableView.reloadData()
      }
    }
  }
  
  @objc func refreshList(_ refreshControl: UIRefreshControl) {
    guard !isLoading else {
      return
    }
    
    isLoading = true
    HarvestDB.getRefreshedSessions(limitedToLast: pageSize) { psessions in
      self.sessions.removeAll()
      self.sessions.accumulateByDay(with: psessions)
      DispatchQueue.main.async {
        self.isLoading = false
        self.refreshControl?.endRefreshing()
        self.tableView.reloadData()
      }
    }
  }
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return sessions.count + (isLoading ? 1 : 0)
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if isLoading && section == sessions.count {
      return 1
    }
    return sessions[SessionsIndex(section)].value.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if isLoading && indexPath.section == sessions.count {
      let cell = tableView.dequeueReusableCell(withIdentifier: "sessionSelectionLoadingCell", for: indexPath)
      for subview in cell.contentView.subviews where subview is UIActivityIndicatorView {
        (subview as? UIActivityIndicatorView)?.startAnimating()
      }
      return cell
    }
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "sessionSelectionCell", for: indexPath)
    
    let sidx = SessionsIndex(indexPath.section)
    
    let formatter = DateFormatter()
    formatter.dateStyle = .none
    formatter.timeStyle = .short
    
    let session = sessions[sidx].value[indexPath.row]
    let date = session.startDate
    let name = session.foreman.description
    cell.textLabel?.text =  name + " - " + formatter.string(from: date)
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard !isLoading || indexPath.section != sessions.count else {
      return
    }
    let sidx = SessionsIndex(indexPath.section)
    
    self.selectedSession = sessions[sidx].value[indexPath.row]
    self.performSegue(withIdentifier: "SessionToItem", sender: self)
  }
  
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    
    guard !isLoading || section != sessions.count else {
      return nil
    }
    
    let sidx = SessionsIndex(section)
    
    let date = sessions[sidx].key
    
    return formatter.string(from: date)
  }
  
  override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    if scrollView.contentOffset.y + scrollView.frame.size.height >= scrollView.contentSize.height {
      if !isLoading {
        loadNewPage()
      }
    }
  }
  
  override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
    return selectedSession != nil
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let vc = segue.destination
    
    guard let entityVC = vc as? EntityViewController else {
      fatalError("Check to make sure only one segue exists to an EntityViewController")
    }
    
    guard let session = selectedSession else {
      fatalError("Somthing went wrong. Never get to segue without a selected session")
    }
    
    entityVC.title = session.description
    entityVC.entity = .session(session)
    
  }
}
