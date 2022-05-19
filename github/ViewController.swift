//
//  ViewController.swift
//  github
//
//  Created by 김두원 on 2022/05/08.
//
// Change something
import UIKit

class ViewController: UIViewController , UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var customTableView: UITableView!
    @IBOutlet weak var searchBar : UISearchBar!
    let cellIdetifier: String = "repositoryCell"
    var resultItems: [Items?] = []
    var fetchingMore: Bool = false
    var per_page:Int = 30
    var page:Int = 1
    // MARK: - tableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if resultItems.isEmpty {
            return 1
        }
        else {
            return resultItems.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = customTableView.dequeueReusableCell(withIdentifier: cellIdetifier) as? TableViewCell else { return UITableViewCell() }
        
        if resultItems.isEmpty { cell.fullnameLabel.text = "No Result!"}
        else{
            cell.fullnameLabel.text = resultItems[indexPath.row]?.full_name
            cell.descriptionLabel.text = resultItems[indexPath.row]?.description ?? ""
        }
        return cell
    }
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        customTableView.delegate = self
        customTableView.dataSource = self
        searchBar.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        apiLoad()
    }
    
    // MARK: - API Load Data
    func apiLoad(qValue:String = "tetris") {

        var components = URLComponents(string: "https://api.github.com/search/repositories")
        let q = URLQueryItem(name: "q", value: qValue)
        let order = URLQueryItem(name: "order", value: "desc")
        let perPage = URLQueryItem(name: "per_page", value: "\(per_page)")
        let pageCount = URLQueryItem(name: "page", value: "\(page)")

        components?.queryItems = [q, order, perPage, pageCount]
        guard let url = components?.url else {
            print("URL failed")
            return
        }
        
        // URLSession
        let session: URLSession = URLSession(configuration: .default)
        // dataTask
        let dataTask: URLSessionDataTask = session.dataTask(with: url) { (data:Data? ,response:URLResponse? ,error:Error?) in
            
            if let error = error {
                print(error.localizedDescription)
            }
            
            guard let data = data else {
                return
            }
            
            // Json 데이터 디코드
            do{
                let apiResponse = try JSONDecoder().decode(Repositories.self, from: data)
                self.resultItems = apiResponse.items
                print("success!!!!!")
                // 테이블뷰에 데이터 뿌려줌
                DispatchQueue.main.async {
                    self.customTableView.reloadData()
                }
            } catch {
                print(error)
            }
        }
        return dataTask.resume()
    }

    // MARK - Scroll
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.height {
            if !fetchingMore {
                beginBatchFetch()
            }
        }
    }
    
    func beginBatchFetch() {
            fetchingMore = true
            // 0.7초 후에 실행 시킴
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: {
                self.page += 1
                
                self.apiLoad()
                
                print(self.page)
                self.fetchingMore = false
                self.customTableView.reloadData()
            })
     }
    
}

// MARK: - SearBarDelegate
extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String = "") {
        print("------------------\(searchText)------------------")
        if searchText.isEmpty { print("nil") }
        else { apiLoad(qValue: searchText) }
    }
}

