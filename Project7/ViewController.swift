//
//  ViewController.swift
//  Project7
//
//  Created by Luca Hummel on 08/07/21.
//

import UIKit

class ViewController: UITableViewController {
    var petitions = [Petition]()
    var searched = [Petition]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let creditButton = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(showCredits))
        let filterButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(showText))
        
        navigationItem.rightBarButtonItems = [filterButton, creditButton]
        
        let urlString: String
        
        if navigationController?.tabBarItem.tag
            == 0 {
            //"https://api.whitehouse.gov/v1/petitions.json?limit=100"
            urlString = "https://www.hackingwithswift.com/samples/petitions-1.json"
        } else {
            // urlString = "https://api.whitehouse.gov/v1/petitions.json?signatureCountFloor=10000&limit=100"
            urlString = "https://www.hackingwithswift.com/samples/petitions-2.json"
        }
        
        
        if let url = URL(string: urlString) {
            if let data = try? Data(contentsOf: url) {
                parse(json: data)
                searched += petitions
                return
            }
        }
        
        showError()
    }
    
    @objc func showText() {
        let ac = UIAlertController(title: "Search", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) {
            [weak self, weak ac] _ in
            guard let search = ac?.textFields?[0].text else { return }
            self?.searchData(search: search)
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    func searchData(search: String) {
        searched.removeAll()
        if search == ""{
            searched += petitions
        } else {
            for petition in petitions {
                if petition.title.contains(search) || petition.body.contains(search){
                    searched.append(petition)
                }
            }
        }
        tableView.reloadData()
    }
    
    @objc func showCredits() {
        let ac = UIAlertController(title: "Credits", message: "The data comes from the We The People API of the Whitehouse.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    func showError() {
        let ac = UIAlertController(title: "Loading Error", message: "There was a problem loading the feed; please check your connection and try again", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }

    func parse(json: Data) {
        let decoder = JSONDecoder()
        
        if let jsonPetitions = try? decoder.decode(Petitions.self, from: json) {
            petitions = jsonPetitions.results
            tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searched.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let petition = searched[indexPath.row]
        cell.textLabel?.text = petition.title
        cell.detailTextLabel?.text = petition.body
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailViewController()
        vc.detailItem = searched[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
}

