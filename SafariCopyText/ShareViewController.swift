//
//  ShareViewController.swift
//  SafariCopyText
//
//

import UIKit
import Social

class ShareViewController: SLComposeServiceViewController {
    
    private struct SuffixItem {
        let suffix: String
        var repeatCount: Int
        
        mutating func increaseCount() {
            repeatCount += 1
        }
    }
    
    @IBOutlet weak var resultView: UIView!
    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    @IBOutlet weak var sortingSegmentControl: UISegmentedControl!
    
    private var allSuffixItems = [SuffixItem]()
    private var filteredSuffixItems = [SuffixItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resultView.layer.cornerRadius = CGFloat(30)
        setupSortingSegmentControl()
    }
    
    @IBAction func close(_ sender: UIButton) {
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }
    
    @IBAction func change(_ sender: UISegmentedControl) {
        setupSortingSegmentControl()
        setupFilteredSuffixItems()
        tableView.reloadData()
    }
    
    @IBAction func changeSortOrder(_ sender: UISegmentedControl) {
        setupFilteredSuffixItems()
        tableView.reloadData()
    }
    
    override func isContentValid() -> Bool {
        return true
    }
    
    override func didSelectPost() {
        setupAllSuffixItems(contentText: contentText)
        setupFilteredSuffixItems()
        tableView.reloadData()
    }
    
    override func configurationItems() -> [Any]! {
        return []
    }
}

extension ShareViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredSuffixItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SuffixCell", for: indexPath)
        cell.textLabel?.text = filteredSuffixItems[indexPath.row].suffix
        let repeatCount = filteredSuffixItems[indexPath.row].repeatCount
        cell.detailTextLabel?.text = repeatCount > 1 ? "\(repeatCount)" : ""
        return cell
    }
}

private extension ShareViewController {
    
    private func setupSortingSegmentControl() {
        if segmentControl.selectedSegmentIndex == 0 {
            sortingSegmentControl.isHidden = false
        } else {
            sortingSegmentControl.isHidden = true
        }
    }
    
    private func setupFilteredSuffixItems() {
        let selected = segmentControl.selectedSegmentIndex
        let sortingSelected = sortingSegmentControl.selectedSegmentIndex
        
        if selected == 0 {
            filteredSuffixItems = allSuffixItems.sorted(by: {
                sortingSelected == 0 ? $0.suffix < $1.suffix : $0.suffix > $1.suffix
            })
            return
        }
        
        var items = [SuffixItem]()
        
        if selected == 1 {
            items = allSuffixItems.filter { $0.suffix.count == 3 }
        } else if selected == 2 {
            items = allSuffixItems.filter { $0.suffix.count == 5 }
        }
        
        items.sort(by: { $0.repeatCount > $1.repeatCount })
        filteredSuffixItems = [SuffixItem](items.prefix(10))
    }
    
    private func setupAllSuffixItems(contentText: String) {
        let suffixList = makeSuffixList(text: contentText)
        suffixList.forEach { suffix in
            if let index = allSuffixItems.firstIndex(where: { $0.suffix == suffix }) {
                allSuffixItems[index].increaseCount()
            } else {
                allSuffixItems.append(SuffixItem(suffix: suffix, repeatCount: 1))
            }
        }
    }
    
    private func makeSuffixList(text: String) -> [String] {
        return contentText
            .split(separator: " ")
            .flatMap { String($0).wordSuffixList }
    }
}
